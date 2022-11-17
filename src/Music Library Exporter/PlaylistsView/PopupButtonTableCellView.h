//
//  PopupButtonTableCellView.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-10.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PopupButtonTableCellView : NSTableCellView

@property (nullable, assign) IBOutlet NSPopUpButton* button;

@end

NS_ASSUME_NONNULL_END
