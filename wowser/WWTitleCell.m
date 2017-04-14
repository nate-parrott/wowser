//
//  WWTitleCell.m
//  wowser
//
//  Created by Nate Parrott on 4/13/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWTitleCell.h"

@interface WWTitleCell ()

@property (nonatomic) NSTextField *title;
@property (nonatomic) NSImageView *divider;

@end



@implementation WWTitleCell

- (instancetype)init {
    self = [super init];
    
    self.title = [NSTextField new];
    [self addSubview:self.title];
    self.title.bezeled = NO;
    self.title.editable = NO;
    self.title.drawsBackground = NO;
    self.title.selectable = NO;
    self.title.alignment = NSTextAlignmentCenter;
    self.title.stringValue = @"This is a Tab";
    
    self.divider = [NSImageView imageViewWithImage:[NSImage imageNamed:@"TabDivider"]];
    [self addSubview:self.divider];
    
    self.wantsLayer = YES;
    
    return self;
}

- (void)layout {
    [super layout];
    self.title.frame = NSMakeRect(0, 0, self.bounds.size.width, 30);
    CGSize imageSize = self.divider.image.size;
    self.divider.frame = NSMakeRect(self.bounds.size.width - imageSize.width, 0, imageSize.width, imageSize.height);
}

@end
