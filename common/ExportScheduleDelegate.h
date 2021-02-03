//
//  ExportScheduleDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExportScheduleDelegate : NSObject {

  BOOL _scheduleEnabled;
  NSInteger _scheduleInterval;
}


#pragma mark - Properties -


#pragma mark - Initializers -

- (instancetype)init;


#pragma mark - Accessors -

- (NSDictionary*)defaultValues;

- (BOOL)scheduleEnabled;
- (NSInteger)scheduleInterval;

- (BOOL)isSchedulerRegisteredWithSystem;
- (NSString*)errorForSchedulerRegistration:(BOOL)registerFlag;


#pragma mark - Mutators -

- (void)loadPropertiesFromUserDefaults;

- (void)setScheduleEnabled:(BOOL)flag;
- (void)setScheduleInterval:(NSInteger)interval;

- (BOOL)registerSchedulerWithSystem:(BOOL)flag;
- (void)updateSchedulerRegistrationIfRequired;


@end

NS_ASSUME_NONNULL_END
