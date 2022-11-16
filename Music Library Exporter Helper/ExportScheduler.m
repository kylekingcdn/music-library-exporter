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
#import "DirectoryBookmarkHandler.h"
#import "ExportManager.h"
#import "ScheduleConfiguration.h"
#import "DirectoryPermissionsWindowController.h"

@implementation ExportScheduler {

  NSUserDefaults* _groupDefaults;

  UserDefaultsExportConfiguration* _exportConfiguration;
  ScheduleConfiguration* _scheduleConfiguration;

  NSTimer* _timer;

  DirectoryPermissionsWindowController* _permissionsWindowController;
}


#pragma mark - Initializers

- (instancetype)init {

  if (self = [super init]) {

    // detect changes in NSUSerDefaults for app group
    _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
    [_groupDefaults addObserver:self forKeyPath:ScheduleConfigurationKeyScheduleEnabled options:NSKeyValueObservingOptionNew context:NULL];
    [_groupDefaults addObserver:self forKeyPath:ScheduleConfigurationKeyScheduleInterval options:NSKeyValueObservingOptionNew context:NULL];
    [_groupDefaults addObserver:self forKeyPath:ScheduleConfigurationKeyLastExportedAt options:NSKeyValueObservingOptionNew context:NULL];
    [_groupDefaults addObserver:self forKeyPath:ExportConfigurationKeyOutputDirectoryPath options:NSKeyValueObservingOptionNew context:NULL];

    _exportConfiguration = nil;
    _scheduleConfiguration = nil;

    _timer = nil;

    _permissionsWindowController = nil;

    return self;
  }
  else {
    return nil;
  }
}

- (instancetype)initWithExportConfiguration:(UserDefaultsExportConfiguration*)exportConfiguration
                   andScheduleConfiguration:(ScheduleConfiguration*)scheduleConfiguration {

  if (self = [self init]) {

    _exportConfiguration = exportConfiguration;
    _scheduleConfiguration = scheduleConfiguration;

    // update schedule
    [self updateSchedule];

    // request output dir permission if required
    [self requestOutputDirectoryPermissionsIfRequired];

    return self;
  }
  else {
    return nil;
  }
}


#pragma mark - Accessors

- (nullable NSDate*)determineNextExportDate {

  NSDate* lastExportDate = _scheduleConfiguration.lastExportedAt;

  if (_scheduleConfiguration.scheduleEnabled) {

    // overdue, schedule 60s from now
    if (lastExportDate == nil) {
      return [NSDate dateWithTimeIntervalSinceNow:60];
    }

    NSTimeInterval intervalSinceLastExport = 0 - [lastExportDate timeIntervalSinceNow];
    MLE_Log_Info(@"ExportScheduler [determineNextExportDate] %fs since last export", intervalSinceLastExport);

    // overdue, schedule 60s from now
    if (intervalSinceLastExport > _scheduleConfiguration.scheduleInterval) {
      return [NSDate dateWithTimeIntervalSinceNow:10/*60*/];
    }

    return [lastExportDate dateByAddingTimeInterval:_scheduleConfiguration.scheduleInterval];
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

  NSString* outputDirPath = _exportConfiguration.outputDirectoryPath;
  if (outputDirPath.length == 0) {
    MLE_Log_Info(@"ExportScheduler [isOutputDirectoryBookmarkValid] output directory has not been set yet");
    return NO;
  }

  DirectoryBookmarkHandler* bookmarkHandler = [[DirectoryBookmarkHandler alloc] initWithUserDefaultsKey:OUTPUT_DIRECTORY_BOOKMARK_KEY];
  NSURL* outputDirectoryURL = [bookmarkHandler urlFromDefaultsAndReturnError:nil];

  if (outputDirectoryURL && outputDirectoryURL.isFileURL) {

    if ([outputDirectoryURL.path isEqualToString:outputDirPath]) {
      MLE_Log_Info(@"ExportScheduler [isOutputDirectoryBookmarkValid] bookmark is valid");
      return YES;
    }
    MLE_Log_Info(@"ExportScheduler [isOutputDirectoryBookmarkValid] bookmarked path: %@", outputDirectoryURL.path);
  }

  MLE_Log_Info(@"ExportScheduler [isOutputDirectoryBookmarkValid] bookmark is not valid. The helper app must be granted write permission to: %@", outputDirPath);

  return NO;
}

- (ExportDeferralReason)reasonToDeferExport {

  if (_scheduleConfiguration.skipOnBattery && [ExportScheduler isSystemRunningOnBattery]) {
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

  NSTimeInterval intervalToNextExport = _scheduleConfiguration.nextExportAt.timeIntervalSinceNow;
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

    // resolve output filename (fallback to default if none provided)
    NSString* outputFileName = _exportConfiguration.outputFileName;
    if (outputFileName == nil || outputFileName.length == 0) {
      outputFileName = @"Library.xml";
      MLE_Log_Info(@"ConfigurationViewController [exportLibrary] output filename unspecified - falling back to default: %@", outputFileName);
    }

    // resolve output directory
    DirectoryBookmarkHandler* bookmarkHandler = [[DirectoryBookmarkHandler alloc] initWithUserDefaultsKey:OUTPUT_DIRECTORY_BOOKMARK_KEY];
    NSError* bookmarkResolveError;
    NSURL* outputDirectoryURL = [bookmarkHandler urlFromDefaultsAndReturnError:&bookmarkResolveError];
    if (outputDirectoryURL == nil) {
      MLE_Log_Info(@"ConfigurationViewController [exportLibrary] unable to retrieve output directory url: %@", bookmarkResolveError);
    }

    // init outputFileURL from OutputDirectoryURL anbd outputFileName
    NSURL* outputFileURL = [outputDirectoryURL URLByAppendingPathComponent:outputFileName];

    ExportManager* exportManager = [[ExportManager alloc] initWithConfiguration:_exportConfiguration];
    [exportManager setOutputFileURL:outputFileURL];

    /* ---- scoped security access started ---- */
    [outputDirectoryURL startAccessingSecurityScopedResource];

    // run export
    NSError* exportError;
    BOOL exportSuccessful = [exportManager exportLibraryWithError:&exportError];

    [outputDirectoryURL stopAccessingSecurityScopedResource];
    /* ---- scoped security access stopped ---- */

    if (!exportSuccessful) {
      // ... handle export error
      return;
    }
  }

  else {
    MLE_Log_Info(@"ExportScheduler [onTimerFinished] export task is being skipped for reason: %@", ExportDeferralReasonNames[deferralReason]);
  }

  [_scheduleConfiguration setLastExportedAt:[NSDate date]];
}

- (void)updateSchedule {

  MLE_Log_Info(@"ExportScheduler [updateSchedule]");

  NSDate* nextExportDate = [self determineNextExportDate];

  MLE_Log_Info(@"ExportScheduler [updateSchedule] next export: %@", nextExportDate.description);

  [_scheduleConfiguration setNextExportAt:nextExportDate];

  if (nextExportDate) {
    [self activateScheduler];
  }
  else {
    [self deactivateScheduler];
  }
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)anObject change:(NSDictionary*)aChange context:(void*)aContext {

  MLE_Log_Info(@"ExportScheduler [observeValueForKeyPath:%@]", keyPath);

  if ([keyPath isEqualToString:ScheduleConfigurationKeyScheduleEnabled] ||
      [keyPath isEqualToString:ScheduleConfigurationKeyScheduleInterval] ||
      [keyPath isEqualToString:ScheduleConfigurationKeyLastExportedAt] ||
      [keyPath isEqualToString:ExportConfigurationKeyOutputDirectoryPath]) {

    // fetch latest configuration values
    [_scheduleConfiguration loadPropertiesFromUserDefaults];
    [_exportConfiguration loadPropertiesFromUserDefaults];

    [self requestOutputDirectoryPermissionsIfRequired];
    [self updateSchedule];
  }
}

- (void)requestOutputDirectoryPermissions {

  if (_permissionsWindowController) {
    [[_permissionsWindowController window] close];
    _permissionsWindowController = nil;
  }

  _permissionsWindowController = [[DirectoryPermissionsWindowController alloc] initWithExportConfiguration:_exportConfiguration andScheduleConfiguration:_scheduleConfiguration];
  [_permissionsWindowController.window center];
  [_permissionsWindowController.window makeKeyAndOrderFront:self];
}

- (void)requestOutputDirectoryPermissionsIfRequired {

  NSString* outputDirPath = _exportConfiguration.outputDirectoryPath;
  BOOL outputDirIsSet = (outputDirPath.length > 0);

  if (!outputDirIsSet) {
    MLE_Log_Info(@"ExportScheduler [requestOutputDirectoryPermissionsIfRequired] not prompting for permissions since output path hasn't been set yet");
    return;
  }
  else if ([self isOutputDirectoryBookmarkValid]) {
    MLE_Log_Info(@"ExportScheduler [requestOutputDirectoryPermissionsIfRequired] output dir bookmark is valid, permissions grant not required");
  }
  else {
    MLE_Log_Info(@"ExportScheduler [requestOutputDirectoryPermissionsIfRequired] output dir bookmark is either not valid or inconsistent. Triggering prompt for permissions grant");
    [self requestOutputDirectoryPermissions];
  }
}

@end
