//
//  WWWebView.m
//  wowser
//
//  Created by Nate Parrott on 4/13/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWWebView.h"
#import "WWWindowController.h"
#import "WWTabView.h"
#import "WWTab.h"

@interface WWWebView () {
    BOOL _forwardScrollToParent;
}

@end


@implementation WWWebView

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    self.allowedTouchTypes |= NSTouchTypeMaskIndirect;
}

- (void)scrollWheel:(NSEvent *)event {
    if (_forwardScrollToParent) {
        // [self.enclosingScrollView scrollWheel:event];
    } else {
        [super scrollWheel:event];
        [self recordInteractionWithThisTab];
    }
}

- (void)touchesBeganWithEvent:(NSEvent *)event {
    [super touchesBeganWithEvent:event];
    NSInteger nTouches = [event touchesMatchingPhase:NSTouchPhaseTouching inView:self].count;
    if (nTouches == 3) {
        _forwardScrollToParent = YES;
    } else {
        _forwardScrollToParent = NO;
    }
}

- (WWTab *)associatedTab {
    WWWindowController *ct = [WWWindowController controllerForWindow:self.window];
    for (WWTab *tab in ct.tabs) {
        if ([tab isViewLoaded] && [tab getOrCreateView].webView == self) {
            return tab;
        }
    }
    return nil;
}

- (void)recordInteractionWithThisTab {
    [[self associatedTab] didInteract];
}

@end
