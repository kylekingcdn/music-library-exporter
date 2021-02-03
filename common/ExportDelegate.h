//
//  ExportDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-03.
//

#import <Foundation/Foundation.h>

@class UserDefaultsExportConfiguration;


NS_ASSUME_NONNULL_BEGIN

@interface ExportDelegate : NSObject


#pragma mark - Properties -

@property UserDefaultsExportConfiguration* configuration;


#pragma mark - Initializers -

- (instancetype)init;

- (instancetype)initWithConfiguration:(UserDefaultsExportConfiguration*)config;


#pragma mark - Accessors -

- (nullable NSDate*)lastExportedAt;

- (void)dumpProperties;


#pragma mark - Mutators -

- (void)loadPropertiesFromUserDefaults;

- (void)setLastExportedAt:(nullable NSDate*)timestamp;

- (BOOL)exportLibrary;


@end

NS_ASSUME_NONNULL_END
