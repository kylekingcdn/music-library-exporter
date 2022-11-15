//
//  CLIDefines.m
//  music-library-exporter
//
//  Created by Kyle King on 2021-02-15.
//

#import "CLIDefines.h"


@implementation CLIDefines

+ (NSArray<NSNumber*>*)optionsForCommand:(CLICommandKind)command {

  switch (command) {

    case CLICommandKindHelp: {
      return @[
        @(CLIOptionKindHelp)
      ];
    }

    case CLICommandKindVersion: {
      return @[
        @(CLIOptionKindVersion)
      ];
    }

    case CLICommandKindPrint: {
      return @[
        @(CLIOptionKindHelp),
        @(CLIOptionKindReadPrefs),
        @(CLIOptionKindFlatten),
        @(CLIOptionKindExcludeInternal),
        @(CLIOptionKindExcludeIds),
      ];
    }

    case CLICommandKindExport: {
      return @[
        @(CLIOptionKindHelp),
        @(CLIOptionKindReadPrefs),
        @(CLIOptionKindFlatten),
        @(CLIOptionKindExcludeInternal),
        @(CLIOptionKindExcludeIds),
        @(CLIOptionKindMusicMediaDirectory),
        @(CLIOptionKindSort),
        @(CLIOptionKindRemapSearch),
        @(CLIOptionKindRemapReplace),
        @(CLIOptionKindRemapLocalhostPrefix),
        @(CLIOptionKindOutputPath),
      ];
    }

    case CLICommandKindUnknown: {
      return @[
        @(CLIOptionKindHelp)
      ];
    }
  }
}

+ (NSArray<NSNumber*>*)requiredOptionsForCommand:(CLICommandKind)command {

  switch (command) {

    case CLICommandKindHelp: {
      return @[ ];
    }

    case CLICommandKindVersion: {
      return @[ ];
    }

    case CLICommandKindPrint: {
      return @[ ];
    }

    case CLICommandKindExport: {
      return @[
        @(CLIOptionKindMusicMediaDirectory),
        @(CLIOptionKindOutputPath),
      ];
    }

    case CLICommandKindUnknown: {
      return @[ ];
    }
  }
}

+ (nullable NSString*)nameForCommand:(CLICommandKind)command {

  switch (command) {
    case CLICommandKindHelp: {
      return @"help";
    }
    case CLICommandKindVersion: {
      return @"version";
    }
    case CLICommandKindPrint: {
      return @"print";
    }
    case CLICommandKindExport: {
      return @"export";
    }
    case CLICommandKindUnknown: {
      return nil;
    }
  }
}

+ (nullable NSString*)nameForOption:(CLIOptionKind)option {

  switch (option) {

    case CLIOptionKindHelp: {
      return @"--help";
    }
    case CLIOptionKindVersion: {
      return @"--version";
    }

    case CLIOptionKindReadPrefs: {
      return @"--read_prefs";
    }

    case CLIOptionKindFlatten: {
      return @"--flatten";
    }
    case CLIOptionKindExcludeInternal: {
      return @"--exclude_internal";
    }
    case CLIOptionKindExcludeIds: {
      return @"--exclude_ids";
    }

    case CLIOptionKindMusicMediaDirectory: {
      return @"--music_media_dir";
    }
    case CLIOptionKindSort: {
      return @"--sort";
    }
    case CLIOptionKindRemapSearch: {
      return @"--remap_search";
    }
    case CLIOptionKindRemapReplace: {
      return @"--remap_replace";
    }
    case CLIOptionKindRemapLocalhostPrefix: {
      return @"--localhost_path_prefix";
    }
    case CLIOptionKindOutputPath: {
      return @"--output_path";
    }

    case CLIOptionKind_MAX: {
      return nil;
    }
  }
}

+ (nullable NSString*)nameAndValueForOption:(CLIOptionKind)option {

  NSString* optionName = [CLIDefines nameForOption:option];

  switch (option) {

    case CLIOptionKindExcludeIds: {
      optionName = [optionName stringByAppendingString:@" <playlist_ids>"];
      break;
    }
    case CLIOptionKindMusicMediaDirectory: {
      optionName = [optionName stringByAppendingString:@" <music_dir>"];
      break;
    }
    case CLIOptionKindSort: {
      optionName = [optionName stringByAppendingString:@" <playlist_sorting_value>"];
      break;
    }
    case CLIOptionKindRemapSearch: {
      optionName = [optionName stringByAppendingString:@" <text_to_find>"];
      break;
    }
    case CLIOptionKindRemapReplace: {
      optionName = [optionName stringByAppendingString:@" <replacement_text>"];
      break;
    }
    case CLIOptionKindOutputPath: {
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

  for (CLICommandKind command = CLICommandKindHelp; command < CLICommandKindUnknown; command++) {
    [names addObject:[CLIDefines nameForCommand:command]];
  }

  return names;
}

+ (nullable NSString*)signatureFormatForCommand:(CLICommandKind)command {

  switch (command) {

    case CLICommandKindHelp: {
      return @"[-h --help help]";
    }
    case CLICommandKindVersion: {
      return @"[-v --version version]";
    }
    case CLICommandKindPrint: {
      return @"[print]";
    }
    case CLICommandKindExport: {
      return @"[export]";
    }

    case CLICommandKindUnknown: {
      return nil;
    }
  }
}

+ (nullable NSString*)signatureFormatForOption:(CLIOptionKind)option {

  switch (option) {

    case CLIOptionKindHelp: {
      return [CLIDefines signatureFormatForCommand:CLICommandKindHelp];
    }

    case CLIOptionKindVersion: {
      return [CLIDefines signatureFormatForCommand:CLICommandKindVersion];
    }

    case CLIOptionKindReadPrefs: {
      return @"[-p --read_prefs]";
    }

    case CLIOptionKindFlatten: {
      return @"[-f --flatten]";
    }
    case CLIOptionKindExcludeInternal: {
      return @"[-n --exclude_internal]";
    }
    case CLIOptionKindExcludeIds: {
      return @"[-e --exclude_ids]={1,1}";
    }

    case CLIOptionKindMusicMediaDirectory: {
      return @"[-m --music_media_dir]={1,1}";
    }
    case CLIOptionKindSort: {
      return @"[--sort]={1,1}";
    }
    case CLIOptionKindRemapSearch: {
      return @"[-s --remap_search]={1,1}";
    }
    case CLIOptionKindRemapReplace: {
      return @"[-r --remap_replace]={1,1}";
    }
    case CLIOptionKindRemapLocalhostPrefix: {
      return @"[--localhost_path_prefix]";
    }
    case CLIOptionKindOutputPath: {
      return @"[-o --output_path]={1,1}";
    }

    case CLIOptionKind_MAX: {
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
