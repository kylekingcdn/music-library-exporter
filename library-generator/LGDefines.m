//
//  LGDefines.m
//  library-generator
//
//  Created by Kyle King on 2021-02-15.
//

#import "LGDefines.h"

@implementation LGDefines


+ (NSArray<NSNumber*>*)optionsForCommand:(LGCommandKind)command {

  switch (command) {

    case LGCommandKindHelp: {
      return @[
        @(LGOptionKindHelp)
      ];
    }

    case LGCommandKindPrint: {
      return @[
        @(LGOptionKindHelp),
        @(LGOptionKindFlatten),
        @(LGOptionKindExcludeInternal),
        @(LGOptionKindExcludeIds),
      ];
    }

    case LGCommandKindExport: {
      return @[
        @(LGOptionKindHelp),
        @(LGOptionKindFlatten),
        @(LGOptionKindExcludeInternal),
        @(LGOptionKindExcludeIds),
        @(LGOptionKindMusicMediaDirectory),
        @(LGOptionKindSort),
        @(LGOptionKindRemapSearch),
        @(LGOptionKindRemapReplace),
        @(LGOptionKindOutputPath),
      ];
    }

    case LGCommandKindUnknown: {
      return @[
        @(LGOptionKindHelp)
      ];
    }
  }
}

+ (NSArray<NSNumber*>*)requiredOptionsForCommand:(LGCommandKind)command {

  switch (command) {

    case LGCommandKindHelp: {
      return @[ ];
    }

    case LGCommandKindPrint: {
      return @[ ];
    }

    case LGCommandKindExport: {
      return @[
        @(LGOptionKindMusicMediaDirectory),
        @(LGOptionKindOutputPath),
      ];
    }

    case LGCommandKindUnknown: {
      return @[ ];
    }
  }
}

+ (nullable NSString*)nameForCommand:(LGCommandKind)command {

  switch (command) {
    case LGCommandKindHelp: {
      return @"help";
    }
    case LGCommandKindPrint: {
      return @"print";
    }
    case LGCommandKindExport: {
      return @"export";
    }
    case LGCommandKindUnknown: {
      return nil;
    }
  }
}
+ (nullable NSString*)nameForOption:(LGOptionKind)option {

  switch (option) {

    case LGOptionKindHelp: {
      return @"--help";
    }

    case LGOptionKindFlatten: {
      return @"--flatten";
    }
    case LGOptionKindExcludeInternal: {
      return @"--exclude_internal";
    }
    case LGOptionKindExcludeIds: {
      return @"--exclude_ids";
    }

    case LGOptionKindMusicMediaDirectory: {
      return @"--music_media_dir";
    }
    case LGOptionKindSort: {
      return @"--sort";
    }
    case LGOptionKindRemapSearch: {
      return @"--remap_search";
    }
    case LGOptionKindRemapReplace: {
      return @"--remap_replace}";
    }
    case LGOptionKindOutputPath: {
      return @"--output_path";
    }
  }
}

+ (nullable NSString*)signatureFormatForCommand:(LGCommandKind)command {

  switch (command) {

    case LGCommandKindHelp: {
      return @"[-h --help help]";
    }
    case LGCommandKindPrint: {
      return @"[print]";
    }
    case LGCommandKindExport: {
      return @"[export]";
    }

    case LGCommandKindUnknown: {
      return nil;
    }
  }
}

+ (nullable NSString*)signatureFormatForOption:(LGOptionKind)option {

  switch (option) {

    case LGOptionKindHelp: {
      return [LGDefines signatureFormatForCommand:LGCommandKindHelp];
    }

    case LGOptionKindFlatten: {
      return @"[-f --flatten]";
    }
    case LGOptionKindExcludeInternal: {
      return @"[-n --exclude_internal]";
    }
    case LGOptionKindExcludeIds: {
      return @"[-e --exclude_ids]={1,1}";
    }

    case LGOptionKindMusicMediaDirectory: {
      return @"[-m --music_media_dir]={1,1}";
    }
    case LGOptionKindSort: {
      return @"[-S --sort]={1,1}";
    }
    case LGOptionKindRemapSearch: {
      return @"[-s --remap_search]={1,1}";
    }
    case LGOptionKindRemapReplace: {
      return @"[-r --remap_replace]={1,1}";
    }
    case LGOptionKindOutputPath: {
      return @"[-o --output_path]={1,1}";
    }
  }
}

@end
