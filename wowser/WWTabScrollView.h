//
//  WWTabScrollView.h
//  wowser
//
//  Created by Nate Parrott on 4/12/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WWTab;

@interface WWTabScrollView : NSView

@property (nonatomic) NSArray <WWTab *> *tabs;
@property (nonatomic) CGPoint contentOffset;
@property (nonatomic) CGSize contentSize;

@property (nonatomic, copy) void (^onScroll)(CGPoint offset);

@end
