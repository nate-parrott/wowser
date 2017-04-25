//
//  WWTabScrollView.m
//  wowser
//
//  Created by Nate Parrott on 4/12/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWTabScrollView.h"
#import "WWTab.h"
#import "WWTabView.h"
@import WebKit;
#import "wowser-Swift.h"

@interface WWTabScrollView () {
    BOOL _trackTouches;
    Impetus *_impetus;
    
    CGPoint _gestureTrackingPos;
    NSMutableDictionary *_prevPositionForTouches;
}

@property (nonatomic) NSView *documentView;

@end

@implementation WWTabScrollView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.documentView = [NSView new];
    [self addSubview:self.documentView];
    self.documentView.wantsLayer = YES;
    self.documentView.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    self.allowedTouchTypes |= NSTouchTypeMaskIndirect;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    _contentOffset = contentOffset;
    if (sqrt(pow(_impetus.position.x - contentOffset.x, 2) + pow(_impetus.position.y - contentOffset.y, 2)) > 1) {
        _impetus.position = contentOffset;
    }
    [self _updateDocumentFrame];
    if (self.onScroll) self.onScroll(contentOffset);
}

- (void)setTabs:(NSArray<WWTab *> *)tabs {
    for (WWTab *oldTab in _tabs) {
        if (![tabs containsObject:oldTab]) {
            [[oldTab getOrCreateView] removeFromSuperview];
        }
    }
    _tabs = tabs;
    for (WWTab *tab in tabs) {
        if (![[tab getOrCreateView] superview]) {
            [self.documentView addSubview:[tab getOrCreateView]];
        }
    }
    [self setNeedsLayout:YES];
}

- (void)layout {
    [super layout];
    NSInteger x = 0;
    NSInteger height = self.bounds.size.height;
    for (WWTab *tab in self.tabs) {
        NSView *v = [tab getOrCreateView];
        v.frame = NSMakeRect(x, 0, 400, height);
        x += 400;
    }
    self.contentSize = NSMakeSize(x, height);
    
    Impetus *impetus = [self impetus];
    [impetus setBoundsWithMinX:0 minY:0 maxX:self.contentSize.width - self.bounds.size.width maxY:self.contentSize.height - self.bounds.size.height];
}

- (void)ensureTabIsVisible:(WWTab *)tab {
    [self layout];
    WWTabView *tabView = [tab getOrCreateView];
    CGPoint offset = self.contentOffset;
    offset.x = MIN(offset.x, tabView.frame.origin.x);
    offset.x = MAX(offset.x, tabView.frame.origin.x + tabView.frame.size.width - self.bounds.size.width);
    self.contentOffset = offset;
}

- (void)setContentSize:(CGSize)contentSize {
    _contentSize = contentSize;
    [self _updateDocumentFrame];
}

- (void)_updateDocumentFrame {
    self.documentView.frame = NSMakeRect(-self.contentOffset.x, -self.contentOffset.y, self.contentSize.width, self.contentSize.height);
}

- (Impetus *)impetus {
    if (!_impetus) {
        _impetus = [[Impetus alloc] initWithInitialPos:self.contentOffset onUpdate:^(CGPoint p) {
            self.contentOffset = CGPointMake(p.x, 0);
        }];
    }
    return _impetus;
}

- (void)touchesBeganWithEvent:(NSEvent *)event {
    [super touchesBeganWithEvent:event];
    NSSet<NSTouch *> *touches = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self];
    NSInteger nTouches = touches.count;
    if (nTouches == 3) {
        _trackTouches = YES;
        _gestureTrackingPos = CGPointZero;
        _prevPositionForTouches = [NSMutableDictionary new];
        [[self impetus] startGestureWithPos:[self gestureTrackingPositionForTouches:touches]];
    } else {
        _trackTouches = NO;
    }
}

- (void)touchesMovedWithEvent:(NSEvent *)event {
    if (_trackTouches) {
        NSSet<NSTouch *> *touches = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self];
        [[self impetus] updateGestureWithPos:[self gestureTrackingPositionForTouches:touches]];
    }
}

- (void)touchesEndedWithEvent:(NSEvent *)event {
    if (_trackTouches) {
        [[self impetus] endGesture];
    }
}

- (CGPoint)gestureTrackingPositionForTouches:(NSSet<NSTouch *> *)touches {
    CGPoint translation = CGPointZero;
    NSInteger translationFromTouchCount = 0;
    
    for (NSTouch *t in touches) {
        if (_prevPositionForTouches[t.identity]) {
            NSPoint prevPos = [_prevPositionForTouches[t.identity] pointValue];
            translation.x += t.normalizedPosition.x - prevPos.x;
            translation.y += t.normalizedPosition.y - prevPos.y;
            translationFromTouchCount++;
        }
        _prevPositionForTouches[t.identity] = [NSValue valueWithPoint:t.normalizedPosition];
    }
    
    CGFloat scale = 900;
    if (translationFromTouchCount) {
        _gestureTrackingPos.x -= (translation.x / translationFromTouchCount) * scale;
        _gestureTrackingPos.y -= (translation.y / translationFromTouchCount) * scale;
    }
    return _gestureTrackingPos;
}

@end
