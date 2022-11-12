//
//  CheckBoxTableCellView.h
//  Music Library Exporter
//
//  Created by Kyle King on 2021-02-10.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CheckBoxTableCellView : NSTableCellView

@property (nullable, assign) IBOutlet NSButton* checkbox;

@end

NS_ASSUME_NONNULL_END
