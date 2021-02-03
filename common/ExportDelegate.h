//
//  ExportDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-03.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UserDefaultsExportConfiguration;
@class LibrarySerializer;


@interface ExportDelegate : NSObject {

  NSDate* _lastExportedAt;

  LibrarySerializer* _librarySerializer;
}


@property UserDefaultsExportConfiguration* configuration;


#pragma mark - Initializers -

- (instancetype)init;

- (instancetype)initWithConfiguration:(UserDefaultsExportConfiguration*)exportConfig;


#pragma mark - Accessors -

- (nullable NSDate*)lastExportedAt;

- (void)dumpProperties;


#pragma mark - Mutators -

- (void)loadPropertiesFromUserDefaults;

- (void)setLastExportedAt:(nullable NSDate*)timestamp;

- (BOOL)exportLibrary;


@end

NS_ASSUME_NONNULL_END
