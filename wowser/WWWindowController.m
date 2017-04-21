//
//  WWWindowController.m
//  wowser
//
//  Created by Nate Parrott on 4/12/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWWindowController.h"
#import "WWTab.h"
#import "WWTabScrollView.h"
#import "ConvenienceCategories.h"
#import "WWTitleCell.h"
#import "WWTabView.h"

@interface WWWindowController () <NSWindowDelegate>

@property (nonatomic) IBOutlet WWTabScrollView *scrollView;
@property (nonatomic) IBOutlet NSView *titleBar;
@property (nonatomic) NSArray<WWTitleCell *> *titleCells;

@end

@implementation WWWindowController

+ (NSMutableSet *)windowControllers {
    static NSMutableSet *windowControllers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        windowControllers = [NSMutableSet set];
    });
    return windowControllers;
}

+ (instancetype)controllerForWindow:(NSWindow *)window {
    for (WWWindowController *controller in [self windowControllers]) {
        if (controller.window == window) {
            return controller;
        }
    }
    return nil;
}

+ (BOOL)doOpenWindowsExist {
    return [[self windowControllers] count] > 0;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [[[self class] windowControllers] addObject:self];
        
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    self.window.styleMask |=  NSFullSizeContentViewWindowMask;
    
    // self.tabs = @[[WWTab new], [WWTab new], [WWTab new], [WWTab new], [WWTab new]];
    self.tabs = @[[WWTab new]];
    
    // self.scrollView.contentView.postsBoundsChangedNotifications = YES;
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didScroll:) name:NSViewBoundsDidChangeNotification object:self.scrollView.contentView];
    __weak WWWindowController *weakSelf = self;
    self.scrollView.onScroll = ^(CGPoint p) {
        [weakSelf updateTitleBarLayout];
    };
}

- (void)setTabs:(NSArray<WWTab *> *)tabs {
    _tabs = tabs;
    self.scrollView.tabs = tabs;
    self.titleCells = [tabs map:^id(id obj) {
        return [obj getOrCreateTitleCell];
    }];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[[self class] windowControllers] removeObject:self];
}

- (void)windowDidResize:(NSNotification *)notification {
    [self updateTitleBarLayout];
}

#pragma mark Tab logic

- (WWTab *)tabForKeyActions {
    WWTab *tab = [self tabThatMouseIsOver] ? : [self mostRecentlyInteractedTab];
    NSArray *visible = [self visibleTabs];
    if (tab && [visible containsObject:tab]) {
        return tab;
    } else {
        return visible.firstObject;
    }
}

- (NSArray<WWTab *> *)visibleTabs {
    NSMutableArray *visible = [NSMutableArray new];
    for (WWTab *tab in self.tabs) {
        if ([tab isViewLoaded]) {
            NSView *tabView = [tab getOrCreateView];
            if (NSIntersectsRect(self.window.contentView.bounds, [self.window.contentView convertRect:tabView.bounds fromView:tabView])) {
                [visible addObject:tab];
            }
        }
    }
    return visible;
}

- (WWTab *)tabThatMouseIsOver {
    NSPoint globalLocation = [NSEvent mouseLocation];
    NSPoint windowLocation = [[self window] convertScreenToBase:globalLocation];
    for (WWTab *tab in self.tabs) {
        if ([tab isViewLoaded]) {
            WWTabView *view = [tab getOrCreateView];
            NSPoint viewLocation = [view convertPoint:windowLocation fromView:nil];
            if (NSPointInRect(viewLocation, view.bounds)) {
                return tab;
            }
        }
    }
    return nil;
}

- (WWTab *)mostRecentlyInteractedTab {
    NSArray *sorted = [self.tabs sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastInteractionTime" ascending:YES]]];
    return sorted.lastObject;
}

- (WWTab *)newTabAfterTab:(WWTab *)sourceTab configuration:(WKWebViewConfiguration *)configuration {
    WWTab *tab = [WWTab new];
    tab.initialConfiguration = configuration;
    [self insertTab:tab afterTab:sourceTab];
    // TODO: shift the scrollview to reveal this tab, if necessary
    return tab;
}

- (void)newTab {
    WWTab *tab = [WWTab new];
    [self insertTab:tab afterTab:nil];
}

- (void)closeTab {
    WWTab *keyTab = [self tabForKeyActions];
    if (keyTab) {
        NSMutableArray *tabList = self.tabs.mutableCopy;
        [tabList removeObject:keyTab];
        self.tabs = tabList;
    }
}

- (IBAction)newTab:(id)sender {
    [self newTab];
}

- (void)insertTab:(WWTab *)tab afterTab:(WWTab *)tabOrNil {
    NSMutableArray *tabList = self.tabs.mutableCopy;
    NSInteger index = 0;
    if (tabOrNil) {
        index = [tabList indexOfObject:tabOrNil] + 1;
    } else {
        WWTab *keyTab = [self tabForKeyActions];
        if (keyTab) {
            index = [tabList indexOfObject:keyTab] + 1;
        }
    }
    [tabList insertObject:tab atIndex:index];
    self.tabs = tabList;
}

#pragma mark Layout

- (void)setTitleCells:(NSArray<WWTitleCell *> *)titleCells {
    for (WWTitleCell *old in _titleCells) {
        if (![titleCells containsObject:old]) {
            [old removeFromSuperview];
        }
    }
    _titleCells = titleCells;
    for (WWTitleCell *cell in _titleCells) {
        if (!cell.superview) {
            [self.titleBar addSubview:cell];
        }
    }
    [self updateTitleBarLayout];
}

- (void)updateTitleBarLayout {
    CGFloat x = -self.scrollView.contentOffset.x;
    for (WWTitleCell *cell in self.titleCells) {
        cell.frame = NSMakeRect(x, 0, 400, self.titleBar.bounds.size.height);
        x += 400;
    }
}

@end
