//
//  SorterDefines.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SorterDefines : NSObject

#pragma mark - Accessors

// Properties that should support sorting
+ (NSArray<NSString*>*)allProperties;

// Names of properties to use for frontend, logging, etc.
+ (NSDictionary*)propertyNames;

// Substitute properties to use when the value of a given property is empty/nil
+ (NSDictionary*)propertySubstitutions;

// Alternative properties to compare/sort when the value is identical for both provided instances
+ (NSDictionary*)fallbackSortProperties;

// Default alternatives to use when there is no corresponding array in the `fallbackSortProperties` dictionary
+ (NSArray<NSString*>*)defaultFallbackSortProperties;

+ (nullable NSString*)nameForProperty:(NSString*)property;

+ (NSArray<NSString*>*)substitutionsForProperty:(NSString*)property;

+ (NSArray<NSString*>*)fallbackPropertiesForProperty:(NSString*)property;

@end

NS_ASSUME_NONNULL_END
