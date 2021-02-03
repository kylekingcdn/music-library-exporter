//
//  ExportScheduleDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExportScheduleDelegate : NSObject


#pragma mark - Properties -

@property BOOL scheduleEnabled;
@property NSInteger scheduleInterval;


#pragma mark - Initializers -

- (instancetype)init;


#pragma mark - Accessors -

- (NSDictionary*)defaultValues;


#pragma mark - Mutators -

- (void)loadPropertiesFromUserDefaults;


@end

NS_ASSUME_NONNULL_END
