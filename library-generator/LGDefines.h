//
//  LGDefines.h
//  library-generator
//
//  Created by Kyle King on 2021-02-15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface LGDefines : NSObject


extern NSErrorDomain const __MLE_ErrorDomain_ArgParser;
extern NSErrorDomain const __MLE_ErrorDomain_LibraryGenerator;

typedef NS_ENUM(NSInteger, ArgParserErrorCode) {
  ArgParserErrorUknown,
  ArgParserErrorInvalidCommand,
  ArgParserErrorInvalidOption,
  ArgParserErrorMissingRequiredOption,
  ArgParserErrorMalformedPlaylistIdOption,
  ArgParserErrorMalformedSortingOptionFormat,
  ArgParserErrorUnknownSortColumn,
  ArgParserErrorUnknownSortOrder,
  ArgParserErrorAppPrefsPropertyListInvalid,
};

typedef NS_ENUM(NSInteger, LibraryGeneratorErrorCode) {
  LibraryGeneratorErrorUknown,
  LibraryGeneratorErrorInvalidOutputPath,
  LibraryGeneratorErrorInvalidMusicMediaDirectory,
  LibraryGeneratorErrorInvalidRemapping,
};

typedef NS_ENUM(NSInteger, LGCommandKind) {
  LGCommandKindHelp,
  LGCommandKindPrint,
  LGCommandKindExport,
  LGCommandKindUnknown,
};

typedef NS_ENUM(NSInteger, LGOptionKind) {

  // - shared - //

  LGOptionKindHelp,

  LGOptionKindVerbose,

  LGOptionKindReadPrefs,

  LGOptionKindFlatten,
  LGOptionKindExcludeInternal,
  LGOptionKindExcludeIds,

  // - export only - //

  LGOptionKindMusicMediaDirectory,

  LGOptionKindSort,
  LGOptionKindRemapSearch,
  LGOptionKindRemapReplace,
  LGOptionKindOutputPath,


  LGOptionKind_MAX,
};

+ (nullable NSString*)nameForCommand:(LGCommandKind)command;
+ (nullable NSString*)nameForOption:(LGOptionKind)option;

+ (nullable NSString*)nameAndValueForOption:(LGOptionKind)option;

+ (NSArray<NSString*>*)commandNames;

+ (NSArray<NSNumber*>*)optionsForCommand:(LGCommandKind)command;

+ (NSArray<NSNumber*>*)requiredOptionsForCommand:(LGCommandKind)command;

+ (nullable NSString*)signatureFormatForCommand:(LGCommandKind)command;
+ (nullable NSString*)signatureFormatForOption:(LGOptionKind)option;

+ (NSURL*)fileUrlForAppPreferences;

@end

NS_ASSUME_NONNULL_END
