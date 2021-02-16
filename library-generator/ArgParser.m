//
//  ArgParser.m
//  library-generator
//
//  Created by Kyle King on 2021-02-15.
//

#import "ArgParser.h"

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

  // TODO: finish me
  NSString* excludedIdsStr = [_package firstObjectForSignature:_excludeIdsOptionSig];
  if (excludedIdsStr) {
    NSArray<NSString*>* excludedIdsArr = [excludedIdsStr componentsSeparatedByString:@","];
    NSMutableSet<NSNumber*>* excludedIds = [NSMutableSet set];

    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    for (NSString* currId in excludedIdsArr) {
      [excludedIds addObject:[numberFormatter numberFromString:currId]];
    }
    [configuration setExcludedPlaylistPersistentIds:excludedIds];
  }

  /*
  NSString* sortOverridesStr = [_package firstObjectForSignature:_sortOptionSig];
  if (sortOverridesStr) {
    NSArray<NSString*>* sortOverridesArr = [sortOverridesStr componentsSeparatedByString:@","];
    for (NSString* currPlaylistSortOverride in sortOverridesArr) {
      //...
    }
    [configuration setExcludedPlaylistsPersistentIds:excludedIds];
  }
  */

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
  NSLog(@"ArgParser [validateCommand] valid command: %li", (long)_command);

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
