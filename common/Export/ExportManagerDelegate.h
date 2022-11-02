//
//  ExportManagerDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import <Foundation/Foundation.h>

#import "Defines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ExportManagerDelegate <NSObject>
@optional

- (void) exportStateChanged:(ExportState)state;

- (void) exportedItems:(NSUInteger)exportedItems ofTotal:(NSUInteger)totalItems;
- (void) exportedPlaylists:(NSUInteger)exportedPlaylists ofTotal:(NSUInteger)totalPlaylists;

@end

NS_ASSUME_NONNULL_END
