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
    CGPoint _prevMousePos;
}

@property (nonatomic) WWReplicatorView *repl;
@property (nonatomic) WKWebView *webView;
@property (nonatomic, weak) WWTab *tab;
@property (nonatomic) NSView *rightDivider;
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
    // self.rightDivider.layer.backgroundColor = [NSColor colorWithWhite:0.5 alpha:0.15].CGColor;
    self.rightDivider.layer.backgroundColor = [NSColor redColor].CGColor;
    self.rightDivider.layerContentsRedrawPolicy = NSViewLayerContentsRedrawNever;
        
    return self;
}

- (void)layout {
    [super layout];
    self.repl.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    // self.repl.layer.transform = CATransform3DMakeTranslation(0, 40, 0);
    self.webView.frame = CGRectMake(0, 0, self.repl.bounds.size.width, self.repl.bounds.size.height - 64);
    
    CGFloat dividerWidth = self.mouseIsHoveringOverDivider ? WWTabViewDragHandleWidth : 1;
    self.rightDivider.frame = NSMakeRect(self.bounds.size.width - dividerWidth, 0, dividerWidth, self.bounds.size.height);
}

- (void)setMouseIsHoveringOverDivider:(BOOL)mouseIsHoveringOverDivider {
    _mouseIsHoveringOverDivider = mouseIsHoveringOverDivider;
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
    _resizeTrackingArea = [[NSTrackingArea alloc] initWithRect:trackingZone options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:_resizeTrackingArea];
}

- (void)mouseDown:(NSEvent *)event {
    _mouseIsDown = YES;
    _prevMousePos = [event locationInWindow];
}

- (void)mouseUp:(NSEvent *)event {
    _mouseIsDown = NO;
}

- (void)mouseDragged:(NSEvent *)event {
    CGPoint newPos = [event locationInWindow];
    CGFloat dWidth = newPos.x - _prevMousePos.x;
    _prevMousePos = newPos;
    self.tab.width += dWidth;
}

//- (void)mouseMoved:(NSEvent *)event {
//    if (_mouseIsDown) {
//        CGPoint newPos = [event locationInWindow];
//        CGFloat dWidth = newPos.x - _prevMousePos.x;
//        _prevMousePos = newPos;
//        self.tab.width += dWidth;
//    }
//}

- (void)mouseEntered:(NSEvent *)event {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        self.mouseIsHoveringOverDivider = YES;
    } completionHandler:^{
        
    }];
}

- (void)mouseExited:(NSEvent *)event {
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
//        context.allowsImplicitAnimation = YES;
//        self.mouseIsHoveringOverDivider = NO;
//    } completionHandler:^{
//        
//    }];
    self.mouseIsHoveringOverDivider = NO;
}

- (NSView *)hitTest:(NSPoint)point {
    NSView *v = [super hitTest:point];
    if (v == self.rightDivider) {
        return self;
    } else {
        return v;
    }
}

@end
