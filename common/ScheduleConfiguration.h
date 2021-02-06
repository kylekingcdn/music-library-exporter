//
//  ScheduleConfiguration.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface ScheduleConfiguration : NSObject


#pragma mark - Initializers -

- (instancetype)init;


#pragma mark - Accessors -

- (NSDictionary*)defaultValues;

- (BOOL)scheduleEnabled;
- (NSTimeInterval)scheduleInterval;

- (nullable NSDate*)lastExportedAt;
- (nullable NSDate*)nextExportAt;

- (BOOL)skipOnBattery;

- (void)dumpProperties;


#pragma mark - Mutators -

- (void)loadPropertiesFromUserDefaults;

- (void)setScheduleEnabled:(BOOL)flag;
- (void)setScheduleInterval:(NSTimeInterval)interval;

- (void)setLastExportedAt:(nullable NSDate*)timestamp;
- (void)setNextExportAt:(nullable NSDate*)timestamp;

- (void)setSkipOnBattery:(BOOL)flag;



@end

NS_ASSUME_NONNULL_END
