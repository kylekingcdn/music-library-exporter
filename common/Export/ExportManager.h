//
//  ExportManager.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import <Foundation/Foundation.h>

#import "Defines.h"
#import "ExportManagerDelegate.h"
#import "MediaItemSerializerDelegate.h"
#import "PlaylistSerializerDelegate.h"

@class ExportConfiguration;
@class OrderedDictionary;

NS_ASSUME_NONNULL_BEGIN

@interface ExportManager : NSObject <MediaItemSerializerDelegate,PlaylistSerializerDelegate>

extern NSErrorDomain const __MLE_ErrorDomain_ExportManager;

typedef NS_ENUM(NSInteger, ExportManagerErrorCode) {
  ExportManagerErrorMusicMediaLocationUnset,
  ExportManagerErrorOutputDirectoryInvalid,
  ExportManagerErrorRemappingInvalid,
  ExportManagerErrorBusyState,
  ExportManagerErrorUnitialized,
  ExportManagerErrorWriteError,
};

#pragma mark - Properties

@property (nullable, weak) NSObject<ExportManagerDelegate>* delegate;

@property (readonly) ExportState state;
@property (nullable,copy) NSURL* outputFileURL;


#pragma mark - Initializers

- (instancetype)initWithConfiguration:(ExportConfiguration*)configuration;


#pragma mark - Mutators

- (BOOL)exportLibraryWithError:(NSError**)error;


@end

NS_ASSUME_NONNULL_END
