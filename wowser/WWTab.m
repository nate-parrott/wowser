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
#import "WWTitleCell.h"
#import "NSURL+NaturalURLEntry.h"

@interface WWTab () <WWTitleCellDelegate, WKNavigationDelegate> {
    WWWebView *_webView;
    WWTabView *_view;
    WWTitleCell *_titleCell;
}

@end

@implementation WWTab

- (NSView *)getOrCreateView {
    if (!_view) {
        _webView = [[WWWebView alloc] initWithFrame:CGRectZero configuration:[self createConfiguration]];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]]];
        _webView.customUserAgent = @"Mozilla/6.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/8.0 Mobile/10A5376e Safari/8536.25";
        _webView.allowsBackForwardNavigationGestures = YES;
        _view = [[WWTabView alloc] initWithWebView:_webView];
    }
    return _view;
}

- (WKWebViewConfiguration *)createConfiguration {
    WKWebViewConfiguration *conf = [WKWebViewConfiguration new];
    return conf;
}

- (WWTitleCell *)getOrCreateTitleCell {
    if (!_titleCell) {
        _titleCell = [WWTitleCell new];
        _titleCell.delegate = self;
    }
    return _titleCell;
}

#pragma mark Title cell delegate

- (void)titleCell:(WWTitleCell *)titleCell didTypeReturnWithText:(NSString *)text {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL withNaturalString:text]]];
}

#pragma mark Navigation delegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

@end
