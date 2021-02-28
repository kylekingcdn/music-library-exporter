//
//  ArgParser.m
//  library-generator
//
//  Created by Kyle King on 2021-02-15.
//

#import "ArgParser.h"

#import "Logger.h"
#import "Utils.h"
#import "XPMArguments.h"
#import "ExportConfiguration.h"


@implementation ArgParser {

  NSDictionary* _commandSignatures;
  NSDictionary* _optionSignatures;

  XPMArgumentPackage* _package;
}


#pragma mark - Initializers

- (instancetype)initWithProcessInfo:(NSProcessInfo*)processInfo {

  self = [super init];

  _processInfo = processInfo;

  [self initMemberSignatures];

  return self;
}

+ (instancetype)parserWithProcessInfo:(NSProcessInfo*)processInfo {

  ArgParser* parser = [[ArgParser alloc] initWithProcessInfo:processInfo];

  return parser;
}


#pragma mark - Accessors

- (nullable XPMArgumentSignature*)signatureForCommand:(LGCommandKind)command {

  return [_commandSignatures objectForKey:@(command)];
}

- (nullable XPMArgumentSignature*)signatureForOption:(LGOptionKind)option {

  return [_optionSignatures objectForKey:@(option)];
}

- (NSSet<NSNumber*>*)determineCommandTypes {

  NSMutableSet<NSNumber*>* commmandTypes = [NSMutableSet set];

  for (LGCommandKind command = LGCommandKindHelp; command < LGCommandKindUnknown; command++) {

    XPMArgumentSignature* commandSig = [self signatureForCommand:command];

    BOOL isCurrentCommandType = [_package booleanValueForSignature:commandSig];

    if (isCurrentCommandType) {
      if (command == LGCommandKindHelp) {
        return [NSSet setWithObject:@(command)];
      }
      else {
        [commmandTypes addObject:@(command)];
      }
    }
  }

  return commmandTypes;
}

- (BOOL)verboseOutputEnabled {

  XPMArgumentSignature* verboseSignature = [self signatureForOption:LGOptionKindVerbose];
  if (verboseSignature == nil) {
    return NO;
  }

  return [_package booleanValueForSignature:verboseSignature];
}

- (BOOL)readPrefsEnabled {

  XPMArgumentSignature* readPrefsSignature = [self signatureForOption:LGOptionKindReadPrefs];
  if (readPrefsSignature == nil) {
    return NO;
  }

  return [_package booleanValueForSignature:readPrefsSignature];
}

- (BOOL)populateExportConfiguration:(ExportConfiguration*)configuration error:(NSError**)error {

  // populate config from app prefs
  if ([self readPrefsEnabled]) {
    return [self populateExportConfigurationFromAppPreferences:configuration error:error];
  }

  [configuration setFlattenPlaylistHierarchy:[_package booleanValueForSignature:[self signatureForOption:LGOptionKindFlatten]]];

  [configuration setIncludeInternalPlaylists:![_package booleanValueForSignature:[self signatureForOption:LGOptionKindExcludeInternal]]];

  NSString* musicMediaDir = [_package firstObjectForSignature:[self signatureForOption:LGOptionKindMusicMediaDirectory]];
  if (musicMediaDir) {
    [configuration setMusicLibraryPath:musicMediaDir];
  }
  NSString* excludedIdsStr = [_package firstObjectForSignature:[self signatureForOption:LGOptionKindExcludeIds]];
  if (excludedIdsStr) {
    NSSet<NSString*>* excludedIds = [ArgParser playlistIdsForIdsOption:excludedIdsStr error:error];
    if (excludedIds == nil) {
      return NO;
    }
    [configuration setExcludedPlaylistPersistentIds:excludedIds];
  }

  NSString* playlistSortingOpt = [_package firstObjectForSignature:[self signatureForOption:LGOptionKindSort]];
  if (playlistSortingOpt) {

    NSMutableDictionary* sortColumnDict = [NSMutableDictionary dictionary];
    NSMutableDictionary* sortOrderDict = [NSMutableDictionary dictionary];
    BOOL sortingOptionParsed = [ArgParser parsePlaylistSortingOption:playlistSortingOpt forColumnDict:sortColumnDict andOrderDict:sortOrderDict andReturnError:error];
    if (!sortingOptionParsed) {
      return NO;
    }

    [configuration setCustomSortColumnDict:sortColumnDict];
    [configuration setCustomSortOrderDict:sortOrderDict];
  }

  NSString* remapSearch = [_package firstObjectForSignature:[self signatureForOption:LGOptionKindRemapSearch]];
  NSString* remapReplace = [_package firstObjectForSignature:[self signatureForOption:LGOptionKindRemapReplace]];
  BOOL hasRemapping = (remapSearch || remapReplace);

  [configuration setRemapRootDirectory:hasRemapping];
  if (remapSearch) {
    [configuration setRemapRootDirectoryOriginalPath:remapSearch];
  }
  if (remapReplace) {
    [configuration setRemapRootDirectoryMappedPath:remapReplace];
  }

  NSString* outputFilePath = [_package firstObjectForSignature:[self signatureForOption:LGOptionKindOutputPath]];
  if (outputFilePath) {
    NSURL* fileUrl = [NSURL fileURLWithPath:outputFilePath];

    NSString* fileName = [fileUrl lastPathComponent];
    NSURL* fileDirUrl = [fileUrl URLByDeletingLastPathComponent];

    [configuration setOutputFileName:fileName];
    [configuration setOutputDirectoryUrl:fileDirUrl];
    [configuration setOutputDirectoryPath:fileDirUrl.path];
  }

  return YES;
}

- (BOOL)populateExportConfigurationFromAppPreferences:(ExportConfiguration*)configuration error:(NSError**)error {

  NSURL* prefsPlistUrl = [LGDefines fileUrlForAppPreferences];
  NSString* prefsPlistPath = prefsPlistUrl.path;

  if (![[NSFileManager defaultManager] fileExistsAtPath:prefsPlistPath]) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorAppPrefsPropertyListInvalid userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"App preferences property list not found at expected path: %@", prefsPlistPath],
      }];
    }
    return NO;
  }

  if (![[NSFileManager defaultManager] isReadableFileAtPath:prefsPlistPath]) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorAppPrefsPropertyListInvalid userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"App preferences property not readable at expected path: %@", prefsPlistPath],
      }];
    }
    return NO;
  }

  NSDictionary* prefsPlistDict = [NSDictionary dictionaryWithContentsOfURL:prefsPlistUrl error:error];
  if (prefsPlistDict == nil) {
    return NO;
  }

  [configuration loadValuesFromDictionary:prefsPlistDict];

  return YES;
}

- (void)dumpArguments {

  if (_processInfo) {
    MLE_Log_Info(@"ArgParser [dumpArguments]: %@", NSProcessInfo.processInfo.arguments);
  }
}

+ (NSSet<NSString*>*)playlistIdsForIdsOption:(NSString*)playlistIdsOption error:(NSError**)error{

  return [NSSet setWithArray:[playlistIdsOption componentsSeparatedByString:@","]];

}

+ (BOOL)parsePlaylistSortingOption:(NSString*)sortOptions forColumnDict:(NSMutableDictionary*)sortColDict andOrderDict:(NSMutableDictionary*)sortOrderDict andReturnError:(NSError**)error {

//  MLE_Log_Info(@"ArgParser [parsePlaylistSortingOption:%@]", sortOptions);

  // each will be in form of {id}:{sort_col}-{sort_order}
  NSArray<NSString*>* playlistSortingStrings = [sortOptions componentsSeparatedByString:@","];

  for (NSString* sortOption in playlistSortingStrings) {

    if (![ArgParser parsePlaylistSortingSegment:sortOption forColumnDict:sortColDict andOrderDict:sortOrderDict andReturnError:error]) {
      return NO;
    }
  }

  return YES;
}

+ (BOOL)parsePlaylistSortingSegment:(NSString*)sortOption forColumnDict:(NSMutableDictionary*)sortColDict andOrderDict:(NSMutableDictionary*)sortOrderDict andReturnError:(NSError**)error {

//  MLE_Log_Info(@"ArgParser [parsePlaylistSortingSegment:%@]", sortOption);

  // part 1 will be {id}, part 2 will be {sort_col}-{sort_order}
  NSArray<NSString*>* sortOptionParts = [sortOption componentsSeparatedByString:@":"];
  if (sortOptionParts.count != 2) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorMalformedSortingOptionFormat userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid sorting option format: %@", sortOption],
      }];
    }
    return NO;
  }

  // part 1 will be {sort_col}, part 2 will be {sort_order}
  NSString* playlistId = sortOptionParts.firstObject;
  NSString* playlistSortValuesStr = sortOptionParts.lastObject;

  PlaylistSortColumnType sortColumn = PlaylistSortColumnNull;
  PlaylistSortOrderType sortOrder = PlaylistSortOrderNull;
  BOOL valueParsed = [ArgParser parsePlaylistSortingSegmentValue:playlistSortValuesStr forColumn:&sortColumn andOrder:&sortOrder andReturnError:error];
  if (!valueParsed) {
    return NO;
  }

  [sortColDict setValue:[Utils titleForPlaylistSortColumn:sortColumn] forKey:playlistId];
  [sortOrderDict setValue:[Utils titleForPlaylistSortOrder:sortOrder] forKey:playlistId];

  return YES;
}

+ (BOOL)parsePlaylistSortingSegmentValue:(NSString*)sortOptionValue forColumn:(PlaylistSortColumnType*)aSortColumn andOrder:(PlaylistSortOrderType*)aSortOrder andReturnError:(NSError**)error {

//  MLE_Log_Info(@"ArgParser [parsePlaylistSortingSegmentValue:%@]", sortOptionValue);

  NSArray<NSString*>* sortOptionValueParts = [sortOptionValue componentsSeparatedByString:@"-"];

  if (sortOptionValueParts.count != 2) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorMalformedSortingOptionFormat userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid sorting option format: %@", sortOptionValue],
      }];
    }
    return NO;
  }

  NSString* sortColStr = sortOptionValueParts.firstObject;
  PlaylistSortColumnType sortCol = [ArgParser sortColumnForOptionName:sortColStr];

  if (sortCol == PlaylistSortColumnNull) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorUnknownSortColumn userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unknown sort column specifier: %@", sortColStr],
      }];
    }
    return NO;
  }

  NSString* sortOrderStr = sortOptionValueParts.lastObject;
  PlaylistSortOrderType sortOrder = [ArgParser sortOrderForOptionName:sortOrderStr];

  if (sortOrder == PlaylistSortOrderNull) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorUnknownSortOrder userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unknown sort order specifier: %@", sortOrderStr],
      }];
    }
    return NO;
  }

  *aSortColumn = sortCol;
  *aSortOrder = sortOrder;

  return YES;
}

+ (PlaylistSortColumnType)sortColumnForOptionName:(NSString*)sortColumnOption {

  if ([sortColumnOption isEqualToString:@"title" ]) {
    return PlaylistSortColumnTitle;
  }
  else if ([sortColumnOption isEqualToString:@"artist" ]) {
    return PlaylistSortColumnArtist;
  }
  else if ([sortColumnOption isEqualToString:@"albumartist" ]) {
    return PlaylistSortColumnAlbumArtist;
  }
  else if ([sortColumnOption isEqualToString:@"dateadded" ]) {
    return PlaylistSortColumnDateAdded;
  }

  return PlaylistSortColumnNull;
}

+ (PlaylistSortOrderType)sortOrderForOptionName:(NSString*)sortOrderOption {

  if ([sortOrderOption isEqualToString:@"d"]) {
    return PlaylistSortOrderDescending;
  }
  else if ([sortOrderOption isEqualToString:@"a"]) {
    return PlaylistSortOrderAscending;
  }

  return PlaylistSortOrderNull;
}


#pragma mark - Mutators

- (void)initMemberSignatures {

  MLE_Log_Info(@"ArgParser [initMemberSignatures]");

  NSMutableDictionary* commandSignatures = [NSMutableDictionary dictionary];
  NSMutableDictionary* optionSignatures = [NSMutableDictionary dictionary];

  // add help signature to both
  XPMArgumentSignature* helpSignature = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForCommand:LGCommandKindHelp]];
  [commandSignatures setObject:helpSignature forKey:@(LGCommandKindHelp)];
  [optionSignatures setObject:helpSignature forKey:@(LGOptionKindHelp)];

  // init command signatures dict
  for (LGCommandKind command = LGCommandKindHelp + 1; command < LGCommandKindUnknown; command++) {

    NSString* signatureFormat = [LGDefines signatureFormatForCommand:command];
    XPMArgumentSignature* commandSignature = [XPMArgumentSignature argumentSignatureWithFormat:signatureFormat];
    [commandSignatures setObject:commandSignature forKey:@(command)];
  }

  // init option signatures dict
  for (LGOptionKind option = LGOptionKindHelp + 1; option < LGOptionKind_MAX; option++) {

    NSString* signatureFormat = [LGDefines signatureFormatForOption:option];
    XPMArgumentSignature* optionSignature = [XPMArgumentSignature argumentSignatureWithFormat:signatureFormat];
    [optionSignatures setObject:optionSignature forKey:@(option)];
  }

  _commandSignatures = commandSignatures;
  _optionSignatures = optionSignatures;
}

- (void)parse {

  MLE_Log_Info(@"ArgParser [parse]");

  NSMutableSet* commandSigs = [NSMutableSet set];

  for (LGCommandKind command = LGCommandKindHelp; command < LGCommandKindUnknown; command++) {

    XPMArgumentSignature* commandSig = [self signatureForCommand:command];

    NSMutableSet* commandOptions = [NSMutableSet set];
    NSArray<NSNumber*>* validOptionTypes = [LGDefines optionsForCommand:command];

    // add each possible option to the command
    for (NSNumber* optionType in validOptionTypes) {
      [commandOptions addObject:[self signatureForOption:[optionType integerValue]]];
    }

    [commandSig setInjectedSignatures:commandOptions];
    [commandSigs addObject:commandSig];
  }

  _package = [_processInfo xpmargs_parseArgumentsWithSignatures:commandSigs];
}

- (BOOL)validateCommandAndReturnError:(NSError**)error {

  MLE_Log_Info(@"ArgParser [validateCommandAndReturnError]");

  NSSet<NSNumber*>* commandTypes = [self determineCommandTypes];

  // no command found
  if (commandTypes.count == 0) {

    // interpret running the program with no arguments and no options as a help command
    if (_processInfo.arguments.count <= 1) {
      _command = LGCommandKindHelp;
      return YES;
    }
    else {
      if (error) {
        *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorInvalidCommand userInfo:@{
          NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unknown command\nValid commands:  %@", [LGDefines.commandNames componentsJoinedByString:@", "]],
        }];
      }
      _command = LGCommandKindUnknown;
      return NO;
    }
  }

  // help command, this returns valid even if more commands are entered as help messages get priority
  if ([commandTypes containsObject:@(LGCommandKindHelp)]) {
    _command = LGCommandKindHelp;
    return YES;
  }

  // multiple commands entered
  if (commandTypes.count > 1) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorInvalidCommand userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Only one command may be specified at a time"],
      }];
    }
    _command = LGCommandKindUnknown;
    return NO;
  }

  // command issued is valid
  _command = [commandTypes.anyObject integerValue];
  MLE_Log_Info(@"ArgParser [validateCommandAndReturnError] identified valid command: %@", [LGDefines nameForCommand:_command]);

  return YES;
}

- (BOOL)validateOptionsAndReturnError:(NSError**)error; {

  MLE_Log_Info(@"ArgParser [validateOptionsAndReturnError]");

  NSAssert(_command != LGCommandKindUnknown, @"validateOptionsAndReturnError called without valid command");

  if (_package.unknownSwitches.count > 0) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorInvalidOption userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unrecognized option(s): %@", [_package.unknownSwitches componentsJoinedByString:@", "]],
      }];
    }
    return NO;
  }

  if (_package.uncapturedValues.count > 1) {
    NSMutableArray* trulyUncaptured = [_package.uncapturedValues mutableCopy];
    [trulyUncaptured removeObjectAtIndex:0];
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorInvalidCommand userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unexpected argument(s): %@", [trulyUncaptured componentsJoinedByString:@", "]],
      }];
    }
    return NO;
  }

  NSArray<NSNumber*>* requiredOptions = [LGDefines requiredOptionsForCommand:_command];
  NSMutableArray* requiredOptionsMissing = [NSMutableArray array];
  NSMutableArray* requiredOptionsMissingNames = [NSMutableArray array];

  // validate required options have been specified
  for (NSNumber* optionType in requiredOptions) {

    LGOptionKind option = [optionType integerValue];
    XPMArgumentSignature* sig = [self signatureForOption:option];
    NSUInteger sigCount = [_package countOfSignature:sig];
    if (sigCount == 0) {
      MLE_Log_Info(@"ArgParser [validateOptionsAndReturnError] missing required option: %@", [LGDefines nameForOption:option]);
      [requiredOptionsMissing addObject:sig];
      [requiredOptionsMissingNames addObject:[LGDefines nameAndValueForOption:option]];
    }
  }
  if (requiredOptionsMissing.count > 0) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorMissingRequiredOption userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Required options are incomplete:  %@", [requiredOptionsMissingNames componentsJoinedByString:@", "]],
      }];
    }
    return NO;
  }

  MLE_Log_Info(@"ArgParser [validateOptionsAndReturnError] options seem valid");

  return YES;
}



@end
