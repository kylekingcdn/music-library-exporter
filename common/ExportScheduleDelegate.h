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


#pragma mark - Initializers -

- (instancetype)init;


#pragma mark - Accessors -

- (NSDictionary*)defaultValues;

- (BOOL)scheduleEnabled;
- (NSInteger)scheduleInterval;

- (BOOL)isHelperRegisteredWithSystem;
- (NSString*)errorForHelperRegistration:(BOOL)registerFlag;

- (void)dumpProperties;


#pragma mark - Mutators -

- (void)loadPropertiesFromUserDefaults;

- (void)setScheduleEnabled:(BOOL)flag;
- (void)setScheduleInterval:(NSInteger)interval;

- (BOOL)registerHelperWithSystem:(BOOL)flag;
- (void)updateHelperRegistrationIfRequired;


@end

NS_ASSUME_NONNULL_END
