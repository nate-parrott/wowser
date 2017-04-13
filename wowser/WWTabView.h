//
//  WWTabView.h
//  wowser
//
//  Created by Nate Parrott on 4/13/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@import WebKit;

@interface WWTabView : NSView

- (instancetype)initWithWebView:(WKWebView *)webView;

@end
