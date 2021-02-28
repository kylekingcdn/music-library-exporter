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


#pragma mark - Initializers

- (instancetype)initWithProcessInfo:(NSProcessInfo*)processInfo;

+ (instancetype)parserWithProcessInfo:(NSProcessInfo*)processInfo;


#pragma mark - Accessors

- (nullable XPMArgumentSignature*)signatureForCommand:(LGCommandKind)command;
- (nullable XPMArgumentSignature*)signatureForOption:(LGOptionKind)option;

- (NSSet<NSNumber*>*)determineCommandTypes;

- (BOOL)populateExportConfiguration:(ExportConfiguration*)configuration error:(NSError**)error;
- (BOOL)populateExportConfigurationFromAppPreferences:(ExportConfiguration*)configuration error:(NSError**)error;

- (void)dumpArguments;

- (BOOL)verboseOutputEnabled;

+ (nullable NSSet<NSString*>*)playlistIdsForIdsOption:(NSString*)playlistIdsOption error:(NSError**)error;

+ (BOOL)parsePlaylistSortingOption:(NSString*)sortOption forColumnDict:(NSMutableDictionary*)sortColDict andOrderDict:(NSMutableDictionary*)sortOrderDict andReturnError:(NSError**)error;
+ (BOOL)parsePlaylistSortingSegment:(NSString*)sortOption forColumnDict:(NSMutableDictionary*)sortColDict andOrderDict:(NSMutableDictionary*)sortOrderDict andReturnError:(NSError**)error;
+ (BOOL)parsePlaylistSortingSegmentValue:(NSString*)sortOptionValue forColumn:(PlaylistSortColumnType*)sortColumn andOrder:(PlaylistSortOrderType*)sortOrder andReturnError:(NSError**)error;

+ (PlaylistSortColumnType)sortColumnForOptionName:(NSString*)sortColumnOption;
+ (PlaylistSortOrderType)sortOrderForOptionName:(NSString*)sortOrderOption;


#pragma mark - Mutators

- (void)initMemberSignatures;

- (void)parse;

- (BOOL)validateCommandAndReturnError:(NSError**)error;
- (BOOL)validateOptionsAndReturnError:(NSError**)error;


@end

NS_ASSUME_NONNULL_END
