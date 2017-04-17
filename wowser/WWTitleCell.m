//
//  WWTitleCell.m
//  wowser
//
//  Created by Nate Parrott on 4/13/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWTitleCell.h"
#import "WWTransformView.h"
@import QuartzCore;

@interface WWTitleCell () <NSTextFieldDelegate> {
    NSTrackingArea *_trackingArea;
}

@property (nonatomic) NSTextField *title, *url;
@property (nonatomic) NSImageView *divider;

@property (nonatomic) WWTransformView *titleTransformView, *urlTransformView;
@property (nonatomic) BOOL urlFieldFocused, mouseHovering, urlVisible;

@end



@implementation WWTitleCell

- (instancetype)init {
    self = [super init];
    
    self.wantsLayer = YES;
    
    self.urlTransformView = [WWTransformView new];
    [self addSubview:self.urlTransformView];
    
    self.titleTransformView = [WWTransformView new];
    [self addSubview:self.titleTransformView];
    
    self.title = [NSTextField new];
    self.title.bezeled = NO;
    self.title.editable = NO;
    self.title.drawsBackground = NO;
    self.title.selectable = NO;
    self.title.alignment = NSTextAlignmentCenter;
    self.title.stringValue = @"This is a Tab";
    self.title.font = [NSFont systemFontOfSize:14 weight:NSFontWeightMedium];
    self.title.textColor = [NSColor colorWithWhite:0 alpha:0.66];
    self.title.maximumNumberOfLines = 1;
    self.title.cell.truncatesLastVisibleLine = YES;
    self.titleTransformView.content = self.title;
    
    self.url = [NSTextField new];
    self.url.bezeled = NO;
    self.url.drawsBackground = NO;
    self.url.alignment = NSTextAlignmentCenter;
    self.url.font = [NSFont systemFontOfSize:12 weight:NSFontWeightRegular];
    self.url.stringValue = @"https://google.com";
    self.url.layer.opacity = 0;
    self.url.focusRingType = NSFocusRingTypeNone;
    self.url.delegate = self;
    self.url.target = self;
    self.url.action = @selector(textFieldDidReturn:);
    self.url.maximumNumberOfLines = 1;
    self.url.cell.truncatesLastVisibleLine = YES;
    self.urlTransformView.content = self.url;
    
    self.divider = [NSImageView imageViewWithImage:[NSImage imageNamed:@"TabDivider"]];
    [self addSubview:self.divider];
    
    self.urlVisible = NO;
    
    return self;
}

- (void)layout {
    [super layout];
    
    // self.title.frame = NSMakeRect(0, 0, self.bounds.size.width, 30);
    self.titleTransformView.frame = NSMakeRect(0, 0, self.bounds.size.width, 30 + 15);
    self.urlTransformView.frame = NSMakeRect(0, 0, self.bounds.size.width, 29);
    self.titleTransformView.insets = NSEdgeInsetsMake(15, 0, 0, 0);
    
    CGSize imageSize = self.divider.image.size;
    self.divider.frame = NSMakeRect(self.bounds.size.width - imageSize.width, 0, imageSize.width, imageSize.height);
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    if (_trackingArea) {
        [self removeTrackingArea:_trackingArea];
    }
    _trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

#pragma mark URL visibility

- (BOOL)shouldShowUrlField {
    return self.mouseHovering || self.urlFieldFocused;
}

- (void)mouseEntered:(NSEvent *)event {
    self.mouseHovering = YES;
    [self setUrlVisible:[self shouldShowUrlField] animated:YES];
}

- (void)mouseExited:(NSEvent *)event {
    self.mouseHovering = NO;
    [self setUrlVisible:[self shouldShowUrlField] animated:YES];
}

- (void)setUrlVisible:(BOOL)urlVisible {
    [self setUrlVisible:urlVisible animated:NO];
}

- (void)setUrlVisible:(BOOL)urlVisible animated:(BOOL)animated {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        self.urlTransformView.alphaValue = urlVisible ? 1 : 0;
        self.titleTransformView.alphaValue = urlVisible ? 0.5 : 1;
        if (urlVisible) {
            self.urlTransformView.animator.transform = CATransform3DIdentity;
            self.titleTransformView.animator.transform = CATransform3DTranslate(CATransform3DMakeScale(0.8, 0.8, 1), 0, 20, 0);
        } else {
            self.urlTransformView.animator.transform = CATransform3DTranslate(CATransform3DMakeScale(0.8, 0.8, 1), 0, -5, 0);
            self.titleTransformView.animator.transform = CATransform3DIdentity;
        }
    } completionHandler:^{
        
    }];
}

#pragma mark URL field

- (BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor {
    // TODO: can we get a notification when the field is clicked, rather than when it's first typed-into?
    self.urlFieldFocused = YES;
    [self setUrlVisible:[self shouldShowUrlField] animated:YES];
    return YES;
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    self.urlFieldFocused = NO;
    [self setUrlVisible:[self shouldShowUrlField] animated:YES];
    return YES;
}

- (void)textFieldDidReturn:(NSTextField *)field {
    [self.delegate titleCell:self didTypeReturnWithText:field.stringValue];
}

@end
