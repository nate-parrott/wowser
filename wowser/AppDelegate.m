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

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[NSAppleEventManager sharedAppleEventManager]
     setEventHandler:self
     andSelector:@selector(getUrl:withReplyEvent:)
     forEventClass:kInternetEventClass
     andEventID:kAEGetURL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [URLCompleterTests testAll];
    [[self getWindowControllerForOpeningANewTab] ensureAtLeastOneTab];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CFStringRef bundleID = (__bridge CFStringRef)[[NSBundle mainBundle] bundleIdentifier];
        OSStatus httpResult = LSSetDefaultHandlerForURLScheme(CFSTR("http"), bundleID);
        OSStatus httpsResult = LSSetDefaultHandlerForURLScheme(CFSTR("https"), bundleID);
    });
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [[self getWindowControllerForOpeningANewTab] ensureAtLeastOneTab];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    
}

- (IBAction)newTab:(id)sender {
    WWWindowController *controller = [WWWindowController controllerForWindow:[NSApp keyWindow]];
    [controller newTab];
}

- (IBAction)closeTab:(id)sender {
    WWWindowController *controller = [WWWindowController controllerForWindow:[NSApp keyWindow]];
    [controller closeTab];
}

- (WWWindowController *)getWindowControllerForOpeningANewTab {
    WWWindowController *controller = [WWWindowController controllerForWindow:[NSApp keyWindow]];
    if (controller) {
        return controller;
    }
    for (NSWindow *window in [NSApp windows]) {
        if ([window.windowController isKindOfClass:[WWWindowController class]]) {
            return (WWWindowController *)window.windowController;
        }
    }
    return [self newBrowserWindow];
}

- (WWWindowController *)newBrowserWindow {
    WWWindowController *win = [[WWWindowController alloc] initWithWindowNibName:@"WWWindowController"];
    [win.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
    return win;
}

- (IBAction)newBrowserWindow:(id)sender {
    [self newBrowserWindow];
}

- (IBAction)closeWindow:(id)sender {
    if ([[[NSApp keyWindow] windowController] isKindOfClass:[WWWindowController class]]){
        [[NSApp keyWindow] close];
    }
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *urlStr = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url) {
        [[self getWindowControllerForOpeningANewTab] newTabWithURL:url];
        [[self getWindowControllerForOpeningANewTab].window makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
    }
    // NSLog(@"DID LAUNCH URL: %@", url);
}

@end
