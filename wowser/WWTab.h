//
//  WWTab.h
//  wowser
//
//  Created by Nate Parrott on 4/12/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WebKit;
@class WWTitleCell;
@class WWTabView;

@interface WWTab : NSObject

- (WWTabView *)getOrCreateView;
- (WWTitleCell *)getOrCreateTitleCell;
- (BOOL)isViewLoaded;

- (void)didClose;

@property (nonatomic) WKWebViewConfiguration *initialConfiguration;

- (void)didInteract;
@property (nonatomic) CFAbsoluteTime lastInteractionTime;

@end
