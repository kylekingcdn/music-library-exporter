//
//  CLIDefines.h
//  music-library-exporter
//
//  Created by Kyle King on 2021-02-15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface CLIDefines : NSObject

typedef NS_ENUM(NSInteger, LGCommandKind) {
  LGCommandKindHelp,
  LGCommandKindVersion,
  LGCommandKindPrint,
  LGCommandKindExport,
  LGCommandKindUnknown,
};

typedef NS_ENUM(NSInteger, CLIOptionKind) {

  // - shared - //

  CLIOptionKindHelp,

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

+ (nullable NSString*)nameForCommand:(LGCommandKind)command;
+ (nullable NSString*)nameForOption:(CLIOptionKind)option;

+ (nullable NSString*)nameAndValueForOption:(CLIOptionKind)option;

+ (NSArray<NSString*>*)commandNames;

+ (NSArray<NSNumber*>*)optionsForCommand:(LGCommandKind)command;

+ (NSArray<NSNumber*>*)requiredOptionsForCommand:(LGCommandKind)command;

+ (nullable NSString*)signatureFormatForCommand:(LGCommandKind)command;
+ (nullable NSString*)signatureFormatForOption:(CLIOptionKind)option;

+ (NSURL*)fileUrlForAppPreferences;

@end

NS_ASSUME_NONNULL_END
