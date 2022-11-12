//
//  ExportScheduler.h
//  Music Library Exporter Helper
//
//  Created by Kyle King on 2021-02-02.
//

#import <Foundation/Foundation.h>

#import "Defines.h"

@class ScheduleConfiguration;


NS_ASSUME_NONNULL_BEGIN

@interface ExportScheduler : NSObject


#pragma mark - Initializers

- (instancetype)init;


#pragma mark - Accessors

- (nullable NSDate*)determineNextExportDate;

+ (NSString*)getCurrentPowerSource;
+ (BOOL)isSystemRunningOnBattery;

+ (BOOL)isMainAppRunning;

- (BOOL)isOutputDirectoryBookmarkValid;

- (ExportDeferralReason)reasonToDeferExport;


#pragma mark - Mutators

- (void)activateScheduler;
- (void)deactivateScheduler;

- (void)updateSchedule;

- (void)requestOutputDirectoryPermissions;
- (void)requestOutputDirectoryPermissionsIfRequired;



@end

NS_ASSUME_NONNULL_END
