//
//  WWWindowController.h
//  wowser
//
//  Created by Nate Parrott on 4/12/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WWTab;
@import WebKit;

@interface WWWindowController : NSWindowController

+ (BOOL)doOpenWindowsExist;
+ (instancetype)controllerForWindow:(NSWindow *)window;

@property (nonatomic) NSArray<WWTab *> *tabs;

- (WWTab *)tabForKeyActions;
- (void)newTab;
- (void)closeTab;

- (WWTab *)newTabAfterTab:(WWTab *)sourceTab configuration:(WKWebViewConfiguration *)configuration;

@end
