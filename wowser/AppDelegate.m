//
//  AppDelegate.m
//  wowser
//
//  Created by Nate Parrott on 4/12/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "AppDelegate.h"
#import "WWWindowController.h"
#import "wowser-Swift.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [URLCompleterTests testAll];
    [self openWindowIfNoneExists];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [self openWindowIfNoneExists];
}

- (void)openWindowIfNoneExists {
    if ([[NSApp windows] count] == 0) {
        [self newBrowserWindow:nil];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)newTab:(id)sender {
    WWWindowController *controller = [WWWindowController controllerForWindow:[NSApp keyWindow]];
    [controller newTab];
}

- (IBAction)closeTab:(id)sender {
    WWWindowController *controller = [WWWindowController controllerForWindow:[NSApp keyWindow]];
    [controller closeTab];
}

- (IBAction)newBrowserWindow:(id)sender {
    WWWindowController *win = [[WWWindowController alloc] initWithWindowNibName:@"WWWindowController"];
    [win.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)closeWindow:(id)sender {
    if ([[[NSApp keyWindow] windowController] isKindOfClass:[WWWindowController class]]){
        [[NSApp keyWindow] close];
    }
}

@end
