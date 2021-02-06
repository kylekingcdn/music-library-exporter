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
#import "ExportConfiguration.h"
#import "ExportDelegate.h"
#import "ScheduleConfiguration.h"

@implementation ScheduleDelegate {

  NSUserDefaults* _groupDefaults;

  NSTimer* _timer;
}


#pragma mark - Initializers -

- (instancetype)init {

  self = [super init];

  _groupDefaults = [[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier];
  [_groupDefaults addObserver:self forKeyPath:@"ScheduleInterval" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"LastExportedAt" options:NSKeyValueObservingOptionNew context:NULL];
  [_groupDefaults addObserver:self forKeyPath:@"NextExportAt" options:NSKeyValueObservingOptionNew context:NULL];

  return self;
}

+ (instancetype)schedulerWithConfig:(ScheduleConfiguration*)config {

  ScheduleDelegate* scheduleDelegate = [[ScheduleDelegate alloc] init];
  [scheduleDelegate setConfiguration:config];

  return scheduleDelegate;
}

+ (instancetype)schedulerWithConfig:(ScheduleConfiguration*)config andExporter:(ExportDelegate*)exportDelegate {

  ScheduleDelegate* scheduleDelegate = [[ScheduleDelegate alloc] init];
  [scheduleDelegate setConfiguration:config];
  [scheduleDelegate setExportDelegate:exportDelegate];

  return scheduleDelegate;
}


#pragma mark - Accessors -

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

- (ExportDeferralReason)reasonToDeferExport {

  if (!_configuration || !_exportDelegate) {
    return ExportDeferralErrorReason;
  }
  if (_configuration.skipOnBattery && [ScheduleDelegate isSystemRunningOnBattery]) {
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

  _timer = [NSTimer scheduledTimerWithTimeInterval:_interval*60*60 target:self selector:@selector(onTimerFinished) userInfo:nil repeats:YES];
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

  NSLog(@"ScheduleDelegate [onTimerFinished] current power source: %@", [ScheduleDelegate getCurrentPowerSource]);

  [_exportDelegate exportLibrary];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)anObject change:(NSDictionary*)aChange context:(void*)aContext {

  NSLog(@"ScheduleDelegate [observeValueForKeyPath:%@]", keyPath);

  if ([keyPath isEqualToString:@"ScheduleInterval"] ||
      [keyPath isEqualToString:@"LastExportedAt"] ||
      [keyPath isEqualToString:@"NextExportAt"]) {

    // fetch latest configuration values
    [_configuration loadPropertiesFromUserDefaults];
  }
}

@end
