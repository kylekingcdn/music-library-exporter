//
//  ExportScheduleDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ExportDelegate;


@interface ExportScheduleDelegate : NSObject {

  BOOL _scheduleEnabled;
  NSInteger _scheduleInterval;
}


#pragma mark - Initializers -

- (instancetype)initWithExportDelegate:(ExportDelegate*)exportDelegate;


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

- (void)activateScheduler;
- (void)deactivateScheduler;



@end

NS_ASSUME_NONNULL_END
