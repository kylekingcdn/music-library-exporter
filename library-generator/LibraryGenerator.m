//
//  LibraryGenerator.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-17.
//

#import "LibraryGenerator.h"

#import <iTunesLibrary/ITLibrary.h>
#import <iTunesLibrary/ITLibPlaylist.h>
#import <sys/ioctl.h>

#import "Logger.h"
#import "ArgParser.h"
#import "ExportConfiguration.h"
#import "LibraryFilter.h"
#import "LibrarySerializer.h"
#import "PlaylistNode.h"
#import "PlaylistTree.h"
#import "OrderedDictionary.h"


@interface LibraryGenerator ()

- (BOOL)isRunningInTerminal;

- (void)clearBuffer;
- (void)printStatus:(NSString*)message;
- (void)printStatusDone:(NSString*)message;

- (void)printPlaylistNode:(PlaylistNode*)node withIndent:(NSUInteger)indent;

- (void)drawProgressBarWithStatus:(NSString*)status forCurrentValue:(NSUInteger)currentVal andTotalValue:(NSUInteger)totalVal;

@end


@implementation LibraryGenerator {

  BOOL _printProgress;
  NSUInteger _termWidth;

  ITLibrary* _library;

  NSArray<ITLibMediaItem*>* _includedTracks;
  NSArray<ITLibPlaylist*>* _includedPlaylists;

  LibrarySerializer* _librarySerializer;
}


#pragma mark - Initializers -

- (instancetype)init {

  self = [super init];

  if ([self isRunningInTerminal]) {
    
    _printProgress = YES;

    // get terminal width
    struct winsize w;
    ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);
    _termWidth = w.ws_col;
  }

  else {
    _printProgress = NO;
  }

  return self;
}


#pragma mark - Accessors

- (void)printHelp {
  printf("library-generator");
  printf("\n");
  printf("\nUSAGE");
  printf("\n");
  printf("\n    library-generator <command> [options]");
  printf("\n");
  printf("\nCOMMANDS");
  printf("\n");
  printf("\n    help");
  printf("\n");
  printf("\n        Prints this (hopefully) helpful message");
  printf("\n");
  printf("\n    print");
  printf("\n");
  printf("\n        Prints the list of playlists in your library with their kind and 'Persistent ID'.");
  printf("\n        This command is essential for determining the ID for a playlist that you want to include in either --exclude_ids or --sort.");
  printf("\n        The print command also supports the playlist filtering options that are available for the export command (--exclude_ids <playlist_ids>, --exclude_internal, --flatten).");
  printf("\n        These can be helpful for previewing the list of playlists that will be included in an export when the filter options are applied.");
  printf("\n");
  printf("\n        Supported options:");
  printf("\n            --exclude_ids <playlist_ids>");
  printf("\n            --exclude_internal");
  printf("\n            --flatten");
  printf("\n");
  printf("\n    export");
  printf("\n");
  printf("\n        The export command handles the generation and saving of your XML library.");
  printf("\n");
  printf("\n        MANDATORY OPTIONS:");
  printf("\n            --music_media_dir  <music_media_dir>");
  printf("\n            --output_path  <path>");
  printf("\n");
  printf("\n        Supported options:");
  printf("\n            --flatten");
  printf("\n            --exclude_internal ");
  printf("\n            --exclude_ids  <playlist_ids>");
  printf("\n            --sort  <playlist_sorting_specifer>");
  printf("\n            --remap_search  <text_to_find>");
  printf("\n            --remap_replace  <replacement text>");
  printf("\n");
  printf("\nOPTIONS");
  printf("\n");
  printf("\n    --flatten, -f");
  printf("\n");
  printf("\n        Setting this flag will flatten the generated playlist hierarchy, or in other words, exclude any folders.");
  printf("\n        The playlists contained in any folders are still included in the exported library, they simply appear 'top-level'.");
  printf("\n        For an example of what this means, compare the output of 'library-generator print' to the output of 'library-generator print --flatten',");
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
  printf("\n        Playlist IDs can be determined by running the print command: 'library-generator print'");
  printf("\n");
  printf("\n        Example value:");
  printf("\n            --exclude_ids 1803375142671959318,5128334259688473588,57194740367344335011");
  printf("\n");
  printf("\n    --music_media_dir <music_media_dir>, -m <music_media_dir>");
  printf("\n");
  printf("\n        The value of this option MUST be set to the corresponding value in your Music app's Preferences.");
  printf("\n        It can be found under: Preferences > Files > Music Media folder location.");
  printf("\n        library-generator can NOT validate what is entered for this value, so it is important to ensure that it is accurate.");
  printf("\n");
  printf("\n        Example value:");
  printf("\n             --music_media_dir \"/Macintosh HD/Users/Kyle/Music/Music/Media\"");
  printf("\n");
  printf("\n    --output_path <path>, -o <path>");
  printf("\n");
  printf("\n        The desired output path of the generated library (directory and filename.");
  printf("\n        Export behaviour is undetermined when using file extensions other than '.xml'.");
  printf("\n        If you must change the extension: first run the export command and then run 'mv' afterwards to relocate it to the desired location.");
  printf("\n");
  printf("\n        Example value:");
  printf("\n            --output_path ~/Music/Music/GeneratedLibrary.xml");
  printf("\n");
  printf("\n    --sort <playlist_sorting_specifer>, -S <playlist_sorting_specifer>");
  printf("\n");
  printf("\n");
  printf("\n    --remap_search <text_to_find>, -s <text_to_find>");
  printf("\n");
  printf("\n");
  printf("\n    --remap_replace <replacement text>, -r <replacement text>");
  printf("\n\n");
}

- (void)printPlaylists {

  PlaylistTree* playlistTree = [[PlaylistTree alloc] init];
  [playlistTree setFlattened:_configuration.flattenPlaylistHierarchy];
  [playlistTree generateForSourcePlaylists:_includedPlaylists];

  // print playlists recursively via top-level
  for (PlaylistNode* childNode in playlistTree.rootNode.children) {
    [self printPlaylistNode:childNode withIndent:0];
  }
}

- (BOOL)isRunningInTerminal {

  NSString* term = [[[NSProcessInfo processInfo] environment] valueForKey:@"TERM"];
  if (term == nil) {
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

- (void)printPlaylistNode:(PlaylistNode*)node withIndent:(NSUInteger)indent {

  // TODO: add additional columns (e.g. kind)
  // TODO: determine column widths dynamically
  // TODO: elide column overflow text

  // indent
  for (NSUInteger i=2; i<indent; i++){
    putchar(' ');
  }

  int spacing = 30 - (int)indent;

  // print playlist description
  printf("- %-*s  %s\n", spacing, node.playlist.name.UTF8String, node.playlist.persistentID.stringValue.UTF8String);

  // call recursively on children, increasing indent w/ each level
  for (PlaylistNode* childNode in node.children) {
    [self printPlaylistNode:childNode withIndent:indent+2];
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


#pragma mark - Mutators -

- (BOOL)setupAndReturnError:(NSError**)error {

  MLE_Log_Info(@"LibraryGenerator [setupAndReturnError]");

  // init ITLibrary
  _library = [ITLibrary libraryWithAPIVersion:@"1.1" error:error];
  if (_library == nil) {
    return NO;
  }

  ArgParser* argParser = [ArgParser parserWithProcessInfo:[NSProcessInfo processInfo]];
  [argParser dumpArguments];
  
  // init signatures + XPMArgumentPackage
  [argParser parse];

  // validate command
  if (![argParser validateCommandAndReturnError:error]) {
    return NO;
  }

  _command = argParser.command;

  // display help
  if (_command == LGCommandKindHelp) {
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
  [ExportConfiguration initSharedConfig:_configuration];

  // init LibraryFilter to fetch included media items
  LibraryFilter* libraryFilter = [[LibraryFilter alloc] initWithLibrary:_library];
  _includedTracks = [libraryFilter getIncludedTracks];
  _includedPlaylists = [libraryFilter getIncludedPlaylists];

  return YES;
}

- (BOOL)exportLibraryAndReturnError:(NSError**)error {

  MLE_Log_Info(@"LibraryGenerator [exportLibraryAndReturnError]");

  /* prepare for export */

  [self printStatus:@"preparing for export"];
  LibrarySerializer* _librarySerializer = [[LibrarySerializer alloc] initWithLibrary:_library];
  [_librarySerializer initSerializeMembers];
  [self printStatusDone:@"preparing for export"];

  /* start export */
  [self printStatus:@"generating tracks"];
  OrderedDictionary* tracksDict;
  if (_printProgress) {
    // add track progress callback
    void (^trackProgressCallback)(NSUInteger,NSUInteger) = ^(NSUInteger trackIndex, NSUInteger trackCount){
      [self drawProgressBarWithStatus:@"generating tracks" forCurrentValue:trackIndex andTotalValue:trackCount];
    };
    tracksDict = [_librarySerializer serializeTracks:_includedTracks withProgressCallback:trackProgressCallback];
    [self clearBuffer];
  }
  else {
    tracksDict = [_librarySerializer serializeTracks:_includedTracks];
  }
  [self printStatusDone:@"generating tracks"];

  [self printStatus:@"generating playlists"];
  NSArray<OrderedDictionary*>* playlistsArr;
  if (_printProgress) {
    // add playlist progress callback
    void (^playlistProgressCallback)(NSUInteger,NSUInteger) = ^(NSUInteger playlistIndex, NSUInteger playlistCount){
      [self drawProgressBarWithStatus:@"generating playlists" forCurrentValue:playlistIndex andTotalValue:playlistCount];
    };
    playlistsArr = [_librarySerializer serializePlaylists:_includedPlaylists withProgressCallback:playlistProgressCallback];
    [self clearBuffer];
  }
  else {
    playlistsArr = [_librarySerializer serializePlaylists:_includedPlaylists];
  }
  [self printStatusDone:@"generating playlists"];
  
  [self printStatus:@"generating library"];
  OrderedDictionary* libraryDict = [_librarySerializer serializeLibraryforTracks:tracksDict andPlaylists:playlistsArr];
  [self printStatusDone:@"generating library"];

  [self printStatus:@"writing to file"];
  BOOL writeSuccess = [libraryDict writeToURL:_configuration.outputFileUrl error:error];
  if (!writeSuccess) {
    return NO;
  }
  [self printStatusDone:@"writing to file"];

  return YES;
}


@end
