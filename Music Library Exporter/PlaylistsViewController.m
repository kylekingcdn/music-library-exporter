//
//  PlaylistsViewController.m
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-10.
//

#import "PlaylistsViewController.h"

#import <iTunesLibrary/ITLibrary.h>

#import "ExportConfiguration.h"


@interface PlaylistsViewController ()

@end


@implementation PlaylistsViewController


#pragma mark - Initializers -

- (instancetype)init {

  self = [super initWithNibName:@"PlaylistsView" bundle:nil];

  return self;
}

+ (PlaylistsViewController*)controllerWithLibrary:(ITLibrary*)lib andExportConfig:(ExportConfiguration*)exportConfig {

  PlaylistsViewController* controller = [[PlaylistsViewController alloc] init];

  [controller setLibrary:lib];
  [controller setExportConfiguration:exportConfig];

  return controller;
}


#pragma mark - Mutators -

- (void)viewDidLoad {

  [super viewDidLoad];
}


@end
