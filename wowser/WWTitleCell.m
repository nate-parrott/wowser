//
//  WWTitleCell.m
//  wowser
//
//  Created by Nate Parrott on 4/13/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWTitleCell.h"

@interface WWTitleCell () {
    NSTrackingArea *_trackingArea;
}

@property (nonatomic) NSTextField *title, *url;
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
    self.title.font = [NSFont systemFontOfSize:14 weight:NSFontWeightMedium];
    self.title.textColor = [NSColor colorWithWhite:0 alpha:0.66];
    self.title.wantsLayer = YES;
    
    self.url = [NSTextField new];
    [self addSubview:self.url];
    self.url.bezeled = NO;
    self.url.drawsBackground = NO;
    self.url.alignment = NSTextAlignmentCenter;
    self.url.font = [NSFont systemFontOfSize:12 weight:NSFontWeightRegular];
    self.url.stringValue = @"https://google.com";
    self.url.wantsLayer = YES;
    self.url.layer.opacity = 0;
    self.url.focusRingType = NSFocusRingTypeNone;
    
    self.divider = [NSImageView imageViewWithImage:[NSImage imageNamed:@"TabDivider"]];
    [self addSubview:self.divider];
    
    self.wantsLayer = YES;
    
    return self;
}

- (void)layout {
    [super layout];
    
    self.title.frame = NSMakeRect(0, 0, self.bounds.size.width, 30);
    self.url.frame = NSMakeRect(0, 0, self.bounds.size.width, 29);
    
    CGSize imageSize = self.divider.image.size;
    self.divider.frame = NSMakeRect(self.bounds.size.width - imageSize.width, 0, imageSize.width, imageSize.height);
}

- (void)mouseEntered:(NSEvent *)event {
    self.url.layer.opacity = 1;
    self.title.layer.opacity = 0;
}

- (void)mouseExited:(NSEvent *)event {
    self.url.layer.opacity = 0;
    self.title.layer.opacity = 1;
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    if (_trackingArea) {
        [self removeTrackingArea:_trackingArea];
    }
    _trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

@end
