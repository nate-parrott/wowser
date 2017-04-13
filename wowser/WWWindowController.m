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

@interface WWWindowController () <NSWindowDelegate>

@property (nonatomic) NSArray<WWTab *> *tabs;
@property (nonatomic) IBOutlet WWTabScrollView *scrollView;

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
    
    // self.tabs = @[[WWTab new], [WWTab new], [WWTab new], [WWTab new], [WWTab new]];
    self.tabs = @[[WWTab new]];
}

- (void)setTabs:(NSArray<WWTab *> *)tabs {
    self.scrollView.tabs = tabs;
}

- (void)windowWillClose:(NSNotification *)notification {
    [[[self class] windowControllers] removeObject:self];
}

@end
