//
//  ExportDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-03.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface ExportDelegate : NSObject {

  NSDate* _lastExportedAt;
}


#pragma mark - Initializers -

- (instancetype)init;


#pragma mark - Accessors -

//- (NSDictionary*)defaultValues;

- (nullable NSDate*)lastExportedAt;

- (void)dumpProperties;


#pragma mark - Mutators -

- (void)loadPropertiesFromUserDefaults;

- (void)setLastExportedAt:(nullable NSDate*)timestamp;


@end

NS_ASSUME_NONNULL_END
