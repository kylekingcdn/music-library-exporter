//
//  main.m
//  library-generator
//
//  Created by Kyle King on 2021-01-18.
//

#import <Foundation/Foundation.h>

#import "LibraryGenerator.h"
#import "ExportConfiguration.h"

int main(int argc, const char * argv[]) {

  @autoreleasepool {

    LibraryGenerator* generator = [[LibraryGenerator alloc] init];

    // parse args and load configuration
    NSError* setupError;
    if (![generator setupAndReturnError:&setupError]) {
      if (setupError) {
        fprintf(stderr, "%s\n", setupError.localizedDescription.UTF8String);
      }
      return 1;
    }

    // generator won't always be initialized (e.g. for help command)
    if (generator.configuration) {
      [generator.configuration dumpProperties];
    }

    // handle command
    NSError* commandError;
    BOOL commandSuccess = YES;
    switch (generator.command) {

      case LGCommandKindExport: {
        commandSuccess = [generator exportLibraryAndReturnError:&commandError];
        break;
      }

      case LGCommandKindPrint: {
        [generator printPlaylists];
        break;
      }

      case LGCommandKindHelp: {
        [generator printHelp];
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
