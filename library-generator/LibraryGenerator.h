//
//  LibraryGenerator.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-17.
//

#import <Foundation/Foundation.h>

#import "LGDefines.h"

@class ExportConfiguration;


NS_ASSUME_NONNULL_BEGIN

@interface LibraryGenerator : NSObject


# pragma mark - Properties

@property (readonly) LGCommandKind command;

@property (nullable, readonly) ExportConfiguration* configuration;


#pragma mark - Initializers

- (instancetype)init;


#pragma mark - Accessors

- (BOOL)isRunningInTerminal;

- (void)printHelp;
- (void)printPlaylists;


#pragma mark - Mutators

- (BOOL)setupAndReturnError:(NSError**)error;

- (BOOL)exportLibraryAndReturnError:(NSError**)error;


@end

NS_ASSUME_NONNULL_END
