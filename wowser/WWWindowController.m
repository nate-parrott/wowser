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

@interface WWWindowController () <NSWindowDelegate>

@property (nonatomic) NSArray<WWTab *> *tabs;
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

+ (BOOL)doOpenWindowsExist {
    return [[self windowControllers] count] > 0;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [[[self class] windowControllers] addObject:self];
    
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    self.window.styleMask |=  NSFullSizeContentViewWindowMask;
    
    self.tabs = @[[WWTab new], [WWTab new], [WWTab new], [WWTab new], [WWTab new]];
    // self.tabs = @[[WWTab new]];
    
    self.scrollView.contentView.postsBoundsChangedNotifications = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didScroll:) name:NSViewBoundsDidChangeNotification object:self.scrollView.contentView];
}

- (void)setTabs:(NSArray<WWTab *> *)tabs {
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

- (void)didScroll:(NSNotification *)notif {
    [self updateTitleBarLayout];
}

- (void)updateTitleBarLayout {
    CGFloat x = -self.scrollView.contentView.bounds.origin.x;
    for (WWTitleCell *cell in self.titleCells) {
        cell.frame = NSMakeRect(x, 0, 400, self.titleBar.bounds.size.height);
        x += 400;
    }
}

@end
