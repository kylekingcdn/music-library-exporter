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

  XPMArgumentPackage* _package;

  XPMArgumentSignature* _helpSig;
  XPMArgumentSignature* _printCommandSig;
  XPMArgumentSignature* _exportCommandSig;

  XPMArgumentSignature* _flattenOptionSig;
  XPMArgumentSignature* _excludeInternalOptionSig;
  XPMArgumentSignature* _excludeIdsOptionSig;
  XPMArgumentSignature* _musicMediaDirSig;
  XPMArgumentSignature* _sortOptionSig;
  XPMArgumentSignature* _remapSearchOptionSig;
  XPMArgumentSignature* _remapReplaceOptionSig;
  XPMArgumentSignature* _outputPathOptionSig;
}


#pragma mark - Initializers

- (instancetype)initWithProcessInfo:(NSProcessInfo*)processInfo {

  self = [super init];

  _processInfo = processInfo;

  [self dumpArguments];

  [self initMemberSignatures];

  return self;
}

+ (instancetype)parserWithProcessInfo:(NSProcessInfo*)processInfo {

  ArgParser* parser = [[ArgParser alloc] initWithProcessInfo:processInfo];

  return parser;
}


#pragma mark - Accessors

- (nullable XPMArgumentSignature*)signatureForCommand:(LGCommandKind)command {

  switch (command) {
    case LGCommandKindHelp: { return _helpSig; }
    case LGCommandKindPrint: { return _printCommandSig; }
    case LGCommandKindExport: { return _exportCommandSig; }
    case LGCommandKindUnknown: { return nil; }
  }
}

- (nullable XPMArgumentSignature*)signatureForOption:(LGOptionKind)option {

  switch (option) {
    case LGOptionKindHelp: { return _helpSig; }
    case LGOptionKindFlatten: { return _flattenOptionSig; }
    case LGOptionKindExcludeInternal: { return _excludeInternalOptionSig; }
    case LGOptionKindExcludeIds: { return _excludeIdsOptionSig; }
    case LGOptionKindMusicMediaDirectory: { return _musicMediaDirSig; }
    case LGOptionKindSort: { return _sortOptionSig; }
    case LGOptionKindRemapSearch: { return _remapSearchOptionSig; }
    case LGOptionKindRemapReplace: { return _remapReplaceOptionSig; }
    case LGOptionKindOutputPath: { return _outputPathOptionSig; }
  }
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

- (BOOL)populateExportConfiguration:(ExportConfiguration*)configuration {

  [configuration setFlattenPlaylistHierarchy:[_package booleanValueForSignature:_flattenOptionSig]];

  [configuration setIncludeInternalPlaylists:![_package booleanValueForSignature:_excludeInternalOptionSig]];

  NSString* musicMediaDir = [_package firstObjectForSignature:_musicMediaDirSig];
  if (musicMediaDir) {
    [configuration setMusicLibraryPath:musicMediaDir];
  }
  NSString* excludedIdsStr = [_package firstObjectForSignature:_excludeIdsOptionSig];
  if (excludedIdsStr) {
    NSSet<NSNumber*>* excludedIds = [ArgParser playlistIdsForIdsOption:excludedIdsStr];
    [configuration setExcludedPlaylistPersistentIds:excludedIds];
  }

  NSString* playlistSortingOpt = [_package firstObjectForSignature:_sortOptionSig];
  if (playlistSortingOpt) {

    NSMutableDictionary* sortColumnDict = [NSMutableDictionary dictionary];
    NSMutableDictionary* sortOrderDict = [NSMutableDictionary dictionary];
    NSError* sortOptionError = [ArgParser parsePlaylistsSortingOption:playlistSortingOpt forColumnDictionary:sortColumnDict andOrderDictionary:sortOrderDict];
    if (sortOptionError) {
      MLE_Log_Info(@"error parsing options - %@", sortOptionError.localizedDescription);
      return NO;
    }

    [configuration setCustomSortColumnDict:sortColumnDict];
    [configuration setCustomSortOrderDict:sortOrderDict];
  }

  NSString* remapSearch = [_package firstObjectForSignature:_remapSearchOptionSig];
  NSString* remapReplace = [_package firstObjectForSignature:_remapReplaceOptionSig];
  if (remapSearch && remapReplace) {
    [configuration setRemapRootDirectoryOriginalPath:remapSearch];
    [configuration setRemapRootDirectoryMappedPath:remapReplace];
    [configuration setRemapRootDirectory:YES];
  }
  else {
    [configuration setRemapRootDirectory:NO];
  }

  NSString* outputFilePath = [_package firstObjectForSignature:_outputPathOptionSig];
  if (outputFilePath) {
    NSURL* fileUrl = [NSURL fileURLWithPath:outputFilePath];

    NSString* fileName = [fileUrl lastPathComponent];
    NSURL* fileDirUrl = [fileUrl URLByDeletingLastPathComponent];
    NSString* fileDirStr = [fileDirUrl path];

    [configuration setOutputFileName:fileName];
    [configuration setOutputDirectoryUrl:fileDirUrl];
    [configuration setOutputDirectoryPath:fileDirStr];
  }

  return YES;
}

- (void)displayHelp {

  MLE_Log_Info(@"ArgParser [displayHelp]");

}

- (void)dumpArguments {

  if (_processInfo) {
    MLE_Log_Info(@"ArgParser [dumpArguments]: %@", NSProcessInfo.processInfo.arguments);
  }
}

+ (NSSet<NSNumber*>*)playlistIdsForIdsOption:(NSString*)playlistIdsOption {

  NSMutableSet<NSNumber*>* playlistIds = [NSMutableSet set];

  NSArray<NSString*>* playlistIdStrings = [playlistIdsOption componentsSeparatedByString:@","];

  for (NSString* playlistIdStr in playlistIdStrings) {

    NSDecimalNumber* playlistId = [NSDecimalNumber decimalNumberWithString:playlistIdStr];
    if (!playlistId) {
      MLE_Log_Info(@"ArgParser [parsePlaylistIdsOption]: error - failed to parse playlist id: %@", playlistIdStr);
    }
    else {
      [playlistIds addObject:playlistId];
    }
  }

  return playlistIds;
}

+ (NSError*)parsePlaylistsSortingOption:(NSString*)sortOptions forColumnDictionary:(NSMutableDictionary*)sortColDict andOrderDictionary:(NSMutableDictionary*)sortOrderDict {

//  MLE_Log_Info(@"ArgParser [parsePlaylistsSortingOption:%@]", sortOptions);

  NSError* error;

  // each will be in form of {id}:{sort_col}-{sort_order}
  NSArray<NSString*>* playlistSortingStrings = [sortOptions componentsSeparatedByString:@","];

  for (NSString* sortOption in playlistSortingStrings) {

    error = [ArgParser parsePlaylistSortingOption:sortOption forColumnDictionary:sortColDict andOrderDictionary:sortOrderDict];
    if (error) {
      break;
    }
  }

  return error;
}

+ (NSError*)parsePlaylistSortingOption:(NSString*)sortOption forColumnDictionary:(NSMutableDictionary*)sortColDict andOrderDictionary:(NSMutableDictionary*)sortOrderDict {

//  MLE_Log_Info(@"ArgParser [parsePlaylistSortingOption:%@]", sortOption);

  NSError* error;
  NSInteger errorCode = -1;
  NSString* errorDescription;

  // part 1 will be {id}, part 2 will be {sort_col}-{sort_order}
  NSArray<NSString*>* sortOptionParts = [sortOption componentsSeparatedByString:@":"];
  if (sortOptionParts.count != 2) {
    errorCode = 1;
    errorDescription = [NSString stringWithFormat:@"Invalid sorting option format: %@", sortOption];
  }
  else {
    // part 1 will be {sort_col}, part 2 will be {sort_order}
    NSString* playlistIdStr = sortOptionParts.firstObject;
    NSString* playlistSortValuesStr = sortOptionParts.lastObject;

    NSDecimalNumber* playlistId = [NSDecimalNumber decimalNumberWithString:playlistIdStr];
    if (!playlistId) {
      errorCode = 2;
      errorDescription = [NSString stringWithFormat:@"Invalid playlist id for sort option part: %@", sortOption];
    }
    else {
      PlaylistSortColumnType sortColumn = PlaylistSortColumnNull;
      PlaylistSortOrderType sortOrder = PlaylistSortOrderNull;
      error = [ArgParser parsePlaylistSortingOptionValue:playlistSortValuesStr forColumn:&sortColumn andOrder:&sortOrder];
      if (error) {
        return error;
      }
      [sortColDict setValue:[Utils titleForPlaylistSortColumn:sortColumn] forKey:[playlistId stringValue]];
      [sortOrderDict setValue:[Utils titleForPlaylistSortOrder:sortOrder] forKey:[playlistId stringValue]];
    }
  }

  if (errorCode >= 0) {
    if (!errorDescription) {
      errorDescription = @"Unknown error";
    }
    NSDictionary<NSErrorUserInfoKey,id>* errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, nil];
    error = [NSError errorWithDomain:__MLE__AppBundleIdentifier code:errorCode userInfo:errorInfo];
  }

  return error;
}

+ (NSError*)parsePlaylistSortingOptionValue:(NSString*)sortOptionValue forColumn:(PlaylistSortColumnType*)aSortColumn andOrder:(PlaylistSortOrderType*)aSortOrder {

//  MLE_Log_Info(@"ArgParser [parsePlaylistSortingOptionValue:%@]", sortOptionValue);

  NSInteger errorCode = -1;
  NSString* errorDescription;

  NSArray<NSString*>* sortOptionValueParts = [sortOptionValue componentsSeparatedByString:@"-"];
  if (sortOptionValueParts.count != 2) {
    errorCode = 1;
    errorDescription = [NSString stringWithFormat:@"Invalid sorting option format: %@", sortOptionValue];
  }
  else {
    NSString* sortColStr = sortOptionValueParts.firstObject;
    NSString* sortOrderStr = sortOptionValueParts.lastObject;
    PlaylistSortColumnType sortCol = [ArgParser sortColumnForOptionName:sortColStr];
    PlaylistSortOrderType sortOrder = [ArgParser sortOrderForOptionName:sortOrderStr];
    if (sortCol == PlaylistSortColumnNull) {
      errorCode = 3;
      errorDescription = [NSString stringWithFormat:@"Unknown sort column specifier: %@", sortColStr];
    }
    else if (sortOrder == PlaylistSortOrderNull) {
      errorCode = 4;
      errorDescription = [NSString stringWithFormat:@"Unknown sort order specifier: %@", sortOrderStr];
    }
    else {
      *aSortColumn = sortCol;
      *aSortOrder = sortOrder;
    }
  }

  NSError* error;
  if (errorCode >= 0) {
    if (!errorDescription) {
      errorDescription = @"Unknown error";
    }
    NSDictionary<NSErrorUserInfoKey,id>* errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, nil];
    error = [NSError errorWithDomain:__MLE__AppBundleIdentifier code:errorCode userInfo:errorInfo];
  }

  return error;
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

  _helpSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForCommand:LGCommandKindHelp]];
  
  _printCommandSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForCommand:LGCommandKindPrint]];
  _exportCommandSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForCommand:LGCommandKindExport]];

  _flattenOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindFlatten]];
  _excludeInternalOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindExcludeInternal]];
  _excludeIdsOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindExcludeIds]];

  _musicMediaDirSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindMusicMediaDirectory]];
  _sortOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindSort]];
  _remapSearchOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindRemapSearch]];
  _remapReplaceOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindRemapReplace]];
  _outputPathOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindOutputPath]];
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

- (BOOL)validateCommand {

  MLE_Log_Info(@"ArgParser [validateCommand]");

  _commandError = nil;

  NSSet<NSNumber*>* commandTypes = [self determineCommandTypes];

  // no command found
  if (commandTypes.count == 0) {
    // interpret running the program with no arguments and no options as a help command
    if (_processInfo.arguments.count <= 1) {
      _command = LGCommandKindHelp;
      return YES;
    }
    else {
      _commandError = @"please enter a valid command";
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
    _commandError = @"only one command can be specified at a time";
    _command = LGCommandKindUnknown;
    return NO;
  }

  // command issued is valid
  _command = [commandTypes.anyObject integerValue];
  MLE_Log_Info(@"ArgParser [validateCommand] valid command: %@", [LGDefines nameForCommand:_command]);

  return YES;
}

- (BOOL)validateOptions {

  MLE_Log_Info(@"ArgParser [validateOptions]");

  if (_command == LGCommandKindUnknown) {
    MLE_Log_Info(@"ArgParser [validateOptions] cannot validate options - command is invalid");
    _optionsError = @"command is invalid";
    return NO;
  }

  if (_package.unknownSwitches.count > 0) {
    _optionsError = @"unrecognized options";
    _optionsWithErrors = _package.unknownSwitches;
    return NO;
  }

  if (_package.uncapturedValues.count > 1) {
    NSMutableArray* trulyUncaptured = [_package.uncapturedValues mutableCopy];
    [trulyUncaptured removeObjectAtIndex:0];
    _optionsError = @"unexpected arguments";
    _optionsWithErrors = trulyUncaptured;
    return NO;
  }

  MLE_Log_Info(@"ArgParser [validateOptions] options are valid");

  return YES;
}



@end
