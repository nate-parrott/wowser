//
//  WWTransformView.h
//  wowser
//
//  Created by Nate Parrott on 4/16/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WWTransformView : NSView

@property (nonatomic) CATransform3D transform;
@property (nonatomic) NSView *content;
@property (nonatomic) NSEdgeInsets insets;

@end
