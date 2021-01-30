//
//  ConfigurationViewController.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-29.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConfigurationViewController : NSViewController {

  BOOL _scheduleEnabled;
  IBOutlet NSButton *scheduleEnabledCheckBox;
}

- (id)init;

- (BOOL)isScheduleRegisteredWithSystem;
- (BOOL)registerSchedulerWithSystem:(BOOL)flag;

- (IBAction)setScheduleEnabled:(id)sender;
- (NSString*)errorForSchedulerRegistration:(BOOL)registerFlag;

@end

NS_ASSUME_NONNULL_END
