//
//  ScheduleDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import "ScheduleDelegate.h"

#import <Cocoa/Cocoa.h>
#import <IOKit/ps/IOPowerSources.h>

#import "Defines.h"
#import "Utils.h"
#import "UserDefaultsExportConfiguration.h"
#import "ExportDelegate.h"
#import "ScheduleConfiguration.h"

@implementation ScheduleDelegate {

  ExportDelegate* _exportDelegate;

  NSUserDefaults* _groupDefaults;

  NSTimer* _timer;
}


#pragma mark - Initializers -

- (instancetype)initWithExportDelegate:(ExportDelegate*)exportDelegate {

  self = [super init];

  // detect changes in NSUSerDefaults for app group
  _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  [_groupDefaults addObserver:self forKeyPath:@"ScheduleEnabled" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"ScheduleInterval" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"LastExportedAt" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"OutputDirectoryPath" options:NSKeyValueObservingOptionNew context:NULL];

  _exportDelegate = exportDelegate;

  // update schedule
  [self updateSchedule];

  // request output dir permission if required
  [self requestOutputDirectoryPermissionsIfRequired];

  return self;
}


#pragma mark - Accessors -

- (nullable NSDate*)determineNextExportDate {

  NSDate* lastExportDate = ScheduleConfiguration.sharedConfig.lastExportedAt;

  if (ScheduleConfiguration.sharedConfig.scheduleEnabled) {

    // overdue, schedule 60s from now
    if (!lastExportDate) {
      return [NSDate dateWithTimeIntervalSinceNow:60];
    }

    NSTimeInterval intervalSinceLastExport = 0 - [lastExportDate timeIntervalSinceNow];
    NSLog(@"ScheduleDelegate [determineNextExportDate] %fs since last export", intervalSinceLastExport);

    // overdue, schedule 60s from now
    if (intervalSinceLastExport > ScheduleConfiguration.sharedConfig.scheduleInterval) {
      return [NSDate dateWithTimeIntervalSinceNow:10/*60*/];
    }

    return [lastExportDate dateByAddingTimeInterval:ScheduleConfiguration.sharedConfig.scheduleInterval];
  }

  return nil;
}

+ (NSString*)getCurrentPowerSource {

  return (__bridge NSString *)IOPSGetProvidingPowerSourceType(NULL);
}

+ (BOOL)isSystemRunningOnBattery {

  NSString* powerSource = [ScheduleDelegate getCurrentPowerSource];

  //BOOL isSystemRunningOnAc = [powerSource isEqualToString:@kIOPMACPowerKey];
  BOOL isSystemRunningOnBattery = [powerSource isEqualToString:@kIOPMBatteryPowerKey];
  BOOL isSystemRunningOnUps = [powerSource isEqualToString:@kIOPMUPSPowerKey];

  return isSystemRunningOnBattery || isSystemRunningOnUps; // || !isSystemRunningOnAc;
}

+ (BOOL)isMainAppRunning {

  NSArray<NSRunningApplication*>* runningApplications = [[NSWorkspace sharedWorkspace] runningApplications];

  for (NSRunningApplication* runningApplication in runningApplications) {

    if ([runningApplication.bundleIdentifier isEqualToString:__MLE__AppBundleIdentifier]) {
      return YES;
    }
  }

  return NO;
}

- (BOOL)isOutputDirectoryBookmarkValid {

  NSLog(@"ScheduleDelegate [isOutputDirectoryBookmarkValid]");

  NSString* outputDirPath = UserDefaultsExportConfiguration.sharedConfig.outputDirectoryPath;
  if (outputDirPath.length == 0) {
    NSLog(@"ScheduleDelegate [isOutputDirectoryBookmarkValid] output directory has not been set yet");
    return NO;
  }

  NSURL* outputDirUrl = UserDefaultsExportConfiguration.sharedConfig.resolveAndAutoRenewOutputDirectoryUrl;

  if (outputDirUrl && outputDirUrl.isFileURL) {

    if ([outputDirUrl.path isEqualToString:outputDirPath]) {
      NSLog(@"ScheduleDelegate [isOutputDirectoryBookmarkValid] bookmark is valid");
      return YES;
    }
    NSLog(@"ScheduleDelegate [isOutputDirectoryBookmarkValid] bookmarked path: %@", outputDirUrl.path);
  }

  NSLog(@"ScheduleDelegate [isOutputDirectoryBookmarkValid] bookmark is not valid. The helper app must be granted write permission to: %@", outputDirPath);

  return NO;
}

- (ExportDeferralReason)reasonToDeferExport {

  if (!_exportDelegate) {
    return ExportDeferralErrorReason;
  }
  if (ScheduleConfiguration.sharedConfig.skipOnBattery && [ScheduleDelegate isSystemRunningOnBattery]) {
    return ExportDeferralOnBatteryReason;
  }
  if ([ScheduleDelegate isMainAppRunning]) {
    return ExportDeferralMainAppOpenReason;
  }

  return ExportNoDeferralReason;
}


#pragma mark - Mutators -

- (void)activateScheduler {

  NSLog(@"ScheduleDelegate [activateScheduler]");

  if (_timer) {
    [_timer invalidate];
    _timer = nil;
  }

  NSTimeInterval intervalToNextExport = ScheduleConfiguration.sharedConfig.nextExportAt.timeIntervalSinceNow;
  NSLog(@"ScheduleDelegate [activateScheduler] next export in %fs", intervalToNextExport);

  _timer = [NSTimer scheduledTimerWithTimeInterval:intervalToNextExport target:self selector:@selector(onTimerFinished) userInfo:nil repeats:NO];
}

- (void)deactivateScheduler {

  NSLog(@"ScheduleDelegate [deactivateScheduler]");

  if (_timer) {
    [_timer invalidate];
    _timer = nil;
  }
}

- (void)onTimerFinished {

  NSLog(@"ScheduleDelegate [onTimerFinished]");

  ExportDeferralReason deferralReason = [self reasonToDeferExport];
  if (deferralReason == ExportNoDeferralReason) {

    if ([_exportDelegate prepareForExport]) {
      [_exportDelegate exportLibrary];
    }
  }

  else {
    NSLog(@"ScheduleDelegate [onTimerFinished] export task is being skipped for reason: %@", [Utils descriptionForExportDeferralReason:deferralReason]);
  }

  [ScheduleConfiguration.sharedConfig setLastExportedAt:[NSDate date]];
}

- (void)updateSchedule {

  NSLog(@"ScheduleDelegate [updateSchedule]");

  NSDate* nextExportDate = [self determineNextExportDate];

  NSLog(@"ScheduleDelegate [updateSchedule] next export: %@", nextExportDate.description);

  [ScheduleConfiguration.sharedConfig setNextExportAt:nextExportDate];

  if (nextExportDate) {
    [self activateScheduler];
  }
  else {
    [self deactivateScheduler];
  }
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)anObject change:(NSDictionary*)aChange context:(void*)aContext {

  NSLog(@"ScheduleDelegate [observeValueForKeyPath:%@]", keyPath);

  if ([keyPath isEqualToString:@"ScheduleEnabled"] ||
      [keyPath isEqualToString:@"ScheduleInterval"] ||
      [keyPath isEqualToString:@"LastExportedAt"] ||
      [keyPath isEqualToString:@"OutputDirectoryPath"]) {

    // fetch latest configuration values
    [ScheduleConfiguration.sharedConfig loadPropertiesFromUserDefaults];
    [UserDefaultsExportConfiguration.sharedConfig loadPropertiesFromUserDefaults];

    [self requestOutputDirectoryPermissionsIfRequired];
    [self updateSchedule];
  }
}

- (void)requestOutputDirectoryPermissions {

  NSLog(@"ScheduleDelegate [requestOutputDirectoryPermissions]");

  NSString* outputDirPath = UserDefaultsExportConfiguration.sharedConfig.outputDirectoryPath;

  // Set activation policy to regular to allow for modal to pop up
  [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyRegular];
  
  NSOpenPanel* openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setLevel:NSFloatingWindowLevel];

  [openPanel setMessage:@"Select a location to save the generated library."];
  if (outputDirPath.length > 0) {
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:outputDirPath]];
  }

  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];

  [openPanel beginWithCompletionHandler:^(NSInteger result) {

    if (result == NSModalResponseOK) {

      NSURL* outputDirUrl = [openPanel URL];

      if (outputDirUrl) {
        if (outputDirPath.length == 0 || [outputDirUrl.path isEqualToString:outputDirUrl.path]) {
          NSLog(@"ScheduleDelegate [requestOutputDirectoryPermissions] the correct output directory has been selected");
          [UserDefaultsExportConfiguration.sharedConfig setOutputDirectoryUrl:outputDirUrl];
        }
        else {
          NSLog(@"ScheduleDelegate [requestOutputDirectoryPermissions] the user has selected a diretory that differs from the output directory set with the main app.");
        }
      }
      else {
        NSLog(@"ScheduleDelegate [requestOutputDirectoryPermissions] the user has cancelled granting permissions. Automated exports will be disabled.");
        // TODO: warn user that automated exports will be disabled + do disable
      }
    }
    else {
      NSLog(@"ScheduleDelegate [requestOutputDirectoryPermissions] the user has cancelled granting permissions. Automated exports will be disabled.");
      // TODO: warn user that automated exports will be disabled + do disable
    }

    // reset activation policy
    [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyProhibited];
  }];
}

- (void)requestOutputDirectoryPermissionsIfRequired {

  NSString* outputDirPath = UserDefaultsExportConfiguration.sharedConfig.outputDirectoryPath;
  BOOL outputDirIsSet = (outputDirPath.length > 0);

  if (!outputDirIsSet) {
    NSLog(@"ScheduleDelegate [requestOutputDirectoryPermissionsIfRequired] not prompting for permissions since output path hasn't been set yet");
    return;
  }
  else if (self.isOutputDirectoryBookmarkValid) {
    NSLog(@"ScheduleDelegate [requestOutputDirectoryPermissionsIfRequired] output dir bookmark is valid, permissions grant not required");

  }
  else {
    NSLog(@"ScheduleDelegate [requestOutputDirectoryPermissionsIfRequired] output dir bookmark is either not valid or inconsistent. Triggering prompt for permissions grant");
    [self requestOutputDirectoryPermissions];
  }
}

@end
