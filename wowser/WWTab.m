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
#import <KVOController/NSObject+FBKVOController.h>
#import "WWWindowController.h"

@interface WWTab () <WWTitleCellDelegate, WKNavigationDelegate, WKUIDelegate> {
    WWWebView *_webView;
    WWTabView *_view;
    WWTitleCell *_titleCell;
}

@end

@implementation WWTab

- (instancetype)init {
    self = [super init];
    self.width = 400;
    return self;
}

- (WWTabView *)getOrCreateView {
    if (!_view) {
        _webView = [[WWWebView alloc] initWithFrame:CGRectZero configuration:[self createConfiguration]];
        _webView.customUserAgent = @"Mozilla/6.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/8.0 Mobile/10A5376e Safari/8536.25";
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.UIDelegate = self;
        _view = [[WWTabView alloc] initWithWebView:_webView tab:self];
        
        __weak WWTab *weakSelf = self;
        [self.KVOController observe:_webView keyPath:@"URL" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *str = [[object URL] absoluteString];
                if (str) [weakSelf getOrCreateTitleCell].urlString = str;
            });
        }];
        [self.KVOController observe:_webView keyPath:@"title" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf getOrCreateTitleCell].title.stringValue = [object title];
            });
        }];
    }
    return _view;
}

- (void)loadHomepage {
    [[self getOrCreateView].webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://google.com"]]];
}

- (void)close {
    [[self windowController] closeTab:self];
}

- (void)didClose {
    
}

- (WKWebViewConfiguration *)createConfiguration {
    if (self.initialConfiguration) return self.initialConfiguration;
    
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

- (BOOL)isViewLoaded {
    return !!_view;
}

- (WWWindowController *)windowController {
    return [WWWindowController controllerForWindow:_view.window];
}

- (void)setWidth:(CGFloat)width {
    CGFloat maxWidth = [[[self windowController] window] screen].frame.size.width;
    CGFloat minWidth = 400;
    width = MAX(minWidth, MIN(maxWidth, width));
    _width = width;
    [[self windowController] tabSizesDidUpdate];
}

#pragma mark Title cell delegate

- (void)titleCell:(WWTitleCell *)titleCell didTypeReturnWithText:(NSString *)text {
    [self didInteract];
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL withNaturalString:text]]];
}

- (void)titleCellWantsToCloseTab:(WWTitleCell *)titleCell {
    [self close];
}

- (void)titleCell:(WWTitleCell *)titleCell wantsTabMenuWithSource:(NSView *)sourceView {
    // TODO
}

//#pragma mark Navigation delegate
//
//- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
//    
//}
//
//- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
//    
//}
//
//- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
//    
//}
//
//- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
//    
//}

#pragma mark Interaction tracking
- (void)didInteract {
    self.lastInteractionTime = CFAbsoluteTimeGetCurrent();
}

#pragma mark UI delegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    WWTab *tab = [[self windowController] newTabAfterTab:self configuration:configuration];
    return [tab getOrCreateView].webView;
}

- (void)webView:(WKWebView *)webView runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSArray<NSURL *> * _Nullable))completionHandler {
    // TODO
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    // TODO
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    // TODO
}

- (void)webViewDidClose:(WKWebView *)webView {
    [self close];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    // TODO
}

@end
