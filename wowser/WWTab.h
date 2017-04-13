//
//  WWTab.h
//  wowser
//
//  Created by Nate Parrott on 4/12/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WebKit;

@interface WWTab : NSObject

- (NSView *)getOrCreateView;

@end
