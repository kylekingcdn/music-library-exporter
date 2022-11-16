//
//  DirectoryPermissionsWindowController.m
//  Music Library Exporter Helper
//
//  Created by Kyle King on 2021-02-13.
//

#import "DirectoryPermissionsWindowController.h"

#import "Logger.h"
#import "ExportConfiguration.h"
#import "ScheduleConfiguration.h"
#import "DirectoryBookmarkHandler.h"


@implementation DirectoryPermissionsWindowController {

  ExportConfiguration* _exportConfiguration;
  ScheduleConfiguration* _scheduleConfiguration;
}


#pragma mark - Initializers

- (instancetype)init {

  if (self = [super initWithWindowNibName:@"DirectoryPermissionsWindow"]) {

    _exportConfiguration = nil;
    _scheduleConfiguration = nil;

    return self;
  }
  else {
    return nil;
  }
}

- (instancetype)initWithExportConfiguration:(ExportConfiguration*)exportConfiguration
                   andScheduleConfiguration:(ScheduleConfiguration*)scheduleConfiguration {

  if (self = [self init]) {

    _exportConfiguration = exportConfiguration;
    _scheduleConfiguration = scheduleConfiguration;

    return self;
  }
  else {
    return nil;
  }
}

- (void)windowDidLoad {

  [super windowDidLoad];

  // Set activation policy to regular to allow for modal to pop up
  [self.window setLevel:NSFloatingWindowLevel];
  [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyRegular];
}

- (IBAction)chooseOutputDirectory:(id)sender {

  [self requestOutputDirectoryPermissions];
}

- (void)showIncorrectDirectoryAlert {

  NSAlert *alert = [[NSAlert alloc] init];
  [alert addButtonWithTitle:@"Ok"];
  [alert setMessageText:@"Incorrect output directory selected"];
  [alert setInformativeText:@"Please choose the same output directory that you selected in the Music Library Exporter main application."];
  [alert setAlertStyle:NSAlertStyleCritical];
  [alert runModal];

  [self requestOutputDirectoryPermissions];
}

- (void)showAutomaticExportsDisabledDirectoryAlert {

  NSAlert *alert = [[NSAlert alloc] init];
  [alert addButtonWithTitle:@"Ok"];
  [alert setMessageText:@"Automatic exports have been disabled. "];
  [alert setInformativeText:@"Automatic exports can be re-enabled from the Music Library Exporter main application."];
  [alert setAlertStyle:NSAlertStyleCritical];
  [alert runModal];

  [_scheduleConfiguration setNextExportAt:nil];
  [_scheduleConfiguration setScheduleEnabled:NO];
  [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyProhibited];

  [self close];
}

- (void)requestOutputDirectoryPermissions {

  MLE_Log_Info(@"DirectoryPermissionsWindowController [requestOutputDirectoryPermissions]");

  NSString* outputDirectoryPath = _exportConfiguration.outputDirectoryPath;

  NSOpenPanel* openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  [openPanel setAllowsMultipleSelection:NO];

  [openPanel setMessage:@"Please select the same output directory that you selected in the main application ."];
  if (outputDirectoryPath.length > 0) {
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:outputDirectoryPath]];
  }

  [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {

    if (result == NSModalResponseOK) {

      NSURL* outputDirectoryURL = [openPanel URL];

      if (outputDirectoryURL) {
        if (outputDirectoryPath.length == 0 || [outputDirectoryURL.path isEqualToString:outputDirectoryPath]) {
          MLE_Log_Info(@"DirectoryPermissionsWindowController [requestOutputDirectoryPermissions] the correct output directory has been selected");
          DirectoryBookmarkHandler* bookmarkHandler = [[DirectoryBookmarkHandler alloc] initWithUserDefaultsKey:OUTPUT_DIRECTORY_BOOKMARK_KEY];
          [bookmarkHandler saveURLToDefaults:outputDirectoryURL];
          [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyProhibited];
          return;
        }
        else {
          MLE_Log_Info(@"DirectoryPermissionsWindowController [requestOutputDirectoryPermissions] the user has selected a directory that differs from the output directory set with the main app.");
          [openPanel orderOut:nil];
          [self showIncorrectDirectoryAlert];
          return;
        }
      }
      else {
        MLE_Log_Info(@"DirectoryPermissionsWindowController [requestOutputDirectoryPermissions] the user has cancelled granting permissions. Automated exports will be disabled.");
        [openPanel orderOut:nil];
        [self showAutomaticExportsDisabledDirectoryAlert];
        return;
      }
    }
    else {
      MLE_Log_Info(@"DirectoryPermissionsWindowController [requestOutputDirectoryPermissions] the user has cancelled granting permissions. Automated exports will be disabled.");
      [openPanel orderOut:nil];
      [self showAutomaticExportsDisabledDirectoryAlert];
      return;
    }
  }];
}

@end
