//
//  ScheduleDelegate.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import "ScheduleDelegate.h"

#import "Defines.h"
#import "ScheduleConfiguration.h"
#import "ExportDelegate.h"

@implementation ScheduleDelegate {

  NSBackgroundActivityScheduler* _scheduler;
}


#pragma mark - Initializers -

- (instancetype)initWithConfiguration:(ScheduleConfiguration*)config andExportDelegate:(ExportDelegate*)exportDelegate {

  self = [super init];

  [self setConfiguration:config];
  [self setExportDelegate:exportDelegate];

  return self;
}


#pragma mark - Accessors -


#pragma mark - Mutators -

- (void)activateScheduler {

  NSLog(@"ScheduleDelegate [activateScheduler]");

  _scheduler = [[NSBackgroundActivityScheduler alloc] initWithIdentifier:[__MLE__HelperBundleIdentifier stringByAppendingString:@".scheduler"]];

  [_scheduler setRepeats:YES];
  [_scheduler setTolerance:60];
  [_scheduler setInterval:(_configuration.scheduleInterval * 60 * 60)];
  [_scheduler setQualityOfService:NSQualityOfServiceUtility];

  [_scheduler scheduleWithBlock:^(NSBackgroundActivityCompletionHandler completion) {

    NSLog(@"ScheduleDelegate [activateScheduler] starting task (%@)", [[NSDate date] description]);

    [self->_exportDelegate exportLibrary];
    
    completion(NSBackgroundActivityResultFinished);
  }];
}

- (void)deactivateScheduler {

  NSLog(@"ScheduleDelegate [deactivateScheduler]");

  [_scheduler invalidate];
}

@end
