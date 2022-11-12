//
//  main.m
//  music-library-exporter
//
//  Created by Kyle King on 2021-01-18.
//

#import <Foundation/Foundation.h>

#import "CLIManager.h"
#import "ExportConfiguration.h"

int main(int argc, const char * argv[]) {

  @autoreleasepool {

    CLIManager* cliManager = [[CLIManager alloc] init];

    // parse args and load configuration
    NSError* setupError;
    if (![cliManager setupAndReturnError:&setupError]) {
      if (setupError) {
        fprintf(stderr, "%s\n", setupError.localizedDescription.UTF8String);
      }
      return 1;
    }

    // cliManager won't always be initialized (e.g. for help command)
    if (cliManager.configuration) {
      [cliManager.configuration dumpProperties];
    }

    // handle command
    NSError* commandError;
    BOOL commandSuccess = YES;
    switch (cliManager.command) {

      case LGCommandKindExport: {
        commandSuccess = [cliManager exportLibraryAndReturnError:&commandError];
        break;
      }

      case LGCommandKindPrint: {
        [cliManager printPlaylists];
        break;
      }

      case LGCommandKindHelp: {
        [cliManager printHelp];
        break;
      }

      case LGCommandKindVersion: {
        [cliManager printVersion];
        break;
      }

      // This is included despite setup throwing an error even if it is the case.
      // This allows for potential IDE warnings for any added command types in the future.
      case LGCommandKindUnknown: { break; }
    }

    if (!commandSuccess) {
      if (commandError) {
        fprintf(stderr, "%s\n", commandError.localizedDescription.UTF8String);
      }
      return 1;
    }
  }

  return 0;
}
