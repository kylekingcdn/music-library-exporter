//
//  AppDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-01-25.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {

  BOOL _scheduleEnabled;
}


@property (assign) IBOutlet NSSegmentedControl *launchAtLoginButton;


-(NSString*)errorForSchedulerRegistration:(BOOL)registerFlag;

-(BOOL)isScheduled;
-(void)setScheduleEnabled:(BOOL)flag;

-(BOOL)registerSchedulerWithSystem:(BOOL)flag;

-(IBAction)toggleScheduler:(id)sender;

@end

