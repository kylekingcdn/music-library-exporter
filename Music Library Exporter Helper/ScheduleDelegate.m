//
//  ScheduleDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import "ScheduleDelegate.h"

#import "Defines.h"
#import "ExportDelegate.h"

@implementation ScheduleDelegate {

  NSTimer* _timer;
  NSTimeInterval _interval;
}


#pragma mark - Initializers -

- (instancetype)initWithExportDelegate:(ExportDelegate*)exportDelegate {

  self = [super init];


  [self setExportDelegate:exportDelegate];

  return self;
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
