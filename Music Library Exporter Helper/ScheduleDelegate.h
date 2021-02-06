//
//  ScheduleDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import <Foundation/Foundation.h>

@class ScheduleConfiguration;
@class ExportDelegate;


NS_ASSUME_NONNULL_BEGIN

@interface ScheduleDelegate : NSObject


#pragma mark - Properties -

@property ScheduleConfiguration* configuration;

@property ExportDelegate* exportDelegate;


#pragma mark - Initializers -

- (instancetype)init;

+ (instancetype)schedulerWithConfig:(ScheduleConfiguration*)config;
+ (instancetype)schedulerWithConfig:(ScheduleConfiguration*)config andExporter:(ExportDelegate*)exportDelegate;

#pragma mark - Accessors -

+ (NSString*)getCurrentPowerSource;
+ (BOOL)isSystemRunningOnBattery;


#pragma mark - Mutators -

- (void)activateScheduler;
- (void)deactivateScheduler;

- (void)setInterval:(NSTimeInterval)scheduleInterval;



@end

NS_ASSUME_NONNULL_END
