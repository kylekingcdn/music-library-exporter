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

@property (nullable, weak) NSObject<ExportManagerDelegate>* delegate;
@property (readonly) ExportState state;
@property NSURL* outputFileURL;

- (instancetype)initWithConfiguration:(ExportConfiguration*)configuration;

- (BOOL)exportLibrary;
- (BOOL)writeLibrary:(OrderedDictionary*)libraryDict error:(NSError**)error;


@end

NS_ASSUME_NONNULL_END
