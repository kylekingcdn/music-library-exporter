//
//  HourNumberFormatter.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-08.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HourNumberFormatter : NSNumberFormatter


#pragma mark - Initializers

- (instancetype)init;


#pragma mark - Accessors

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString * _Nullable * _Nullable)newString errorDescription:(NSString * _Nullable * _Nullable)error;


@end

NS_ASSUME_NONNULL_END
