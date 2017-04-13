//
//  WWTabScrollView.h
//  wowser
//
//  Created by Nate Parrott on 4/12/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WWTab;

@interface WWTabScrollView : NSScrollView

@property (nonatomic) NSArray <WWTab *> *tabs;

@end
