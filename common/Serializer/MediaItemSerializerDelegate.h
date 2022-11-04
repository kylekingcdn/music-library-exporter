//
//  ExportManagerDelegate.h
//  Music Library Exporter
//
//  Created by Kyle King on 2022-11-01.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MediaItemSerializerDelegate <NSObject>
@optional

- (void)serializedItems:(NSUInteger)serialized ofTotal:(NSUInteger)total;

@end

NS_ASSUME_NONNULL_END
