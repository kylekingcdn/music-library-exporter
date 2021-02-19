//
//  ArgParser.h
//  library-generator
//
//  Created by Kyle King on 2021-02-15.
//

#import <Foundation/Foundation.h>

#import "LGDefines.h"
#import "Defines.h"


NS_ASSUME_NONNULL_BEGIN

@class XPMArgumentSignature;
@class ExportConfiguration;


@interface ArgParser : NSObject


#pragma mark - Properties

@property (readonly) NSProcessInfo* processInfo;

@property (readonly) LGCommandKind command;
@property (nullable, readonly) NSString* commandError;

@property (readonly) NSString* optionsError;
@property (nullable, readonly) NSArray<NSString*>* optionsWithErrors;


#pragma mark - Initializers

- (instancetype)initWithProcessInfo:(NSProcessInfo*)processInfo;

+ (instancetype)parserWithProcessInfo:(NSProcessInfo*)processInfo;


#pragma mark - Accessors

- (nullable XPMArgumentSignature*)signatureForCommand:(LGCommandKind)command;
- (nullable XPMArgumentSignature*)signatureForOption:(LGOptionKind)option;

- (NSSet<NSNumber*>*)determineCommandTypes;

- (void)dumpArguments;

+ (NSSet<NSNumber*>*)playlistIdsForIdsOption:(NSString*)playlistIdsOption;

+ (BOOL)parsePlaylistSortingOption:(NSString*)sortOption forColumnDict:(NSMutableDictionary*)sortColDict andOrderDict:(NSMutableDictionary*)sortOrderDict withError:(NSError**)error;
+ (BOOL)parsePlaylistSortingSegment:(NSString*)sortOption forColumnDict:(NSMutableDictionary*)sortColDict andOrderDict:(NSMutableDictionary*)sortOrderDict withError:(NSError**)error;
+ (BOOL)parsePlaylistSortingSegmentValue:(NSString*)sortOptionValue forColumn:(PlaylistSortColumnType*)sortColumn andOrder:(PlaylistSortOrderType*)sortOrder withError:(NSError**)error;

+ (PlaylistSortColumnType)sortColumnForOptionName:(NSString*)sortColumnOption;
+ (PlaylistSortOrderType)sortOrderForOptionName:(NSString*)sortOrderOption;


#pragma mark - Mutators

- (void)initMemberSignatures;

- (void)parse;

// TODO: change return type to NSError
- (BOOL)validateCommand;
- (BOOL)validateOptions;

// TODO: change return type to NSError
- (BOOL)populateExportConfiguration:(ExportConfiguration*)configuration;


@end

NS_ASSUME_NONNULL_END
