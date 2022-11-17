//
//  DirectoryPermissionsWindowController.h
//  Music Library Exporter Helper
//
//  Created by Kyle King on 2021-02-13.
//

#import <Cocoa/Cocoa.h>

@class ExportConfiguration;
@class ScheduleConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface DirectoryPermissionsWindowController : NSWindowController


#pragma mark - Initializers

- (instancetype)init;
- (instancetype)initWithExportConfiguration:(ExportConfiguration*)exportConfiguration
                   andScheduleConfiguration:(ScheduleConfiguration*)scheduleConfiguration;


#pragma mark - Mutators

- (IBAction)chooseOutputDirectory:(id)sender;

- (void)showIncorrectDirectoryAlert;
- (void)showAutomaticExportsDisabledDirectoryAlert;

- (void)requestOutputDirectoryPermissions;

@end

NS_ASSUME_NONNULL_END
