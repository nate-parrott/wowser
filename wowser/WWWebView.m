//
//  WWWebView.m
//  wowser
//
//  Created by Nate Parrott on 4/13/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWWebView.h"

@interface WWWebView () {
    BOOL _forwardScrollToParent;
}

@end

@implementation WWWebView

- (void)scrollWheel:(NSEvent *)event {
    if (_forwardScrollToParent) {
        [self.enclosingScrollView scrollWheel:event];
    } else {
        [super scrollWheel:event];
    }
}

- (BOOL)acceptsTouchEvents {
    return YES;
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

@end
