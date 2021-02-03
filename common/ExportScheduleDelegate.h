//
//  ExportScheduleDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ExportDelegate;
@class ScheduleConfiguration;


@interface ExportScheduleDelegate : NSObject


#pragma mark - Properties -

@property ScheduleConfiguration* configuration;


#pragma mark - Initializers -

- (instancetype)initWithConfiguration:(ScheduleConfiguration*)config andExportDelegate:(ExportDelegate*)exportDelegate;


#pragma mark - Accessors -

- (BOOL)isHelperRegisteredWithSystem;
- (NSString*)errorForHelperRegistration:(BOOL)registerFlag;


#pragma mark - Mutators -

- (BOOL)registerHelperWithSystem:(BOOL)flag;
- (void)updateHelperRegistrationIfRequired;

- (void)activateScheduler;
- (void)deactivateScheduler;



@end

NS_ASSUME_NONNULL_END
