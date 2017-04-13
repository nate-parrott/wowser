//
//  WWTabScrollView.m
//  wowser
//
//  Created by Nate Parrott on 4/12/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWTabScrollView.h"
#import "WWTab.h"
@import WebKit;

@implementation WWTabScrollView

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
            [self setNeedsLayout:YES];
        }
    }
}

- (void)layout {
    [super layout];
    NSInteger x = 0;
    NSInteger height = self.contentView.bounds.size.height;
    for (WWTab *tab in self.tabs) {
        NSView *v = [tab getOrCreateView];
        v.frame = NSMakeRect(x, 0, 400, height);
        x += 400;
    }
    self.documentView.frame = NSMakeRect(0, 0, x, height);
}

@end
