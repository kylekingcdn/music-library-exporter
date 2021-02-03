//
//  ScheduleDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-02.
//

#import <Foundation/Foundation.h>

@class ExportDelegate;


NS_ASSUME_NONNULL_BEGIN

@interface ScheduleDelegate : NSObject


#pragma mark - Properties -

@property ExportDelegate* exportDelegate;


#pragma mark - Initializers -

- (instancetype)initWithExportDelegate:(ExportDelegate*)exportDelegate;


#pragma mark - Mutators -

- (void)activateScheduler;
- (void)deactivateScheduler;

- (void)setInterval:(NSTimeInterval)scheduleInterval;



@end

NS_ASSUME_NONNULL_END
