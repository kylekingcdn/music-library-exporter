//
//  CLIDefines.h
//  music-library-exporter
//
//  Created by Kyle King on 2021-02-15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface CLIDefines : NSObject

typedef NS_ENUM(NSUInteger, CLICommandKind) {
  CLICommandKindHelp = 0,
  CLICommandKindVersion,
  CLICommandKindPrint,
  CLICommandKindExport,
  CLICommandKindUnknown,
};

typedef NS_ENUM(NSUInteger, CLIOptionKind) {

  // - shared - //

  CLIOptionKindHelp = 0,

  CLIOptionKindVersion,

  CLIOptionKindReadPrefs,

  CLIOptionKindFlatten,
  CLIOptionKindExcludeInternal,
  CLIOptionKindExcludeIds,

  // - export only - //

  CLIOptionKindMusicMediaDirectory,

  CLIOptionKindSort,
  CLIOptionKindRemapSearch,
  CLIOptionKindRemapReplace,
  CLIOptionKindRemapLocalhostPrefix,
  CLIOptionKindOutputPath,


  CLIOptionKind_MAX,
};

+ (nullable NSString*)nameForCommand:(CLICommandKind)command;
+ (nullable NSString*)nameForOption:(CLIOptionKind)option;

+ (nullable NSString*)nameAndValueForOption:(CLIOptionKind)option;

+ (NSArray<NSString*>*)commandNames;

+ (NSArray<NSNumber*>*)optionsForCommand:(CLICommandKind)command;

+ (NSArray<NSNumber*>*)requiredOptionsForCommand:(CLICommandKind)command;

+ (nullable NSString*)signatureFormatForCommand:(CLICommandKind)command;
+ (nullable NSString*)signatureFormatForOption:(CLIOptionKind)option;

+ (NSURL*)fileUrlForAppPreferences;

@end

NS_ASSUME_NONNULL_END
