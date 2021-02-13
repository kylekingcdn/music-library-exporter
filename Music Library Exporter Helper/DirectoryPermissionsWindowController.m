//
//  DirectoryPermissionsWindowController.m
//  Music Library Exporter Helper
//
//  Created by Kyle King on 2021-02-13.
//

#import "DirectoryPermissionsWindowController.h"

#import "UserDefaultsExportConfiguration.h"
#import "ScheduleConfiguration.h"

@interface DirectoryPermissionsWindowController ()

@end


@implementation DirectoryPermissionsWindowController

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

  [[ScheduleConfiguration sharedConfig] setNextExportAt:nil];
  [[ScheduleConfiguration sharedConfig] setScheduleEnabled:NO];
  [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyProhibited];

  [self close];
}

- (void)requestOutputDirectoryPermissions {

  NSLog(@"DirectoryPermissionsWindowController [requestOutputDirectoryPermissions]");

  NSString* outputDirPath = UserDefaultsExportConfiguration.sharedConfig.outputDirectoryPath;

  NSOpenPanel* openPanel = [NSOpenPanel openPanel];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setCanChooseFiles:NO];
  [openPanel setAllowsMultipleSelection:NO];

  [openPanel setMessage:@"Please select the same output directory that you selected in the main application ."];
  if (outputDirPath.length > 0) {
    [openPanel setDirectoryURL:[NSURL fileURLWithPath:outputDirPath]];
  }

  [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {

    if (result == NSModalResponseOK) {

      NSURL* outputDirUrl = [openPanel URL];

      if (outputDirUrl) {
        if (outputDirPath.length == 0 || [outputDirUrl.path isEqualToString:outputDirPath]) {
          NSLog(@"DirectoryPermissionsWindowController [requestOutputDirectoryPermissions] the correct output directory has been selected");
          [UserDefaultsExportConfiguration.sharedConfig setOutputDirectoryUrl:outputDirUrl];
          [[NSApplication sharedApplication] setActivationPolicy:NSApplicationActivationPolicyProhibited];
          return;
        }
        else {
          NSLog(@"DirectoryPermissionsWindowController [requestOutputDirectoryPermissions] the user has selected a directory that differs from the output directory set with the main app.");
          [openPanel orderOut:nil];
          [self showIncorrectDirectoryAlert];
          return;
        }
      }
      else {
        NSLog(@"DirectoryPermissionsWindowController [requestOutputDirectoryPermissions] the user has cancelled granting permissions. Automated exports will be disabled.");
        [openPanel orderOut:nil];
        [self showAutomaticExportsDisabledDirectoryAlert];
        return;
      }
    }
    else {
      NSLog(@"DirectoryPermissionsWindowController [requestOutputDirectoryPermissions] the user has cancelled granting permissions. Automated exports will be disabled.");
      [openPanel orderOut:nil];
      [self showAutomaticExportsDisabledDirectoryAlert];
      return;
    }
  }];
}

@end
