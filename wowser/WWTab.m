//
//  WWTab.m
//  wowser
//
//  Created by Nate Parrott on 4/12/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWTab.h"
#import "WWWebView.h"
#import "WWTabView.h"

@interface WWTab () {
    WWTabView *_view;
}

@end

@implementation WWTab

- (NSView *)getOrCreateView {
    if (!_view) {
        WWWebView *webView = [[WWWebView alloc] initWithFrame:CGRectZero configuration:[self createConfiguration]];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]]];
        webView.customUserAgent = @"Mozilla/6.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/8.0 Mobile/10A5376e Safari/8536.25";
        webView.allowsBackForwardNavigationGestures = YES;
        _view = [[WWTabView alloc] initWithWebView:webView];
    }
    return _view;
}

- (WKWebViewConfiguration *)createConfiguration {
    WKWebViewConfiguration *conf = [WKWebViewConfiguration new];
    return conf;
}

@end
