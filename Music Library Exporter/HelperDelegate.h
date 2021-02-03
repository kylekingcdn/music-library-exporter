//
//  HelperDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import <Foundation/Foundation.h>

@class ScheduleConfiguration;


NS_ASSUME_NONNULL_BEGIN

@interface HelperDelegate : NSObject


#pragma mark - Properties -

@property ScheduleConfiguration* configuration;


#pragma mark - Initializers -

- (instancetype)initWithConfiguration:(ScheduleConfiguration*)config;


#pragma mark - Accessors -

- (BOOL)isHelperRegisteredWithSystem;
- (NSString*)errorForHelperRegistration:(BOOL)registerFlag;


#pragma mark - Mutators -

- (BOOL)registerHelperWithSystem:(BOOL)flag;
- (void)updateHelperRegistrationIfRequired;


@end

NS_ASSUME_NONNULL_END
