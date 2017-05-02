//
//  WWTabView.m
//  wowser
//
//  Created by Nate Parrott on 4/13/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWTabView.h"
@import QuartzCore;
#import "WWReplicatorView.h"
#import "WWWindowController.h"
#import "WWTab.h"

static const CGFloat WWTabViewDragHandleWidth = 10;

@interface WWTabView () {
    NSTrackingArea *_resizeTrackingArea;
    BOOL _mouseIsDown;
    CGPoint _initialMousePos;
    CGFloat _initialWidth;
}

@property (nonatomic) WWReplicatorView *repl;
@property (nonatomic) WKWebView *webView;
@property (nonatomic, weak) WWTab *tab;

@property (nonatomic) NSView *rightDivider;
@property (nonatomic) NSImageView *rightDividerResizeHint;

@property (nonatomic) BOOL mouseIsHoveringOverDivider;

@end

@implementation WWTabView

- (instancetype)initWithWebView:(WKWebView *)webView tab:(WWTab *)tab {
    self = [super init];
    
    self.wantsLayer = YES;
    
    self.tab = tab;
    
    self.repl = [WWReplicatorView new];
    [self addSubview:self.repl];
    
    self.webView = webView;
    [self.repl addSubview:webView];
    
    CAReplicatorLayer *r = [_repl replicatorLayer];
    r.instanceCount = 2;
    r.instanceTransform = CATransform3DMakeTranslation(0, 64, -1);
    
    self.rightDivider = [NSView new];
    [self addSubview:self.rightDivider];
    self.rightDivider.wantsLayer = YES;
    self.rightDivider.layer.backgroundColor = [NSColor colorWithDeviceRed:0.851 green:0.847 blue:0.847 alpha:1.000].CGColor;
    self.rightDivider.layerContentsRedrawPolicy = NSViewLayerContentsRedrawNever;
    
    self.rightDividerResizeHint = [NSImageView new];
    self.rightDividerResizeHint.image = [NSImage imageNamed:@"ResizeHint"];
    [self.rightDivider addSubview:self.rightDividerResizeHint];
    self.rightDividerResizeHint.alphaValue = 0;
    
    return self;
}

- (void)layout {
    [super layout];
    self.repl.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    // self.repl.layer.transform = CATransform3DMakeTranslation(0, 40, 0);
    self.webView.frame = CGRectMake(0, 0, self.repl.bounds.size.width, self.repl.bounds.size.height - 64);
    
    CGFloat dividerWidth = self.mouseIsHoveringOverDivider || _mouseIsDown ? WWTabViewDragHandleWidth : 1;
    self.rightDivider.frame = NSMakeRect(self.bounds.size.width - dividerWidth, 0, dividerWidth, self.bounds.size.height);
    NSSize dividerHintSize = self.rightDividerResizeHint.image.size;
    self.rightDividerResizeHint.frame = NSMakeRect(dividerWidth / 2 - dividerHintSize.width/2, self.rightDivider.frame.size.height/2 - dividerHintSize.height/2, dividerHintSize.width, dividerHintSize.height);
}

- (void)setMouseIsHoveringOverDivider:(BOOL)mouseIsHoveringOverDivider {
    _mouseIsHoveringOverDivider = mouseIsHoveringOverDivider;
    self.rightDividerResizeHint.alphaValue = mouseIsHoveringOverDivider ? 1 : 0;
    [self setNeedsLayout:YES];
    [self layout];
}

#pragma mark Mouse tracking

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    if (_resizeTrackingArea) {
        [self removeTrackingArea:_resizeTrackingArea];
    }
    NSRect trackingZone = NSMakeRect(self.bounds.size.width - WWTabViewDragHandleWidth, 0, WWTabViewDragHandleWidth, self.bounds.size.height);
    _resizeTrackingArea = [[NSTrackingArea alloc] initWithRect:trackingZone options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways | NSTrackingCursorUpdate owner:self userInfo:nil];
    [self addTrackingArea:_resizeTrackingArea];
}

- (void)mouseDown:(NSEvent *)event {
    _mouseIsDown = YES;
    _initialMousePos = [event locationInWindow];
    _initialWidth = self.tab.width;
}

- (void)mouseUp:(NSEvent *)event {
    _mouseIsDown = NO;
}

- (void)mouseDragged:(NSEvent *)event {
    CGPoint newPos = [event locationInWindow];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.01];
    self.tab.width = _initialWidth + newPos.x - _initialMousePos.x;
    [NSAnimationContext endGrouping];
    
    [CATransaction commit];
    
}

- (void)mouseEntered:(NSEvent *)event {
    if (!_mouseIsDown) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.allowsImplicitAnimation = YES;
            self.mouseIsHoveringOverDivider = YES;
        } completionHandler:^{
            
        }];
    } else {
        self.mouseIsHoveringOverDivider = YES;
    }
}

- (void)mouseExited:(NSEvent *)event {
    if (!_mouseIsDown) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.allowsImplicitAnimation = YES;
            self.mouseIsHoveringOverDivider = NO;
        } completionHandler:^{
            
        }];
    } else {
        self.mouseIsHoveringOverDivider = NO;
    }
}

- (void)cursorUpdate:(NSEvent *)event {
    [[NSCursor resizeLeftRightCursor] set];
}

- (NSView *)hitTest:(NSPoint)point {
    NSView *v = [super hitTest:point];
    if ([v isDescendantOf:self.rightDivider]) {
        return self;
    } else {
        return v;
    }
}

@end
