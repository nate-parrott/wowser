//
//  WWTransformView.m
//  wowser
//
//  Created by Nate Parrott on 4/16/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWTransformView.h"

@implementation WWTransformView

- (instancetype)init {
    self = [super init];
    self.wantsLayer = YES;
    self.transform = CATransform3DIdentity;
    return self;
}

- (void)setTransform:(CATransform3D)transform {
    _transform = transform;
    [self updateTransform];
}

- (void)updateTransform {
    CATransform3D origin = CATransform3DMakeTranslation(self.bounds.size.width/2, self.bounds.size.height/2, 0);
    CATransform3D unorigin = CATransform3DMakeTranslation(-self.bounds.size.width/2, -self.bounds.size.height/2, 0);
    self.layer.sublayerTransform = CATransform3DConcat(unorigin, CATransform3DConcat(self.transform, origin));
}

- (void)setContent:(NSView *)content {
    [_content removeFromSuperview];
    _content = content;
    if (content) [self addSubview:content];
}

- (void)layout {
    [super layout];
    [self updateTransform];
    self.content.frame = NSMakeRect(self.insets.left, self.insets.bottom, self.bounds.size.width - self.insets.left - self.insets.right, self.bounds.size.height - self.insets.top - self.insets.bottom);
}

@end
