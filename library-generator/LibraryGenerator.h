//
//  LibraryGenerator.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-17.
//

#import <Foundation/Foundation.h>

#import "LGDefines.h"


NS_ASSUME_NONNULL_BEGIN

@interface LibraryGenerator : NSObject


#pragma mark - Initializers

- (instancetype)init;


#pragma mark - Accessors

- (void)printHelp;


#pragma mark - Mutators

- (void)run;
- (nullable NSError*)setup;
- (nullable NSError*)execute;

- (nullable NSError*)setupPostValidationMembers;

- (nullable NSError*)handleCommand;
- (nullable NSError*)handleExportCommand;
- (void)handlePrintCommand;

@end

NS_ASSUME_NONNULL_END
