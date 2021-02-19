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

- (BOOL)populateExportConfiguration:(ExportConfiguration*)configuration {

  [configuration setFlattenPlaylistHierarchy:[_package booleanValueForSignature:[self signatureForOption:LGOptionKindFlatten]]];

  [configuration setIncludeInternalPlaylists:![_package booleanValueForSignature:[self signatureForOption:LGOptionKindExcludeInternal]]];

  NSString* musicMediaDir = [_package firstObjectForSignature:[self signatureForOption:LGOptionKindMusicMediaDirectory]];
  if (musicMediaDir) {
    [configuration setMusicLibraryPath:musicMediaDir];
  }
  NSString* excludedIdsStr = [_package firstObjectForSignature:[self signatureForOption:LGOptionKindExcludeIds]];
  if (excludedIdsStr) {
    NSSet<NSNumber*>* excludedIds = [ArgParser playlistIdsForIdsOption:excludedIdsStr];
    [configuration setExcludedPlaylistPersistentIds:excludedIds];
  }

  NSString* playlistSortingOpt = [_package firstObjectForSignature:[self signatureForOption:LGOptionKindSort]];
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

  NSString* remapSearch = [_package firstObjectForSignature:[self signatureForOption:LGOptionKindRemapSearch]];
  NSString* remapReplace = [_package firstObjectForSignature:[self signatureForOption:LGOptionKindRemapReplace]];
  if (remapSearch && remapReplace) {
    [configuration setRemapRootDirectoryOriginalPath:remapSearch];
    [configuration setRemapRootDirectoryMappedPath:remapReplace];
    [configuration setRemapRootDirectory:YES];
  }
  else {
    [configuration setRemapRootDirectory:NO];
  }

  NSString* outputFilePath = [_package firstObjectForSignature:[self signatureForOption:LGOptionKindOutputPath]];
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

  _optionsError = @"unexpected return of validateOption: NO";

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

  NSArray<NSNumber*>* requiredOptions = [LGDefines requiredOptionsForCommand:_command];
  NSMutableArray* requiredOptionsMissing = [NSMutableArray array];
  NSMutableArray* requiredOptionsMissingNames = [NSMutableArray array];

  // validate required options have been specified
  for (NSNumber* optionType in requiredOptions) {

    LGOptionKind option = [optionType integerValue];
    XPMArgumentSignature* sig = [self signatureForOption:option];
    NSUInteger sigCount = [_package countOfSignature:sig];
    if (sigCount == 0) {
      MLE_Log_Info(@"ArgParser [validateOptions] missing required option: %@", [LGDefines nameForOption:option]);
      [requiredOptionsMissing addObject:sig];
      [requiredOptionsMissingNames addObject:[LGDefines nameAndValueForOption:option]];
    }
  }
  if (requiredOptionsMissing.count > 0) {
    _optionsError = @"required options are incomplete";
    _optionsWithErrors = requiredOptionsMissingNames ;
      return NO;
  }

  MLE_Log_Info(@"ArgParser [validateOptions] options seem valid");

  return YES;
}



@end
