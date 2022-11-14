//
//  PreferencesWindowController.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-24.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreferencesWindowController : NSWindowController


#pragma mark - Initializers

- (instancetype)init;


#pragma mark - Mutators

- (IBAction)setCrashReportingEnabled:(id)sender;

@end

NS_ASSUME_NONNULL_END
