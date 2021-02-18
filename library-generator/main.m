//
//  main.m
//  library-generator
//
//  Created by Kyle King on 2021-01-18.
//

#import <Foundation/Foundation.h>

#import "LibraryGenerator.h"

int main(int argc, const char * argv[]) {

  @autoreleasepool {

    LibraryGenerator* generator = [[LibraryGenerator alloc] init];
    [generator run];
  }

  return 0;
}
