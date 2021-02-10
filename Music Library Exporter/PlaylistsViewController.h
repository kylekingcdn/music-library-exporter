//
//  PlaylistsViewController.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-10.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class ITLibrary;
@class ExportConfiguration;


@interface PlaylistsViewController : NSViewController


#pragma mark - Properties -

@property ITLibrary* library;
@property ExportConfiguration* exportConfiguration;


#pragma mark - Initializers -

- (instancetype)init;

+ (PlaylistsViewController*)controllerWithLibrary:(ITLibrary*)lib andExportConfig:(ExportConfiguration*)config;


#pragma mark - Accessors -


#pragma mark - Mutators -


@end

NS_ASSUME_NONNULL_END
