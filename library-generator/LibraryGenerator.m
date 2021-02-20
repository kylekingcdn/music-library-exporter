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

- (void)clearBuffer;
- (void)printStatus:(NSString*)message;

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

- (void)printHelp {

  printf("Usage: library-generator <command> [options]\n");
  // TODO: finish me
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

- (void)printPlaylists {

  PlaylistTree* playlistTree = [[PlaylistTree alloc] init];
  [playlistTree setFlattened:_configuration.flattenPlaylistHierarchy];
  [playlistTree generateForSourcePlaylists:_includedPlaylists];

  // print playlists recursively via top-level
  for (PlaylistNode* childNode in playlistTree.rootNode.children) {
    [self printPlaylistNode:childNode withIndent:0];
  }
}

- (void)printPlaylistNode:(PlaylistNode*)node withIndent:(NSUInteger)indent {

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
