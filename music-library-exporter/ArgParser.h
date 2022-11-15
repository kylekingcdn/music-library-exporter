//
//  ArgParser.h
//  music-library-exporter
//
//  Created by Kyle King on 2021-02-15.
//

#import <Foundation/Foundation.h>

#import "CLIDefines.h"
#import "Defines.h"


NS_ASSUME_NONNULL_BEGIN

@class XPMArgumentSignature;
@class ExportConfiguration;


@interface ArgParser : NSObject

extern NSErrorDomain const __MLE_ErrorDomain_ArgParser;

typedef NS_ENUM(NSUInteger, ArgParserErrorCode) {
  ArgParserErrorUknown = 0,
  ArgParserErrorInvalidCommand,
  ArgParserErrorInvalidOption,
  ArgParserErrorMissingRequiredOption,
  ArgParserErrorMalformedPlaylistIdOption,
  ArgParserErrorMalformedSortingOptionFormat,
  ArgParserErrorUnknownSortColumn,
  ArgParserErrorUnknownSortOrder,
  ArgParserErrorAppPrefsPropertyListInvalid,
};


#pragma mark - Properties

@property (readonly) NSProcessInfo* processInfo;

@property (readonly) CLICommandKind command;


#pragma mark - Initializers

- (instancetype)init;
- (instancetype)initWithProcessInfo:(NSProcessInfo*)processInfo;


#pragma mark - Accessors

- (nullable XPMArgumentSignature*)signatureForCommand:(CLICommandKind)command;
- (nullable XPMArgumentSignature*)signatureForOption:(CLIOptionKind)option;

- (BOOL)isOptionSet:(CLIOptionKind)option;

- (NSSet<NSNumber*>*)determineCommandTypes;

- (BOOL)populateExportConfiguration:(ExportConfiguration*)configuration error:(NSError**)error;
- (BOOL)populateExportConfigurationFromAppPreferences:(ExportConfiguration*)configuration error:(NSError**)error;

- (void)dumpArguments;
- (void)dumpOptions;

- (BOOL)readPrefsEnabled;

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
