//
//  ArgParser.m
//  library-generator
//
//  Created by Kyle King on 2021-02-15.
//

#import "ArgParser.h"

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

  NSString* excludedIdsStr = [_package firstObjectForSignature:_excludeIdsOptionSig];
  if (excludedIdsStr) {
    NSSet<NSNumber*>* excludedIds = [ArgParser parsePlaylistIdsOption:excludedIdsStr];
    [configuration setExcludedPlaylistPersistentIds:excludedIds];
  }

  NSString* playlistSorting = [_package firstObjectForSignature:_sortOptionSig];
  NSDictionary* sortOverridesDict = [ArgParser parsePlaylistSortingOption:playlistSorting];
  for (NSString* currPlaylistIdStr in sortOverridesDict.allKeys) {
    NSDecimalNumber* currPlaylistId = [NSDecimalNumber decimalNumberWithString:currPlaylistIdStr];
    if (currPlaylistId) {
      NSDictionary* currPlaylistSorting = [sortOverridesDict objectForKey:currPlaylistIdStr];
      PlaylistSortColumnType sortCol = [[currPlaylistSorting objectForKey:@"column"] integerValue];
      PlaylistSortOrderType sortOrder = [[currPlaylistSorting objectForKey:@"order"] integerValue];
      [configuration setCustomSortColumn:sortCol forPlaylist:currPlaylistId];
      [configuration setCustomSortOrder:sortOrder forPlaylist:currPlaylistId];
    }
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

  NSLog(@"ArgParser [displayHelp]");

}

- (void)dumpArguments {

  if (_processInfo) {
    NSLog(@"ArgParser [dumpArguments]: %@", NSProcessInfo.processInfo.arguments);
  }
}

+ (NSSet<NSNumber*>*)parsePlaylistIdsOption:(NSString*)playlistIdsOption {

  NSMutableSet<NSNumber*>* playlistIds = [NSMutableSet set];

  NSArray<NSString*>* playlistIdStrings = [playlistIdsOption componentsSeparatedByString:@","];

  for (NSString* playlistIdStr in playlistIdStrings) {

    NSDecimalNumber* playlistId = [NSDecimalNumber decimalNumberWithString:playlistIdStr];
    if (!playlistId) {
      NSLog(@"ArgParser [parsePlaylistIdsOption]: error - failed to parse playlist id: %@", playlistIdStr);
    }
    else {
      [playlistIds addObject:playlistId];
    }
  }

  return playlistIds;
}

+ (NSDictionary*)parsePlaylistSortingOption:(NSString*)playlistSortingOption {

  NSMutableDictionary* playlistSorting = [NSMutableDictionary dictionary];

  // each will be in form of {id}:{sort_col}-{sort_order}
  NSArray<NSString*>* playlistSortingStrings = [playlistSortingOption componentsSeparatedByString:@","];

  for (NSString* playlistSortStr in playlistSortingStrings) {

    // part 1 will be {id}, part 2 will be {sort_col}-{sort_order}
    NSArray<NSString*>* playlistIdSortParts = [playlistSortStr componentsSeparatedByString:@":"];

    if (playlistIdSortParts.count != 2) {
      NSLog(@"ArgParser [parsePlaylistSortingOption] error - unexpected format for sorting option part: %@", playlistSortStr);
    }
    else {
      // part 1 will be {sort_col}, part 2 will be {sort_order}
      NSString* playlistIdStr = playlistIdSortParts.firstObject;

      NSDecimalNumber* playlistId = [NSDecimalNumber decimalNumberWithString:playlistIdStr];
      if (!playlistId) {
        NSLog(@"ArgParser [parsePlaylistSortingOption] error - failed to parse playlist id: %@", playlistIdStr);
      }

      NSString* sortColOrderStr = playlistIdSortParts.lastObject;
      NSArray<NSString*>* sortColOrderParts = [sortColOrderStr componentsSeparatedByString:@"-"];
      if (sortColOrderParts.count != 2) {
        NSLog(@"ArgParser [parsePlaylistSortingOption] error - unexpected format for sorting column + sorting order: %@", sortColOrderStr);
      }
      else {
        NSString* sortColStr = sortColOrderParts.firstObject;
        PlaylistSortColumnType sortCol = [ArgParser sortColumnForOptionName:sortColStr];

        NSString* sortOrderStr = sortColOrderParts.lastObject;
        PlaylistSortOrderType sortOrder = [ArgParser sortOrderForOptionName:sortOrderStr];

        if (sortCol == PlaylistSortColumnNull) {
          NSLog(@"ArgParser [parsePlaylistSortingOption] error - unknown sort column: %@", sortColStr);
        }
        else if (sortOrder == PlaylistSortOrderNull) {
          NSLog(@"ArgParser [parsePlaylistSortingOption] error - unknown sort order: %@", sortOrderStr);
        }
        else {
          NSString* sortColTitle = [Utils titleForPlaylistSortColumn:sortCol];
          NSString* sortOrderTitle = [Utils titleForPlaylistSortOrder:sortOrder];
          NSLog(@"ArgParser [parsePlaylistSortingOption] parsed sorting option (Playlist: '%@', Column: '%@', Order: '%@')", [playlistId stringValue], sortColTitle, sortOrderTitle);

          NSDictionary* sortValsDict = [NSDictionary dictionaryWithObjectsAndKeys: @(sortCol), @"column", @(sortOrder), @"order", nil];
          [playlistSorting setObject:sortValsDict forKey:[playlistId stringValue]];
        }
      }
    }
  }

  return playlistSorting;
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

  NSLog(@"ArgParser [initMemberSignatures]");

  _helpSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForCommand:LGCommandKindHelp]];
  
  _printCommandSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForCommand:LGCommandKindPrint]];
  _exportCommandSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForCommand:LGCommandKindExport]];

  _flattenOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindFlatten]];
  _excludeInternalOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindExcludeInternal]];
  _excludeIdsOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindExcludeIds]];
  _sortOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindSort]];
  _remapSearchOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindRemapSearch]];
  _remapReplaceOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindRemapReplace]];
  _outputPathOptionSig = [XPMArgumentSignature argumentSignatureWithFormat:[LGDefines signatureFormatForOption:LGOptionKindOutputPath]];
}

- (void)parse {

  NSLog(@"ArgParser [parse]");

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

  NSLog(@"ArgParser [validateCommand]");

  _commandError = nil;

  NSSet<NSNumber*>* commandTypes = [self determineCommandTypes];

  // no command found
  if (commandTypes.count == 0) {
    _commandError = @"please enter a valid command";
    _command = LGCommandKindUnknown;
    return NO;
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
  NSLog(@"ArgParser [validateCommand] valid command: %@", [LGDefines signatureFormatForCommand:_command]);

  return YES;
}

- (BOOL)validateOptions {

  NSLog(@"ArgParser [validateOptions]");

  if (_command == LGCommandKindUnknown) {
    NSLog(@"ArgParser [validateOptions] cannot validate options - command is invalid");
    _optionsError = @"command is invalid";
    return NO;
  }

  if (_package.unknownSwitches.count > 0) {
    _optionsError = @"unrecognized options for command";
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

  NSLog(@"ArgParser [validateOptions] options are valid");

  return YES;
}



@end
