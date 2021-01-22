//
//  main.m
//  itunesxmlgen
//
//  Created by Kyle King on 2021-01-18.
//

#import <Foundation/Foundation.h>

#import <iTunesLibrary/ITLibrary.h>

#include "Utils.h"
#include "LibrarySerializer.h"

int main(int argc, const char * argv[]) {

  @autoreleasepool {

    NSError *error = nil;
    ITLibrary *library = [ITLibrary libraryWithAPIVersion:@"1.1" error:&error];

    if (!library) {
      NSLog(@"error - failed to init ITLibrary. error: %@", error.localizedDescription);
      return -1;
    }

    NSString* desktopFilePath = [NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES) firstObject];
    NSString* exportedLibraryFileName = @"exportedLibrary.xml";
    NSString* exportedLibraryFilePath = [[desktopFilePath stringByAppendingString:@"/"] stringByAppendingString:exportedLibraryFileName];

    LibrarySerializer* serializer = [LibrarySerializer alloc];
    [serializer serializeLibrary:library];

    /*
    NSString* sourceLibraryFileName = @"sourceLibrary.xml";
    NSString* sourceLibraryFilePath = [[desktopFilePath stringByAppendingString:@"/"] stringByAppendingString:sourceLibraryFileName];

    NSDictionary* generatedLibraryDict = [serializer dictionary];
    NSDictionary* sourceLibraryDict = [Utils readPropertyListFromFile:sourceLibraryFilePath];

    NSArray<NSString*>* excludedKeyPaths = @[];

    [Utils recursivelyCompareDictionary:sourceLibraryDict withDictionary:generatedLibraryDict exceptForKeyPaths:excludedKeyPaths withCurrentKeyPath:@""];
    */

    [serializer setFilePath:exportedLibraryFilePath];
    [serializer writeDictionary];
  }

  return 0;
}

