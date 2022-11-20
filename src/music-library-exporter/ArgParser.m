//
//  ArgParser.m
//  music-library-exporter
//
//  Created by Kyle King on 2021-02-15.
//

#import "ArgParser.h"

#import <iTunesLibrary/ITLibMediaItem.h>

#import "Logger.h"
#import "XPMArguments.h"
#import "ExportConfiguration.h"


@implementation ArgParser {

  NSDictionary* _commandSignatures;
  NSDictionary* _optionSignatures;

  XPMArgumentPackage* _package;
}

NSErrorDomain const __MLE_ErrorDomain_ArgParser = @"com.kylekingcdn.MusicLibraryExporter.ArgParserErrorDomain";


#pragma mark - Initializers

- (instancetype)init {

  if (self = [super init]) {

    [self initMemberSignatures];

    _package = nil;

    return self;
  }
  else {
    return nil;
  }
}

- (instancetype)initWithProcessInfo:(NSProcessInfo*)processInfo {

  if (self = [self init]) {

    _processInfo = processInfo;

    return self;
  }
  else {
    return nil;
  }
}


#pragma mark - Accessors

- (nullable XPMArgumentSignature*)signatureForCommand:(CLICommandKind)command {

  return [_commandSignatures objectForKey:@(command)];
}

- (nullable XPMArgumentSignature*)signatureForOption:(CLIOptionKind)option {

  return [_optionSignatures objectForKey:@(option)];
}

- (BOOL)isOptionSet:(CLIOptionKind)option {

  if (option == CLIOptionKind_MAX) {
    return NO;
  }

  XPMArgumentSignature* signature = [self signatureForOption:option];
  NSUInteger signatureCount = [_package countOfSignature:signature];

  return (signatureCount != NSNotFound && signatureCount > 0);
}

- (NSSet<NSNumber*>*)determineCommandTypes {

  NSMutableSet<NSNumber*>* commmandTypes = [NSMutableSet set];

  for (CLICommandKind command = CLICommandKindHelp; command < CLICommandKindUnknown; command++) {

    XPMArgumentSignature* commandSig = [self signatureForCommand:command];

    BOOL isCurrentCommandType = [_package booleanValueForSignature:commandSig];

    if (isCurrentCommandType) {
      if (command == CLICommandKindHelp) {
        return [NSSet setWithObject:@(command)];
      }
      else {
        [commmandTypes addObject:@(command)];
      }
    }
  }

  return commmandTypes;
}

- (BOOL)readPrefsEnabled {

  XPMArgumentSignature* readPrefsSignature = [self signatureForOption:CLIOptionKindReadPrefs];
  if (readPrefsSignature == nil) {
    return NO;
  }

  return [_package booleanValueForSignature:readPrefsSignature];
}

- (BOOL)populateExportConfiguration:(ExportConfiguration*)configuration error:(NSError**)error {

  // populate config from app prefs
  if ([self readPrefsEnabled]) {

    [self populateExportConfigurationFromAppPreferences:configuration error:error];
  }

  // generate new persistent library id if not set
  if (configuration.generatedPersistentLibraryId == nil) {
    [configuration setGeneratedPersistentLibraryId:[ExportConfiguration generatePersistentLibraryId]];
  }

  // --flatten
  if ([self isOptionSet:CLIOptionKindFlatten]) {

    [configuration setFlattenPlaylistHierarchy:[_package booleanValueForSignature:[self signatureForOption:CLIOptionKindFlatten]]];
  }

  // --exclude_internal
  if ([self isOptionSet:CLIOptionKindExcludeInternal]) {

    [configuration setIncludeInternalPlaylists:![_package booleanValueForSignature:[self signatureForOption:CLIOptionKindExcludeInternal]]];
  }

  // --exclude_ids
  if ([self isOptionSet:CLIOptionKindExcludeIds]) {

    NSString* excludedIdsStr = [_package firstObjectForSignature:[self signatureForOption:CLIOptionKindExcludeIds]];

    if (excludedIdsStr) {

      NSSet<NSString*>* excludedIds = [ArgParser playlistIdsForIdsOption:excludedIdsStr error:error];
      if (excludedIds == nil) {
        return NO;
      }

      [configuration setExcludedPlaylistPersistentIds:excludedIds];
    }
  }

  // --music_media_dir
  if ([self isOptionSet:CLIOptionKindMusicMediaDirectory]) {

    NSString* musicMediaDir = [_package firstObjectForSignature:[self signatureForOption:CLIOptionKindMusicMediaDirectory]];

    if (musicMediaDir) {
      [configuration setMusicLibraryPath:musicMediaDir];
    }
  }

  // --sort
  if ([self isOptionSet:CLIOptionKindSort]) {

    NSString* playlistSortingOpt = [_package firstObjectForSignature:[self signatureForOption:CLIOptionKindSort]];
    if (playlistSortingOpt) {

      NSMutableDictionary* sortPropertyDict = [NSMutableDictionary dictionary];
      NSMutableDictionary* sortOrderDict = [NSMutableDictionary dictionary];
      BOOL sortingOptionParsed = [ArgParser parsePlaylistSortingOption:playlistSortingOpt forPropertyDict:sortPropertyDict andOrderDict:sortOrderDict andReturnError:error];

      if (!sortingOptionParsed) {
        return NO;
      }

      [configuration setCustomSortPropertyDict:sortPropertyDict];
      [configuration setCustomSortOrderDict:sortOrderDict];
    }
  }

  // --remap-*
  if ([self isOptionSet:CLIOptionKindRemapSearch] || [self isOptionSet:CLIOptionKindRemapReplace]) {

    [configuration setRemapRootDirectory:YES];

    NSString* remapSearch = [_package firstObjectForSignature:[self signatureForOption:CLIOptionKindRemapSearch]];
    NSString* remapReplace = [_package firstObjectForSignature:[self signatureForOption:CLIOptionKindRemapReplace]];

    if (remapSearch) {
      [configuration setRemapRootDirectoryOriginalPath:remapSearch];
    }

    if (remapReplace) {
      [configuration setRemapRootDirectoryMappedPath:remapReplace];
    }
  }

  // --localhost_path_prefix
  if ([self isOptionSet:CLIOptionKindRemapLocalhostPrefix]) {
    BOOL remapLocalhostPrefix = [_package booleanValueForSignature:[self signatureForOption:CLIOptionKindRemapLocalhostPrefix]];
    [configuration setRemapRootDirectoryLocalhostPrefix:remapLocalhostPrefix];
  }

  // --output_path
  if ([self isOptionSet:CLIOptionKindOutputPath]) {

    NSString* outputFilePath = [_package firstObjectForSignature:[self signatureForOption:CLIOptionKindOutputPath]];

    if (outputFilePath) {

      NSURL* fileUrl = [NSURL fileURLWithPath:outputFilePath];
      NSString* fileName = [fileUrl lastPathComponent];
      NSURL* fileDirUrl = [fileUrl URLByDeletingLastPathComponent];

      [configuration setOutputFileName:fileName];
      [configuration setOutputDirectoryUrl:fileDirUrl];
      [configuration setOutputDirectoryPath:fileDirUrl.path];
    }
  }

  return YES;
}

- (BOOL)populateExportConfigurationFromAppPreferences:(ExportConfiguration*)configuration error:(NSError**)error {

  NSURL* prefsPlistUrl = [CLIDefines fileUrlForAppPreferences];
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

  // output dir url must be set manually from the outputDirPath since the app uses bookmarks
  [configuration setOutputDirectoryUrl:[NSURL fileURLWithPath:configuration.outputDirectoryPath]];

  return YES;
}

- (void)dumpArguments {

  if (_processInfo) {
    MLE_Log_Info(@"ArgParser [dumpArguments]: %@", NSProcessInfo.processInfo.arguments);
  }
}

- (void)dumpOptions {

  NSLog(@"Options:");

  for (CLIOptionKind option = CLIOptionKindHelp; option < CLIOptionKind_MAX; option++) {

    BOOL isSet = [self isOptionSet:option];

    NSLog(@"  %@: %@", [CLIDefines nameForOption:option], (isSet ? @"Yes" : @"No"));
  }
}

+ (NSSet<NSString*>*)playlistIdsForIdsOption:(NSString*)playlistIdsOption error:(NSError**)error{

  return [NSSet setWithArray:[playlistIdsOption componentsSeparatedByString:@","]];

}

+ (BOOL)parsePlaylistSortingOption:(NSString*)sortOptions forPropertyDict:(NSMutableDictionary*)sortPropertyDict andOrderDict:(NSMutableDictionary*)sortOrderDict andReturnError:(NSError**)error {

//  MLE_Log_Info(@"ArgParser [parsePlaylistSortingOption:%@]", sortOptions);

  // each will be in form of {id}:{sort_property}-{sort_order}
  NSArray<NSString*>* playlistSortingStrings = [sortOptions componentsSeparatedByString:@","];

  for (NSString* sortOption in playlistSortingStrings) {

    if (![ArgParser parsePlaylistSortingSegment:sortOption forPropertyDict:sortPropertyDict andOrderDict:sortOrderDict andReturnError:error]) {
      return NO;
    }
  }

  return YES;
}

+ (BOOL)parsePlaylistSortingSegment:(NSString*)sortOption forPropertyDict:(NSMutableDictionary*)sortPropertyDict andOrderDict:(NSMutableDictionary*)sortOrderDict andReturnError:(NSError**)error {

//  MLE_Log_Info(@"ArgParser [parsePlaylistSortingSegment:%@]", sortOption);

  // part 1 will be {id}, part 2 will be {sort_property}-{sort_order}
  NSArray<NSString*>* sortOptionParts = [sortOption componentsSeparatedByString:@":"];
  if (sortOptionParts.count != 2) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorMalformedSortingOptionFormat userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid sorting option format: %@", sortOption],
      }];
    }
    return NO;
  }

  // part 1 will be {sort_property}, part 2 will be {sort_order}
  NSString* playlistId = sortOptionParts.firstObject;
  NSString* playlistSortValuesStr = sortOptionParts.lastObject;

  PlaylistSortOrderType sortOrder = PlaylistSortOrderNull;
  NSString* sortProperty = [ArgParser parsePlaylistSortingSegmentValue:playlistSortValuesStr forOrder:&sortOrder andReturnError:error];
  if (sortProperty == nil) {
    return NO;
  }

  [sortPropertyDict setValue:sortProperty forKey:playlistId];
  [sortOrderDict setValue:PlaylistSortOrderNames[sortOrder] forKey:playlistId];

  return YES;
}

+ (nullable NSString*)parsePlaylistSortingSegmentValue:(NSString*)sortOptionValue forOrder:(PlaylistSortOrderType*)aSortOrder andReturnError:(NSError**)error {

//  MLE_Log_Info(@"ArgParser [parsePlaylistSortingSegmentValue:%@]", sortOptionValue);

  NSArray<NSString*>* sortOptionValueParts = [sortOptionValue componentsSeparatedByString:@"-"];

  if (sortOptionValueParts.count != 2) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorMalformedSortingOptionFormat userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid sorting option format: %@", sortOptionValue],
      }];
    }
    return nil;
  }

  NSString* sortPropertyStr = sortOptionValueParts.firstObject;
  NSString* sortProperty = [ArgParser sortPropertyForOptionName:sortPropertyStr];

  if (sortProperty == nil) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorUnknownSortProperty userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unknown sort property specifier: %@", sortPropertyStr],
      }];
    }
    return nil;
  }

  NSString* sortOrderStr = sortOptionValueParts.lastObject;
  PlaylistSortOrderType sortOrder = [ArgParser sortOrderForOptionName:sortOrderStr];

  if (sortOrder == PlaylistSortOrderNull) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorUnknownSortOrder userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unknown sort order specifier: %@", sortOrderStr],
      }];
    }
    return nil;
  }

  *aSortOrder = sortOrder;

  return sortProperty;
}

+ (nullable NSString*)sortPropertyForOptionName:(NSString*)sortPropertyOption {

  if ([sortPropertyOption isEqualToString:@"title" ]) {
    return ITLibMediaItemPropertyTitle;
  }
  else if ([sortPropertyOption isEqualToString:@"artist" ]) {
    return ITLibMediaItemPropertyArtistName;
  }
  else if ([sortPropertyOption isEqualToString:@"albumartist" ]) {
    return ITLibMediaItemPropertyAlbumArtist;
  }
  else if ([sortPropertyOption isEqualToString:@"dateadded" ]) {
    return ITLibMediaItemPropertyAddedDate;
  }

  return nil;
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
  XPMArgumentSignature* helpSignature = [XPMArgumentSignature argumentSignatureWithFormat:[CLIDefines signatureFormatForCommand:CLICommandKindHelp]];
  [commandSignatures setObject:helpSignature forKey:@(CLICommandKindHelp)];
  [optionSignatures setObject:helpSignature forKey:@(CLIOptionKindHelp)];

  // init command signatures dict
  for (CLICommandKind command = CLICommandKindHelp + 1; command < CLICommandKindUnknown; command++) {

    NSString* signatureFormat = [CLIDefines signatureFormatForCommand:command];
    XPMArgumentSignature* commandSignature = [XPMArgumentSignature argumentSignatureWithFormat:signatureFormat];
    [commandSignatures setObject:commandSignature forKey:@(command)];
  }

  // init option signatures dict
  for (CLIOptionKind option = CLIOptionKindHelp + 1; option < CLIOptionKind_MAX; option++) {

    NSString* signatureFormat = [CLIDefines signatureFormatForOption:option];
    XPMArgumentSignature* optionSignature = [XPMArgumentSignature argumentSignatureWithFormat:signatureFormat];
    [optionSignatures setObject:optionSignature forKey:@(option)];
  }

  _commandSignatures = commandSignatures;
  _optionSignatures = optionSignatures;
}

- (void)parse {

  MLE_Log_Info(@"ArgParser [parse]");

  NSMutableSet* commandSigs = [NSMutableSet set];

  for (CLICommandKind command = CLICommandKindHelp; command < CLICommandKindUnknown; command++) {

    XPMArgumentSignature* commandSig = [self signatureForCommand:command];

    NSMutableSet* commandOptions = [NSMutableSet set];
    NSArray<NSNumber*>* validOptionTypes = [CLIDefines optionsForCommand:command];

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
      _command = CLICommandKindHelp;
      return YES;
    }
    else {
      if (error) {
        *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorInvalidCommand userInfo:@{
          NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Unknown command\nValid commands:  %@", [CLIDefines.commandNames componentsJoinedByString:@", "]],
        }];
      }
      _command = CLICommandKindUnknown;
      return NO;
    }
  }

  // help command, this returns valid even if more commands are entered as help messages get priority
  if ([commandTypes containsObject:@(CLICommandKindHelp)]) {
    _command = CLICommandKindHelp;
    return YES;
  }

  // multiple commands entered
  if (commandTypes.count > 1) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_ArgParser code:ArgParserErrorInvalidCommand userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Only one command may be specified at a time"],
      }];
    }
    _command = CLICommandKindUnknown;
    return NO;
  }

  // command issued is valid
  _command = [commandTypes.anyObject integerValue];
  MLE_Log_Info(@"ArgParser [validateCommandAndReturnError] identified valid command: %@", [CLIDefines nameForCommand:_command]);

  return YES;
}

- (BOOL)validateOptionsAndReturnError:(NSError**)error; {

  MLE_Log_Info(@"ArgParser [validateOptionsAndReturnError]");

  NSAssert(_command != CLICommandKindUnknown, @"validateOptionsAndReturnError called without valid command");

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

  MLE_Log_Info(@"ArgParser [validateOptionsAndReturnError] options seem valid");

  return YES;
}



@end
