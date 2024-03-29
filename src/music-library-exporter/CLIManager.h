//
//  CLIManager.h
//  music-library-exporter
//
//  Created by Kyle King on 2021-02-17.
//

#import <Foundation/Foundation.h>

#import "CLIDefines.h"
#import "ExportManagerDelegate.h"

@class ExportConfiguration;
@class PlaylistTreeNode;


NS_ASSUME_NONNULL_BEGIN

@interface CLIManager : NSObject<ExportManagerDelegate>

extern NSErrorDomain const __MLE_ErrorDomain_CLIManager;

typedef NS_ENUM(NSUInteger, CLIManagerErrorCode) {
  CLIManagerErrorUknown = 0,
  CLIManagerErrorInvalidOutputPath,
  CLIManagerErrorInvalidMusicMediaDirectory,
  CLIManagerErrorInvalidRemapping,
};


# pragma mark - Properties

@property (readonly) CLICommandKind command;

@property (nullable, readonly) ExportConfiguration* configuration;


#pragma mark - Initializers

- (instancetype)init;


#pragma mark - Accessors

- (void)printHelp;
- (void)printVersion;
- (void)printPlaylists;


#pragma mark - Mutators

- (BOOL)setupAndReturnError:(NSError**)error;

- (BOOL)exportLibraryAndReturnError:(NSError**)error;


@end

NS_ASSUME_NONNULL_END
