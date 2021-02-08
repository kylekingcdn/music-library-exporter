//
//  HourNumberFormatter.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-08.
//

#import "HourNumberFormatter.h"

@implementation HourNumberFormatter


#pragma mark - Accessors -

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString * _Nullable * _Nullable)newString errorDescription:(NSString * _Nullable * _Nullable)error {

  if (partialString.length == 0) {
    return YES;
  }

  NSScanner *scanner = [NSScanner scannerWithString:partialString];

  if ([scanner scanInt:NULL] && [scanner isAtEnd]) {

    int partialStringInt = [partialString intValue];
    if (partialStringInt > 0 && partialStringInt <= 24) {
      return YES;
    }
  }

  return NO;
}

@end
