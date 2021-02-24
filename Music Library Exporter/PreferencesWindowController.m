//
//  PreferencesWindowController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-24.
//

#import "PreferencesWindowController.h"

#import "Logger.h"
#import "Defines.h"


@interface PreferencesWindowController ()

@property (weak) IBOutlet NSButton* crashReportingCheckBox;

@end


@implementation PreferencesWindowController

- (void)windowDidLoad {

  [super windowDidLoad];

  BOOL crashReportingEnabled = [[[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier] boolForKey:@"CrashReporting"];

  [_crashReportingCheckBox setState:(crashReportingEnabled ? NSControlStateValueOn : NSControlStateValueOff)];
}

- (IBAction)setCrashReportingEnabled:(id)sender {

  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  MLE_Log_Info(@"PreferencesWindowController [setCrashReportingEnabled:%@]", (flag ? @"YES" : @"NO"));
  
  [[[NSUserDefaults alloc] initWithSuiteName:__MLE__AppGroupIdentifier] setBool:flag forKey:@"CrashReporting"];
}

@end
