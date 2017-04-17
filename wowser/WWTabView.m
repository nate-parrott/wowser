//
//  WWTabView.m
//  wowser
//
//  Created by Nate Parrott on 4/13/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWTabView.h"
@import QuartzCore;
#import "WWReplicatorView.h"
#import "WWWindowController.h"

@interface WWTabView () {
}

@property (nonatomic) WWReplicatorView *repl;
@property (nonatomic) WKWebView *webView;
@property (nonatomic, weak) WWTab *tab;

@end

@implementation WWTabView

- (instancetype)initWithWebView:(WKWebView *)webView tab:(WWTab *)tab {
    self = [super init];
    
    self.tab = tab;
    
    self.repl = [WWReplicatorView new];
    [self addSubview:self.repl];
    
    self.webView = webView;
    [self.repl addSubview:webView];
    
    CAReplicatorLayer *r = [_repl replicatorLayer];
    r.instanceCount = 2;
    r.instanceTransform = CATransform3DMakeTranslation(0, 64, -1);
        
    return self;
}

- (void)layout {
    [super layout];
    self.repl.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    // self.repl.layer.transform = CATransform3DMakeTranslation(0, 40, 0);
    self.webView.frame = CGRectMake(0, 0, self.repl.bounds.size.width, self.repl.bounds.size.height - 64);
}

@end
