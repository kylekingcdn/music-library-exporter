//
//  LGDefines.h
//  library-generator
//
//  Created by Kyle King on 2021-02-15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGDefines : NSObject

typedef NS_ENUM(NSInteger, LGCommandKind) {
  LGCommandKindHelp,
  LGCommandKindPrint,
  LGCommandKindExport,
  LGCommandKindUnknown,
};

typedef NS_ENUM(NSInteger, LGOptionKind) {

  // - shared - //

  LGOptionKindHelp,

  LGOptionKindFlatten,
  LGOptionKindExcludeInternal,
  LGOptionKindExcludeIds,

  // - export only - //

  LGOptionKindMusicMediaDirectory,

  LGOptionKindSort,
  LGOptionKindRemapSearch,
  LGOptionKindRemapReplace,
  LGOptionKindOutputPath,
};

+ (nullable NSString*)nameForCommand:(LGCommandKind)command;
+ (nullable NSString*)nameForOption:(LGOptionKind)option;

+ (NSArray<NSNumber*>*)optionsForCommand:(LGCommandKind)command;

+ (nullable NSString*)signatureFormatForCommand:(LGCommandKind)command;
+ (nullable NSString*)signatureFormatForOption:(LGOptionKind)option;

@end

NS_ASSUME_NONNULL_END
