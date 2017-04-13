//
//  WWReplicatorView.m
//  wowser
//
//  Created by Nate Parrott on 4/13/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWReplicatorView.h"

@implementation WWReplicatorView

- (instancetype)init {
    self = [super init];
    self.layer = [CAReplicatorLayer layer];
    [self setWantsLayer:YES];
    self.layer.masksToBounds = NO;
    return self;
}

- (CAReplicatorLayer *)replicatorLayer {
    return (CAReplicatorLayer *)self.layer;
}

- (BOOL)wantsDefaultClipping {
    return NO;
}

@end
