//
//  DirectoryBookmarkHandler.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DirectoryBookmarkHandler : NSObject

#pragma mark - Initializers

- (instancetype)init;
- (instancetype)initWithUserDefaultsKey:(NSString*)defaultsKey;

#pragma mark - Accessors

- (nullable NSData*)bookmarkDataFromDefaults;
- (nullable NSURL*)urlFromDefaultsAndReturnError:(NSError**)error;
- (nullable NSURL*)urlFromDefaultsWithFilename:(NSString*)filename andReturnError:(NSError**)error;

#pragma mark - Mutators

- (void)saveBookmarkDataToDefaults:(nullable NSData*)bookmarkData;
- (BOOL)saveURLToDefaults:(nullable NSURL*)url;

@end

NS_ASSUME_NONNULL_END
