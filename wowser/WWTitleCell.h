//
//  WWTitleCell.h
//  wowser
//
//  Created by Nate Parrott on 4/13/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WWTitleCell;

@protocol WWTitleCellDelegate

- (void)titleCell:(WWTitleCell *)titleCell didTypeReturnWithText:(NSString *)text;

@end



@interface WWTitleCell : NSView

@property (nonatomic, readonly) NSTextField *title, *url;
@property (nonatomic, weak) id<WWTitleCellDelegate> delegate;

@end
