//
//  ExportScheduler.m
//  Music Library Exporter Helper
//
//  Created by Kyle King on 2021-02-02.
//

#import "ExportScheduler.h"

#import <Cocoa/Cocoa.h>
#import <IOKit/ps/IOPowerSources.h>

#import "Logger.h"
#import "Defines.h"
#import "Utils.h"
#import "UserDefaultsExportConfiguration.h"
#import "ExportManager.h"
#import "ScheduleConfiguration.h"
#import "DirectoryPermissionsWindowController.h"

@implementation ExportScheduler {

  NSUserDefaults* _groupDefaults;

  NSTimer* _timer;

  DirectoryPermissionsWindowController* _permissionsWindowController;
}


#pragma mark - Initializers

- (instancetype)init {

  self = [super init];

  // detect changes in NSUSerDefaults for app group
  _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  [_groupDefaults addObserver:self forKeyPath:@"ScheduleEnabled" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"ScheduleInterval" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"LastExportedAt" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"OutputDirectoryPath" options:NSKeyValueObservingOptionNew context:NULL];

  // update schedule
  [self updateSchedule];

  // request output dir permission if required
  [self requestOutputDirectoryPermissionsIfRequired];

  return self;
}


#pragma mark - Accessors

- (nullable NSDate*)determineNextExportDate {

  NSDate* lastExportDate = ScheduleConfiguration.sharedConfig.lastExportedAt;

  if (ScheduleConfiguration.sharedConfig.scheduleEnabled) {

    // overdue, schedule 60s from now
    if (lastExportDate == nil) {
      return [NSDate dateWithTimeIntervalSinceNow:60];
    }

    NSTimeInterval intervalSinceLastExport = 0 - [lastExportDate timeIntervalSinceNow];
    MLE_Log_Info(@"ExportScheduler [determineNextExportDate] %fs since last export", intervalSinceLastExport);

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

  NSString* powerSource = [ExportScheduler getCurrentPowerSource];

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

  MLE_Log_Info(@"ExportScheduler [isOutputDirectoryBookmarkValid]");

  NSString* outputDirPath = UserDefaultsExportConfiguration.sharedConfig.outputDirectoryPath;
  if (outputDirPath.length == 0) {
    MLE_Log_Info(@"ExportScheduler [isOutputDirectoryBookmarkValid] output directory has not been set yet");
    return NO;
  }

  NSURL* outputDirUrl = [UserDefaultsExportConfiguration.sharedConfig resolveOutputDirectoryBookmarkAndReturnError:nil];

  if (outputDirUrl && outputDirUrl.isFileURL) {

    if ([outputDirUrl.path isEqualToString:outputDirPath]) {
      MLE_Log_Info(@"ExportScheduler [isOutputDirectoryBookmarkValid] bookmark is valid");
      return YES;
    }
    MLE_Log_Info(@"ExportScheduler [isOutputDirectoryBookmarkValid] bookmarked path: %@", outputDirUrl.path);
  }

  MLE_Log_Info(@"ExportScheduler [isOutputDirectoryBookmarkValid] bookmark is not valid. The helper app must be granted write permission to: %@", outputDirPath);

  return NO;
}

- (ExportDeferralReason)reasonToDeferExport {

  if (ScheduleConfiguration.sharedConfig.skipOnBattery && [ExportScheduler isSystemRunningOnBattery]) {
    return ExportDeferralOnBatteryReason;
  }
  if ([ExportScheduler isMainAppRunning]) {
    return ExportDeferralMainAppOpenReason;
  }

  return ExportNoDeferralReason;
}


#pragma mark - Mutators

- (void)activateScheduler {

  MLE_Log_Info(@"ExportScheduler [activateScheduler]");

  if (_timer) {
    [_timer invalidate];
    _timer = nil;
  }

  NSTimeInterval intervalToNextExport = ScheduleConfiguration.sharedConfig.nextExportAt.timeIntervalSinceNow;
  MLE_Log_Info(@"ExportScheduler [activateScheduler] next export in %fs", intervalToNextExport);

  _timer = [NSTimer scheduledTimerWithTimeInterval:intervalToNextExport target:self selector:@selector(onTimerFinished) userInfo:nil repeats:NO];
}

- (void)deactivateScheduler {

  MLE_Log_Info(@"ExportScheduler [deactivateScheduler]");

  if (_timer) {
    [_timer invalidate];
    _timer = nil;
  }
}

- (void)onTimerFinished {

  MLE_Log_Info(@"ExportScheduler [onTimerFinished]");

  ExportDeferralReason deferralReason = [self reasonToDeferExport];
  if (deferralReason == ExportNoDeferralReason) {

    /* -- temp -- generate output file url */
    NSError* outputDirResolveError;
    NSURL* outputDirectoryUrl = [UserDefaultsExportConfiguration.sharedConfig resolveOutputDirectoryBookmarkAndReturnError:&outputDirResolveError];
    if (outputDirectoryUrl == nil) {
      MLE_Log_Info(@"ExportScheduler [onTimerFinished] unable to retrieve output directory - a directory must be selected to obtain write permission");
    }
    NSString* outputFileName = UserDefaultsExportConfiguration.sharedConfig.outputFileName;
    if (outputFileName == nil || outputFileName.length == 0) {
      outputFileName = @"Library.xml"; // fallback to default filename
      MLE_Log_Info(@"ExportScheduler [onTimerFinished] output filename unspecified - falling back to default: %@", outputFileName);
    }
    // TODO: handle output directory validation
    NSURL* outputFileUrl = [outputDirectoryUrl URLByAppendingPathComponent:outputFileName];
    /* -- temp -- */

    ExportManager* exportManager = [[ExportManager alloc] initWithConfiguration:UserDefaultsExportConfiguration.sharedConfig];
    [exportManager setOutputFileURL:outputFileUrl];

    NSError* exportError;
    [outputDirectoryUrl startAccessingSecurityScopedResource];
    BOOL exportSuccessful = [exportManager exportLibraryWithError:&exportError];
    [outputDirectoryUrl stopAccessingSecurityScopedResource];
    if (!exportSuccessful) {
      // ... handle export error
      return;
    }
  }

  else {
    MLE_Log_Info(@"ExportScheduler [onTimerFinished] export task is being skipped for reason: %@", [Utils descriptionForExportDeferralReason:deferralReason]);
  }

  [ScheduleConfiguration.sharedConfig setLastExportedAt:[NSDate date]];
}

- (void)updateSchedule {

  MLE_Log_Info(@"ExportScheduler [updateSchedule]");

  NSDate* nextExportDate = [self determineNextExportDate];

  MLE_Log_Info(@"ExportScheduler [updateSchedule] next export: %@", nextExportDate.description);

  [ScheduleConfiguration.sharedConfig setNextExportAt:nextExportDate];

  if (nextExportDate) {
    [self activateScheduler];
  }
  else {
    [self deactivateScheduler];
  }
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)anObject change:(NSDictionary*)aChange context:(void*)aContext {

  MLE_Log_Info(@"ExportScheduler [observeValueForKeyPath:%@]", keyPath);

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

  if (_permissionsWindowController) {
    [[_permissionsWindowController window] close];
    _permissionsWindowController = nil;
  }

  _permissionsWindowController = [[DirectoryPermissionsWindowController alloc] initWithWindowNibName:@"DirectoryPermissionsWindow"];
  [_permissionsWindowController.window center];
  [_permissionsWindowController.window makeKeyAndOrderFront:self];
}

- (void)requestOutputDirectoryPermissionsIfRequired {

  NSString* outputDirPath = UserDefaultsExportConfiguration.sharedConfig.outputDirectoryPath;
  BOOL outputDirIsSet = (outputDirPath.length > 0);

  if (!outputDirIsSet) {
    MLE_Log_Info(@"ExportScheduler [requestOutputDirectoryPermissionsIfRequired] not prompting for permissions since output path hasn't been set yet");
    return;
  }
  else if (self.isOutputDirectoryBookmarkValid) {
    MLE_Log_Info(@"ExportScheduler [requestOutputDirectoryPermissionsIfRequired] output dir bookmark is valid, permissions grant not required");

  }
  else {
    MLE_Log_Info(@"ExportScheduler [requestOutputDirectoryPermissionsIfRequired] output dir bookmark is either not valid or inconsistent. Triggering prompt for permissions grant");
    [self requestOutputDirectoryPermissions];
  }
}

@end
