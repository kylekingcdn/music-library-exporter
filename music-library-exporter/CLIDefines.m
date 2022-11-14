//
//  CLIDefines.m
//  music-library-exporter
//
//  Created by Kyle King on 2021-02-15.
//

#import "CLIDefines.h"


@implementation CLIDefines

+ (NSArray<NSNumber*>*)optionsForCommand:(LGCommandKind)command {

  switch (command) {

    case LGCommandKindHelp: {
      return @[
        @(LGOptionKindHelp)
      ];
    }

    case LGCommandKindVersion: {
      return @[
        @(LGOptionKindVersion)
      ];
    }

    case LGCommandKindPrint: {
      return @[
        @(LGOptionKindHelp),
        @(LGOptionKindReadPrefs),
        @(LGOptionKindFlatten),
        @(LGOptionKindExcludeInternal),
        @(LGOptionKindExcludeIds),
      ];
    }

    case LGCommandKindExport: {
      return @[
        @(LGOptionKindHelp),
        @(LGOptionKindReadPrefs),
        @(LGOptionKindFlatten),
        @(LGOptionKindExcludeInternal),
        @(LGOptionKindExcludeIds),
        @(LGOptionKindMusicMediaDirectory),
        @(LGOptionKindSort),
        @(LGOptionKindRemapSearch),
        @(LGOptionKindRemapReplace),
        @(LGOptionKindRemapLocalhostPrefix),
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

    case LGCommandKindVersion: {
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
    case LGCommandKindVersion: {
      return @"version";
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
    case LGOptionKindVersion: {
      return @"--version";
    }

    case LGOptionKindReadPrefs: {
      return @"--read_prefs";
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
      return @"--remap_replace";
    }
    case LGOptionKindRemapLocalhostPrefix: {
      return @"--localhost_path_prefix";
    }
    case LGOptionKindOutputPath: {
      return @"--output_path";
    }

    case LGOptionKind_MAX: {
      return nil;
    }
  }
}

+ (nullable NSString*)nameAndValueForOption:(LGOptionKind)option {

  NSString* optionName = [CLIDefines nameForOption:option];

  switch (option) {

    case LGOptionKindExcludeIds: {
      optionName = [optionName stringByAppendingString:@" <playlist_ids>"];
      break;
    }
    case LGOptionKindMusicMediaDirectory: {
      optionName = [optionName stringByAppendingString:@" <music_dir>"];
      break;
    }
    case LGOptionKindSort: {
      optionName = [optionName stringByAppendingString:@" <playlist_sorting_value>"];
      break;
    }
    case LGOptionKindRemapSearch: {
      optionName = [optionName stringByAppendingString:@" <text_to_find>"];
      break;
    }
    case LGOptionKindRemapReplace: {
      optionName = [optionName stringByAppendingString:@" <replacement_text>"];
      break;
    }
    case LGOptionKindOutputPath: {
      optionName = [optionName stringByAppendingString:@" <path>"];
      break;
    }
    default: {
      break;
    }
  }

  return optionName;
}

+ (NSArray<NSString*>*)commandNames {

  NSMutableArray<NSString*>* names = [NSMutableArray array];

  for (LGCommandKind command = LGCommandKindHelp; command < LGCommandKindUnknown; command++) {
    [names addObject:[CLIDefines nameForCommand:command]];
  }

  return names;
}

+ (nullable NSString*)signatureFormatForCommand:(LGCommandKind)command {

  switch (command) {

    case LGCommandKindHelp: {
      return @"[-h --help help]";
    }
    case LGCommandKindVersion: {
      return @"[-v --version version]";
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
      return [CLIDefines signatureFormatForCommand:LGCommandKindHelp];
    }

    case LGOptionKindVersion: {
      return [CLIDefines signatureFormatForCommand:LGCommandKindVersion];
    }

    case LGOptionKindReadPrefs: {
      return @"[-p --read_prefs]";
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
      return @"[--sort]={1,1}";
    }
    case LGOptionKindRemapSearch: {
      return @"[-s --remap_search]={1,1}";
    }
    case LGOptionKindRemapReplace: {
      return @"[-r --remap_replace]={1,1}";
    }
    case LGOptionKindRemapLocalhostPrefix: {
      return @"[--localhost_path_prefix]";
    }
    case LGOptionKindOutputPath: {
      return @"[-o --output_path]={1,1}";
    }

    case LGOptionKind_MAX: {
      return nil;
    }
  }
}

+ (NSURL*)fileUrlForAppPreferences {

  NSArray<NSString*>* pathComponents = @[
    NSFileManager.defaultManager.homeDirectoryForCurrentUser.path,
    @"Library",
    @"Group Containers",
    @"group.9YLM7HTV6V.com.MusicLibraryExporter",
    @"Library",
    @"Preferences",
    @"group.9YLM7HTV6V.com.MusicLibraryExporter.plist",
  ];

  return [NSURL fileURLWithPathComponents:pathComponents];
}

@end
