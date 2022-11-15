//
//  CLIManager.m
//  music-library-exporter
//
//  Created by Kyle King on 2021-02-17.
//

#import "CLIManager.h"

#import <iTunesLibrary/ITLibPlaylist.h>
#import <sys/ioctl.h>

#import "Logger.h"
#import "ArgParser.h"
#import "ExportConfiguration.h"
#import "ExportManager.h"
#import "PlaylistTreeNode.h"
#import "PlaylistTreeGenerator.h"
#import "OrderedDictionary.h"
#import "Utils.h"
#import "PlaylistFilterGroup.h"
#import "PlaylistParentIDFilter.h"


@interface CLIManager ()

+ (BOOL)isRunningInTerminal;

- (BOOL)validateExportConfigurationAndReturnError:(NSError**)error;
- (BOOL)validateOutputPathAndReturnError:(NSError**)error;
- (BOOL)validateMusicMediaDirectoryAndReturnError:(NSError**)error;
- (BOOL)validatePathMappingAndReturnError:(NSError**)error;

- (void)clearBuffer;
- (void)printStatus:(NSString*)message;
- (void)printStatusDone:(NSString*)message;

- (NSUInteger)playlistColumnWidthForTree:(PlaylistTreeNode*)playlistTree;
- (NSUInteger)playlistColumnWidthForNode:(PlaylistTreeNode*)node forIndent:(NSUInteger)indent;
- (void)printPlaylistNode:(PlaylistTreeNode*)node withIndent:(NSUInteger)indent forTitleColumnWidth:(NSUInteger)titleColumnWidth;

- (void)drawProgressBarWithStatus:(NSString*)status forCurrentValue:(NSUInteger)currentVal andTotalValue:(NSUInteger)totalVal;

@end


@implementation CLIManager {

  PlaylistParentIDFilter* _playlistParentIDFilter;

  BOOL _printProgress;
  NSUInteger _termWidth;
}

NSErrorDomain const __MLE_ErrorDomain_CLIManager = @"com.kylekingcdn.MusicLibraryExporter.CLIManagerErrorDomain";

NSUInteger const __MLE_PlaylistTableIndentPerLevel = 2;
NSUInteger const __MLE_PlaylistTableMaxWidth = 100;
NSUInteger const __MLE_PlaylistTableColumnMargin = 2;


#pragma mark - Initializers

- (instancetype)init {

  if (self = [super init]) {

    _playlistParentIDFilter = nil;

    if ([CLIManager isRunningInTerminal]) {

      _printProgress = YES;

      // get terminal width
      struct winsize w;
      ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
      _termWidth = w.ws_col;
    }

    else {
      _printProgress = NO;
      _termWidth = 100;
    }

    return self;
  }
  else {
    return nil;
  }
}


#pragma mark - Accessors

- (void)printHelp {
  printf("music-library-exporter");
  printf("\n");
  printf("\nUSAGE");
  printf("\n");
  printf("\n    music-library-exporter <command> [options]");
  printf("\n");
  printf("\nCOMMANDS");
  printf("\n");
  printf("\n    help");
  printf("\n");
  printf("\n        Prints this message");
  printf("\n");
  printf("\n    version");
  printf("\n");
  printf("\n        Displays the current version of music-library-exporter.");
  printf("\n");
  printf("\n    print");
  printf("\n");
  printf("\n        Prints the list of playlists in your library with their kind and 'Persistent ID'.");
  printf("\n        This command is essential for determining the ID for a playlist that you want to include in either --exclude_ids or --sort.");
  printf("\n        The print command also supports the playlist filtering options that are available for the export command (--exclude_ids <playlist_ids>, --exclude_internal, --flatten).");
  printf("\n        These can be helpful for previewing the list of playlists that will be included in a customized export.");
  printf("\n");
  printf("\n        Supported options:");
  printf("\n            --read_prefs");
  printf("\n            --flatten");
  printf("\n            --exclude_internal");
  printf("\n            --exclude_ids  <playlist_ids>");
  printf("\n");
  printf("\n    export");
  printf("\n");
  printf("\n        The export command handles the generation of your XML library.");
  printf("\n");
  printf("\n        Supported options:");
  printf("\n            --read_prefs");
  printf("\n            --music_media_dir  <music_media_dir>");
  printf("\n            --output_path  <path>");
  printf("\n            --flatten");
  printf("\n            --exclude_internal ");
  printf("\n            --exclude_ids  <playlist_ids>");
  printf("\n            --sort  <playlist_sorting_specifers>");
  printf("\n            --remap_search  <text_to_find>");
  printf("\n            --remap_replace  <replacement text>");
  printf("\n");
  printf("\nOPTIONS");
  printf("\n");
  printf("\n    --read_prefs");
  printf("\n");
  printf("\n        Allows for importing settings from the Music Library Exporter app's preferences.");
  printf("\n        Specifying additional options will override the corresponding app preference.");
  printf("\n");
  printf("\n    --music_media_dir <music_media_dir>, -m <music_media_dir>");
  printf("\n");
  printf("\n        The value of this option MUST be set to the corresponding value in your Music app's Preferences.");
  printf("\n        It can be found under: Preferences > Files > Music Media folder location.");
  printf("\n        music-library-exporter can NOT validate what is entered for this value, so it is important to ensure that it is accurate.");
  printf("\n");
  printf("\n        NOTE: This option is mandatory unless the value is being imported via --read_prefs.");
  printf("\n");
  printf("\n        Example value:");
  printf("\n             --music_media_dir \"/Users/kyle/Music/Music/Media\"");
  printf("\n");
  printf("\n    --output_path <path>, -o <path>");
  printf("\n");
  printf("\n        The desired output path of the generated library (directory and filename).");
  printf("\n        Export behaviour is undetermined when using file extensions other than '.xml'.");
  printf("\n        If you must change the extension: first run the export command and then run 'mv' afterwards to relocate it to the desired location.");
  printf("\n");
  printf("\n        NOTE: This option is mandatory unless the value is being imported via --read_prefs.");
  printf("\n");
  printf("\n        Example value:");
  printf("\n            --output_path ~/Music/Music/GeneratedLibrary.xml");
  printf("\n");
  printf("\n    --flatten, -f");
  printf("\n");
  printf("\n        Setting this flag will flatten the generated playlist hierarchy, or in other words, folders will not be included.");
  printf("\n        The playlists contained in any folders are still included in the exported library, they simply appear 'top-level'.");
  printf("\n        For an example of what this means, compare the output of 'music-library-exporter print' to the output of 'music-library-exporter print --flatten',");
  printf("\n        (Note: there will only be an observable difference if you are managing your music library's playlists with folders).");
  printf("\n");
  printf("\n    --exclude_internal, -n");
  printf("\n");
  printf("\n        If set, this flag will prevent any internal playlists from being included in the exported library.");
  printf("\n        Internal playlists include (but are not limited to): 'Library', 'Music', 'Downloaded', etc...");
  printf("\n");
  printf("\n    --exclude_ids <playlist_ids>, -e <playlist_ids>");
  printf("\n");
  printf("\n        A comma separated list of playlist ids that you would like to exclude from the generated library.");
  printf("\n        Playlist IDs can be determined by running the print command: 'music-library-exporter print'");
  printf("\n");
  printf("\n        Example value:");
  printf("\n            --exclude_ids 1803375142671959318,5128334259688473588,57194740367344335011");
  printf("\n");
  printf("\n    --sort <playlist_sorting_specifers>");
  printf("\n");
  printf("\n        A comma separated list of 'playlist sort specifier's.");
  printf("\n        This option allows you to override the sorting of individual playlists.");
  printf("\n");
  printf("\n        A playlist sort specifier has the following format:");
  printf("\n            {PLAYLIST_ID}:{SORT_COLUMN}-{SORT_ORDER}");
  printf("\n");
  printf("\n        Where:");
  printf("\n            PLAYLIST_ID  is the persistent ID of the playlist. Playlist IDs can be found with: 'music-library-exporter print'");
  printf("\n            SORT_COLUMN  is one of the following:  'title', 'artist', 'albumartist', 'dateadded'");
  printf("\n            SORT_ORDER   is either 'a' (for ascending) or 'd' (for descending)");
  printf("\n");
  printf("\n        Example value:");
  printf("\n            --sort \"3245022223634E16:title-a,3FD8F8235DE3C8C9:dateadded-d\"");
  printf("\n");
  printf("\n    --remap_search <text_to_find>, -s <text_to_find>");
  printf("\n");
  printf("\n        Specify the text you would like removed/replaced in each song's filepath.");
  printf("\n        Using the remap option allows you to change the the root music directory in the filepath for each track in your library.");
  printf("\n        This is especially useful when you are using your generted XML library in a remote or containerized environment (e.g. Plex)");
  printf("\n");
  printf("\n        Example value:");
  printf("\n            --remap_search \"/Users/kyle/Music/Music/Media.localized/Music\" --remap_replace \"/data/music\"");
  printf("\n");
  printf("\n    --remap_replace <replacement text>, -r <replacement text>");
  printf("\n");
  printf("\n        Specify the new text you would like to use in each song's filepath.");
  printf("\n        If included, you must also specify the --remap_search option.");
  printf("\n        For example usage, please see the information for the --remap_search option above.");
  printf("\n");
  printf("\n    --localhost_path_prefix");
  printf("\n");
  printf("\n        Enabling this flag will prefix all track location paths with 'localhost'.");
  printf("\n        This option is compatible with path remapping.");
  printf("\n");
  printf("\n        Note: this option will only be needed and/or useful in a very limited set of environments (e.g. Plex on Synology).");
  printf("\n");
  printf("\n        Example result:");
  printf("\n            Track paths will be generated as 'file://localhost/Path/to/track.mp3' rather than 'file:///Path/to/track.mp3'.");
  printf("\n\n");
}

- (void)printVersion {

  printf("music-library-exporter %s\n", [LG_VERSION UTF8String]);
}

- (void)printPlaylists {

  // init playlist filters
  PlaylistFilterGroup* playlistFilterGroup = [[PlaylistFilterGroup alloc]
                                              initWithBaseFiltersAndIncludeInternal:_configuration.includeInternalPlaylists
                                              andFlattenPlaylists:_configuration.flattenPlaylistHierarchy];

  _playlistParentIDFilter = [playlistFilterGroup addFiltersForExcludedIDs:_configuration.excludedPlaylistPersistentIds
                                                      andFlattenPlaylists:_configuration.flattenPlaylistHierarchy];


  PlaylistTreeGenerator* generator = [[PlaylistTreeGenerator alloc] initWithFilters:playlistFilterGroup];
  [generator setFlattenFolders:_configuration.flattenPlaylistHierarchy];

  PlaylistTreeNode* playlistTree = [generator generateTreeWithError:nil];

  NSUInteger tableWidth = MIN(_termWidth, __MLE_PlaylistTableMaxWidth);
  NSUInteger idColumnWidth = __MLE_PlaylistTableColumnMargin + 16 + __MLE_PlaylistTableColumnMargin;
  NSUInteger kindColumnWidth = __MLE_PlaylistTableColumnMargin + 14 + __MLE_PlaylistTableColumnMargin;
  NSUInteger titleColumnMaxWidth = tableWidth - idColumnWidth - kindColumnWidth;
  NSUInteger titleColumnWidth = MIN([self playlistColumnWidthForTree:playlistTree], titleColumnMaxWidth);
  tableWidth = MIN(tableWidth, titleColumnWidth + idColumnWidth + kindColumnWidth);

  // print header row
  printf(" %-*s|  %-*s|  %-*s|\n", (int)titleColumnWidth-2, "Title", (int)idColumnWidth-3, "Playlist ID", (int)kindColumnWidth-3, "Playlist Kind");
  for (int  i=0; i<tableWidth; i++) {
    putchar('-');
  }
  printf("\n");


  for (PlaylistTreeNode* childNode in playlistTree.children) {
    [self printPlaylistNode:childNode withIndent:0 forTitleColumnWidth:titleColumnWidth];
  }
}

+ (BOOL)isRunningInTerminal {

  NSString* term = [[[NSProcessInfo processInfo] environment] valueForKey:@"TERM"];
  if (term == nil) {
    return NO;
  }

  return YES;
}

- (BOOL)validateExportConfigurationAndReturnError:(NSError**)error {

  if (![self validateOutputPathAndReturnError:error]) {
    return NO;
  }

  if (![self validateMusicMediaDirectoryAndReturnError:error]) {
    return NO;
  }

  if (![self validatePathMappingAndReturnError:error]) {
    return NO;
  }

  return YES;
}

- (BOOL)validateOutputPathAndReturnError:(NSError**)error {

  NSURL* filePathUrl = _configuration.outputFileUrl;

  NSString* filePath = filePathUrl.path;
  if (filePath == nil || filePath.length == 0) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_CLIManager code:CLIManagerErrorInvalidOutputPath userInfo:@{
        NSLocalizedDescriptionKey:@"Error: The value for --output_path is empty",
      }];
    }
    return NO;
  }

  NSFileManager* fileManager = [NSFileManager defaultManager];

  BOOL pathIsDirectory;
  BOOL pathExists = [fileManager fileExistsAtPath:filePath isDirectory:&pathIsDirectory];

  if (pathExists) {

    if (pathIsDirectory) {
      if (error) {
        *error = [NSError errorWithDomain:__MLE_ErrorDomain_CLIManager code:CLIManagerErrorInvalidOutputPath userInfo:@{
          NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Error: The --output_path option requires a filename. Please include a file name in your output path: %@", filePath],
        }];
      }
      return NO;
    }

    BOOL pathIsWritable = [fileManager isWritableFileAtPath:filePath];
    if (!pathIsWritable) {
      if (error) {
        *error = [NSError errorWithDomain:__MLE_ErrorDomain_CLIManager code:CLIManagerErrorInvalidOutputPath userInfo:@{
          NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Error: The specified output path is not writable: %@", filePath],
        }];
      }
      return NO;
    }

    return YES;
  }
  else {

    NSString* pathParent = [filePath stringByDeletingLastPathComponent];
    BOOL pathParentIsDirectory;
    BOOL pathParentExists = [fileManager fileExistsAtPath:pathParent isDirectory:&pathParentIsDirectory];

    if (!pathParentExists) {
      if (error) {
        *error = [NSError errorWithDomain:__MLE_ErrorDomain_CLIManager code:CLIManagerErrorInvalidOutputPath userInfo:@{
          NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Error: The output path's parent directory doesn't exist: %@", pathParent],
        }];
      }
      return NO;
    }

    else if (!pathParentIsDirectory) {
      if (error) {
        *error = [NSError errorWithDomain:__MLE_ErrorDomain_CLIManager code:CLIManagerErrorInvalidOutputPath userInfo:@{
          NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Error: The specified output path is not valid as it's parent is not a directory: %@", pathParent],
        }];
      }
      return NO;
    }

    BOOL pathParentIsWritable = [fileManager isWritableFileAtPath:pathParent];
    if (!pathParentIsWritable) {
      if (error) {
        *error = [NSError errorWithDomain:__MLE_ErrorDomain_CLIManager code:CLIManagerErrorInvalidOutputPath userInfo:@{
          NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Error: The parent directory of the specified output path is not writable: %@", pathParent],
        }];
      }
      return NO;
    }
  }

  return YES;
}

- (BOOL)validateMusicMediaDirectoryAndReturnError:(NSError**)error {

  NSString* musicDirPath = _configuration.musicLibraryPath;
  if (musicDirPath == nil || musicDirPath.length == 0) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_CLIManager code:CLIManagerErrorInvalidMusicMediaDirectory userInfo:@{
        NSLocalizedDescriptionKey:@"Error: The value for --music_media_dir is empty",
      }];
    }
    return NO;
  }

  return YES;
}

- (BOOL)validatePathMappingAndReturnError:(NSError**)error {

  NSString* remapSearchPath = _configuration.remapRootDirectoryOriginalPath;
  NSString* remapMappedPath = _configuration.remapRootDirectoryMappedPath;

  BOOL hasSearchPath = (remapSearchPath && remapSearchPath.length > 0);
  BOOL hasMappedPath = (remapMappedPath && remapMappedPath.length > 0);

  if (hasMappedPath && !hasSearchPath) {
    if (error) {
      *error = [NSError errorWithDomain:__MLE_ErrorDomain_CLIManager code:CLIManagerErrorInvalidMusicMediaDirectory userInfo:@{
        NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Error: A value for --remap_search is required if a value for --remap_replace (%@) is given. Please specify the text to find (--remap_search) along with your replacement text (--remap_replace)", remapMappedPath],
      }];
    }
    return NO;
  }

  return YES;
}

- (void)clearBuffer {

  printf("\r");

  NSUInteger bufferLen = MIN(100,_termWidth);
  for (NSUInteger i=0; i<bufferLen; i++){
    putchar(' ');
  }
}

- (void)printStatus:(NSString*)message {

  printf("%s...", message.UTF8String);
  fflush(stdout);
}

- (void)printStatusDone:(NSString*)message {

  if (_printProgress) {
    printf("\r%s...", message.UTF8String);
  }
  printf(" done\n");
  fflush(stdout);
}

- (NSUInteger)playlistColumnWidthForTree:(PlaylistTreeNode*)playlistTree {

  return [self playlistColumnWidthForNode:playlistTree forIndent:0];
}

- (NSUInteger)playlistColumnWidthForNode:(PlaylistTreeNode*)node forIndent:(NSUInteger)indent {

  NSUInteger widthForNode = 0;
  if (node.playlistName) {
    widthForNode = indent + node.playlistName.length + 2; // + 2 for '- ' prefix
  }

  for (PlaylistTreeNode* childNode in node.children) {
    widthForNode = MAX(widthForNode, [self playlistColumnWidthForNode:childNode forIndent:indent + __MLE_PlaylistTableIndentPerLevel]);
  }

  return widthForNode;
}

- (void)printPlaylistNode:(PlaylistTreeNode*)node withIndent:(NSUInteger)indent forTitleColumnWidth:(NSUInteger)titleColumnWidth {

  // indent
  for (NSUInteger i=0; i<indent; i++){
    putchar(' ');
  }

  NSUInteger titleLength = MAX(4,  (titleColumnWidth - indent - 3));
  NSString* formattedTitle = node.playlistName;
  if (formattedTitle.length > titleLength) {
    formattedTitle = [NSString stringWithFormat:@"%@...",[node.playlistName substringToIndex:titleLength-3]];
  }

  // title
  printf(" - %-*s", (int)titleLength, formattedTitle.UTF8String);

  // id
  for (int i=0; i<__MLE_PlaylistTableColumnMargin; i++) { putchar(' '); }
  printf("%-*s", 16 + (int)__MLE_PlaylistTableColumnMargin, node.playlistPersistentHexID.UTF8String);

  // kind
  for (int i=0; i<__MLE_PlaylistTableColumnMargin; i++) { putchar(' '); }
  printf("%-*s", 14 + (int)__MLE_PlaylistTableColumnMargin, node.kindDescription.UTF8String);

  printf("\n");

  // call recursively on children, increasing indent w/ each level
  for (PlaylistTreeNode* childNode in node.children) {
    [self printPlaylistNode:childNode withIndent:indent+__MLE_PlaylistTableIndentPerLevel forTitleColumnWidth:titleColumnWidth];
  }
}

- (void)drawProgressBarWithStatus:(NSString*)status forCurrentValue:(NSUInteger)currentVal andTotalValue:(NSUInteger)totalVal {

  NSUInteger totalSize = MIN(_termWidth,100);

  NSUInteger statusSize = status.length + 4; // 4 extra for '... '

  NSUInteger totalValueDigits = ceil(log10(totalVal));
  NSUInteger progressSize = totalValueDigits + 1 + totalValueDigits + 1; // '  4/100 '

  NSUInteger bordersSize = 2; // edges of progress bar: '['']'
  NSUInteger percentageSize = 4; // ' 100%'

  NSUInteger barSize = totalSize - (statusSize + progressSize + bordersSize + percentageSize);

  NSUInteger barFillAmt = (barSize * currentVal) / totalVal;
  NSUInteger barEmptyAmt = barSize - barFillAmt;

  // progress fraction
  printf("\r%s... %*li/%li ", status.UTF8String, (int)totalValueDigits, currentVal, totalVal);

  // progress bar
  putchar('[');
  for (NSUInteger i=0; i<barFillAmt; i++){
      putchar('=');
  }
  for (NSUInteger i=0; i<barEmptyAmt; i++){
      putchar(' ');
  }
  putchar(']');

  // percentage
  NSUInteger percentComplete = (99 * currentVal)/totalVal; // don't let it reach 100%
  printf(" %2li%%", percentComplete);

  fflush(stdout);
}


#pragma mark - Mutators

- (BOOL)setupAndReturnError:(NSError**)error {

  MLE_Log_Info(@"CLIManager [setupAndReturnError]");

  ArgParser* argParser = [[ArgParser alloc] initWithProcessInfo:[NSProcessInfo processInfo]];
  [argParser dumpArguments];
  
  // init signatures + XPMArgumentPackage
  [argParser parse];

  // validate command
  if (![argParser validateCommandAndReturnError:error]) {
    return NO;
  }

  _command = argParser.command;

  // display help
  if (_command == CLICommandKindHelp) {
    return YES;
  }

  // display version
  if (_command == CLICommandKindVersion) {
    return YES;
  }

  // validate options
  if (![argParser validateOptionsAndReturnError:error]) {
    return NO;
  }

  // generate config
  _configuration = [[ExportConfiguration alloc] init];
  if (![argParser populateExportConfiguration:_configuration error:error]) {
    return NO;
  }

  // extended configuration validation
  switch (_command) {
    case CLICommandKindHelp:
    case CLICommandKindPrint:
    case CLICommandKindVersion:
    case CLICommandKindUnknown: {
      break;
    }
    case CLICommandKindExport: {
      if (![self validateExportConfigurationAndReturnError:error]) {
        return NO;
      }
      break;
    }
  }

  return YES;
}

- (BOOL)exportLibraryAndReturnError:(NSError**)error {

  MLE_Log_Info(@"CLIManager [exportLibraryAndReturnError]");

  ExportManager* exportManager = [[ExportManager alloc] initWithConfiguration:_configuration];
  [exportManager setDelegate:self];
  [exportManager setOutputFileURL:_configuration.outputFileUrl];

  NSError* exportError;
  return [exportManager exportLibraryWithError:&exportError];
}


#pragma mark - ExportManagerDelegate

- (void) exportStateChangedFrom:(ExportState)oldState toState:(ExportState)newState {

  switch (oldState) {
    case ExportFinished:
    case ExportStopped:
    case ExportError: {
      break;
    }
    case ExportPreparing: {
      [self printStatusDone:@"preparing for export"];
      break;
    }
    case ExportGeneratingTracks: {
      if (_printProgress) {
        [self clearBuffer];
      }
      [self printStatusDone:@"generating tracks"];
      break;
    }
    case ExportGeneratingPlaylists: {
      if (_printProgress) {
        [self clearBuffer];
      }
      [self printStatusDone:@"generating playlists"];
      break;
    }
    case ExportGeneratingLibrary: {
      [self printStatusDone:@"generating library"];
      break;
    }
    case ExportWritingToDisk: {
      [self printStatusDone:@"writing to file"];
      break;
    }
  }

  switch (newState) {
    case ExportFinished:
    case ExportStopped:
    case ExportError: {
      break;
    }
    case ExportPreparing: {
      [self printStatus:@"preparing for export"];
      break;
    }
    case ExportGeneratingTracks: {
      [self printStatus:@"generating tracks"];
      break;
    }
    case ExportGeneratingPlaylists: {
      [self printStatus:@"generating playlists"];
      break;
    }
    case ExportGeneratingLibrary: {
      [self printStatus:@"generating library"];
      break;
    }
    case ExportWritingToDisk: {
      [self printStatus:@"writing to file"];
      break;
    }
  }
}

- (void) exportedItems:(NSUInteger)exportedItems ofTotal:(NSUInteger)totalItems {

  if (_printProgress) {
    [self drawProgressBarWithStatus:@"generating tracks" forCurrentValue:exportedItems andTotalValue:totalItems];
  }
}

- (void) exportedPlaylists:(NSUInteger)exportedPlaylists ofTotal:(NSUInteger)totalPlaylists {

  if (_printProgress) {
    [self drawProgressBarWithStatus:@"generating playlists" forCurrentValue:exportedPlaylists andTotalValue:totalPlaylists];
  }
}

- (void)excludedPlaylist:(ITLibPlaylist*)playlist {

  if (_playlistParentIDFilter != nil) {
    [_playlistParentIDFilter addExcludedID:playlist.persistentID];
  }
}


@end
