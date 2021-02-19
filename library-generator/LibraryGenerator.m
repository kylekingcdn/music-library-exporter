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
  if (!term) {
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
//    printf("\r%-80s"," ");
//    [self clearBuffer];
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
  NSUInteger percentageSize = 5; // ' 100%'

  NSUInteger barSize = totalSize - (statusSize + progressSize + bordersSize + percentageSize) /*borders*/; // todo: dynamic

  NSUInteger barFillAmt = (barSize * currentVal) / totalVal;
  NSUInteger barEmptyAmt = barSize - barFillAmt;


//  NSLog(@"statusSize: %li", statusSize);
//  NSLog(@"progressSize: %li", progressSize);
//  NSLog(@"percentageSize: %li", percentageSize);


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
  NSUInteger percentComplete = (100 * currentVal) / totalVal;
  printf(" %3li%%", percentComplete);
//  putchar('%');

  fflush(stdout);
}

- (void)printPlaylists {

  // TODO: handle hierarchy
  for (ITLibPlaylist* currPlaylist in _includedPlaylists) {
    printf("%-30s  %s\n", currPlaylist.name.UTF8String, currPlaylist.persistentID.stringValue.UTF8String);
  }
}


#pragma mark - Mutators -

- (nullable NSError*)setup {

  MLE_Log_Info(@"LibraryGenerator [setup]");

  // init ITLibrary
  NSError* libraryError;
  _library = [ITLibrary libraryWithAPIVersion:@"1.1" error:&libraryError];
  if (!_library) {
    return libraryError;
  }

  ArgParser* argParser = [ArgParser parserWithProcessInfo:[NSProcessInfo processInfo]];

  // parse args
  [argParser parse];

// TODO: use NSError directly
  // validate command
  if (![argParser validateCommand]) {
    return [NSError errorWithDomain:__MLE__AppBundleIdentifier code:3 userInfo:@{ NSLocalizedDescriptionKey:argParser.commandError }];
  }

  _command = argParser.command;

  // display help
  if (_command == LGCommandKindHelp) {
    return nil;
  }

// TODO: use NSError directly
  // validate options
  if (![argParser validateOptions]) {
    NSString* errorMessage = argParser.optionsError;
    if (argParser.optionsWithErrors) {
      errorMessage = [NSString stringWithFormat:@"%@:\n  %@", errorMessage, [argParser.optionsWithErrors componentsJoinedByString:@"\n  "]];
    }
    return [NSError errorWithDomain:__MLE__AppBundleIdentifier code:3 userInfo:@{ NSLocalizedDescriptionKey:errorMessage }];
  }

// TODO: use NSError directly
  // generate config
  _configuration = [[ExportConfiguration alloc] init];
  if (![argParser populateExportConfiguration:_configuration]) {
    return [NSError errorWithDomain:__MLE__AppBundleIdentifier code:3 userInfo:@{ NSLocalizedDescriptionKey:@"An internal error occured while interpreting configuration options" }];
  }
  [ExportConfiguration initSharedConfig:_configuration];

  // init LibraryFilter to fetch included media items
  LibraryFilter* libraryFilter = [[LibraryFilter alloc] initWithLibrary:_library];
  _includedTracks = [libraryFilter getIncludedTracks];
  _includedPlaylists = [libraryFilter getIncludedPlaylists];

  return nil;
}

- (nullable NSError*)exportLibrary {

  MLE_Log_Info(@"LibraryGenerator [exportLibrary]");

  /* prepare for export */

  [self printStatus:@"preparing for export"];
  LibrarySerializer* _librarySerializer = [[LibrarySerializer alloc] initWithLibrary:_library];
  [_librarySerializer initSerializeMembers];
  [self printStatusDone:@"preparing for export"];

  /* start export */
  [self printStatus:@"generating tracks"];
  OrderedDictionary* tracksDict;
  if (_printProgress) {
    // add progress callback
    NSUInteger totalValue = _includedTracks.count;
    void (^progressCallback)(NSUInteger) = ^(NSUInteger currentValue){
      [self drawProgressBarWithStatus:@"generating tracks" forCurrentValue:currentValue andTotalValue:totalValue];
    };
    tracksDict = [_librarySerializer serializeTracks:_includedTracks withProgressCallback:progressCallback];
    [self clearBuffer];
  }
  else {
    tracksDict = [_librarySerializer serializeTracks:_includedTracks];
  }
  [self printStatusDone:@"generating tracks"];

  [self printStatus:@"generating playlists"];
  NSArray<OrderedDictionary*>* playlistsArr = [_librarySerializer serializePlaylists:_includedPlaylists];
  [self printStatusDone:@"generating playlists"];
  
  [self printStatus:@"generating library"];
  OrderedDictionary* libraryDict = [_librarySerializer serializeLibraryforTracks:tracksDict andPlaylists:playlistsArr];
  [self printStatusDone:@"generating library"];

  [self printStatus:@"writing to file"];
  BOOL writeSuccess = [libraryDict writeToURL:_configuration.outputFileUrl atomically:YES];
  if (!writeSuccess) {
    return [NSError errorWithDomain:__MLE__AppBundleIdentifier code:4 userInfo:@{ NSLocalizedDescriptionKey:@"failed to write dictionary" }];
  }
  [self printStatusDone:@"writing to file"];

  return nil;
}


@end
