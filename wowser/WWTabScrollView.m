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
#import "ConvenienceCategories.h"

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
    [self setTabs:tabs animated:NO];
}

- (void)setTabs:(NSArray<WWTab *> *)tabs animated:(BOOL)animated {
    NSArray *oldTabsToRemove = [_tabs map:^id(id obj) {
        return [tabs containsObject:obj] ? nil : obj;
    }];
    void (^removeOldTabs)() = ^{
        for (WWTab *oldTab in oldTabsToRemove) {
            if (![tabs containsObject:oldTab]) {
                [[oldTab getOrCreateView] removeFromSuperview];
            }
        }
    };
    
    NSMapTable<WWTab*, NSValue*> *framesForOldTabs = [NSMapTable strongToStrongObjectsMapTable];
    
    _tabs = tabs;
    for (WWTab *tab in tabs) {
        if ([[tab getOrCreateView] superview]) {
            // old tab -- store its frame:
            [framesForOldTabs setObject:[NSValue valueWithRect:[[tab getOrCreateView] frame]] forKey:tab];
        } else {
            // this is a new tab:
            NSView *tabView = [tab getOrCreateView];
            [self.documentView addSubview:tabView positioned:NSWindowBelow relativeTo:self.subviews.firstObject];
            if (animated) tabView.alphaValue = 0;
        }
    }
    
    if (animated) {
        // do layout so we know the new tabs' positions:
        [self layoutTabs];
        // restore the pre-layout position of the old tabs so we can animate:
        for (WWTab *oldTab in framesForOldTabs.keyEnumerator) {
            [oldTab getOrCreateView].frame = [[framesForOldTabs objectForKey:oldTab] rectValue];
        }
        // send outgoing tabs to back:
        for (WWTab *tab in oldTabsToRemove) {
            [self.documentView addSubview:[tab getOrCreateView] positioned:NSWindowBelow relativeTo:self.subviews.firstObject];
        }
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.allowsImplicitAnimation = YES;
            context.duration = [[self class] animationDuration];
            for (WWTab *tab in _tabs) [tab getOrCreateView].alphaValue = 1;
            for (WWTab *old in oldTabsToRemove) [old getOrCreateView].alphaValue = 0;
            [self layout];
        } completionHandler:^{
            removeOldTabs();
        }];
    } else {
        removeOldTabs();
        [self setNeedsLayout:YES];
    }
}

- (CGFloat)layoutTabs {
    NSInteger x = 0;
    NSInteger height = self.bounds.size.height;
    for (WWTab *tab in self.tabs) {
        NSView *v = [tab getOrCreateView];
        v.frame = NSMakeRect(x, 0, tab.width, height);
        x += tab.width;
    }
    return x;
}

- (void)layout {
    [super layout];
    NSInteger height = self.bounds.size.height;
    self.contentSize = NSMakeSize([self layoutTabs], height);
    
    Impetus *impetus = [self impetus];
    [impetus setBoundsWithMinX:0 minY:0 maxX:self.contentSize.width - self.bounds.size.width maxY:self.contentSize.height - self.bounds.size.height];
}

- (void)ensureTabIsVisible:(WWTab *)tab animated:(BOOL)animated {
    [self layout];
    WWTabView *tabView = [tab getOrCreateView];
    CGPoint offset = self.contentOffset;
    offset.x = MIN(offset.x, tabView.frame.origin.x);
    offset.x = MAX(offset.x, tabView.frame.origin.x + tabView.frame.size.width - self.bounds.size.width);
    if (animated) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.allowsImplicitAnimation = YES;
            context.duration = [[self class] animationDuration];
            self.contentOffset = offset;
        } completionHandler:^{
            
        }];
    } else {
        self.contentOffset = offset;
    }
}

+ (NSTimeInterval)animationDuration {
    return 0.3;
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
