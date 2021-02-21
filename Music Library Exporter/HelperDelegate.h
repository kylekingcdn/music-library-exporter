//
//  HelperDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface HelperDelegate : NSObject


#pragma mark - Initializers

- (instancetype)init;


#pragma mark - Accessors

- (BOOL)isHelperRegisteredWithSystem;
- (NSString*)errorForHelperRegistration:(BOOL)registerFlag;


#pragma mark - Mutators

- (BOOL)registerHelperWithSystem:(BOOL)flag;
- (void)updateHelperRegistrationWithScheduleEnabled:(BOOL)scheduleEnabled;


@end

NS_ASSUME_NONNULL_END
