//
//  PreferencesWindowController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-24.
//

#import "PreferencesWindowController.h"

#import "Logger.h"

#if SENTRY_ENABLED == 1
#import "MLESentryHandler.h"
#endif


@interface PreferencesWindowController ()

@property (weak) IBOutlet NSButton* crashReportingCheckBox;

@end


@implementation PreferencesWindowController

- (void)windowDidLoad {

  [super windowDidLoad];

  BOOL sentryEnabled = NO;
  BOOL crashReportingEnabled = NO;

#if SENTRY_ENABLED == 1
  sentryEnabled = YES;
  crashReportingEnabled = [[MLESentryHandler sharedSentryHandler] userHasEnabledCrashReporting];
#endif

  [_crashReportingCheckBox setEnabled:sentryEnabled];
  [_crashReportingCheckBox setState:(crashReportingEnabled ? NSControlStateValueOn : NSControlStateValueOff)];
}

- (IBAction)setCrashReportingEnabled:(id)sender {

#if SENTRY_ENABLED == 1
  NSControlStateValue flagState = [sender state];
  BOOL flag = (flagState == NSControlStateValueOn);

  MLE_Log_Info(@"PreferencesWindowController [setCrashReportingEnabled:%@]", (flag ? @"YES" : @"NO"));

  [MLESentryHandler setCrashReportingEnabled:flag];
#endif
}

@end
