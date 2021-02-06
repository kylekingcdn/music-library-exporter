//
//  ScheduleDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import "ScheduleDelegate.h"

#import "Defines.h"
#import "ExportDelegate.h"
#import "ScheduleConfiguration.h"

@implementation ScheduleDelegate {

  NSTimer* _timer;
  NSTimeInterval _interval;
}


#pragma mark - Initializers -

- (instancetype)init {

  self = [super init];

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

#pragma mark - Mutators -

- (void)setInterval:(NSTimeInterval)val {

  NSLog(@"ScheduleDelegate [setInterval:%f]", val);

  _interval = val;

  if (_timer) {
    [self activateScheduler];
  }
}

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

  [_exportDelegate exportLibrary];
}

@end
