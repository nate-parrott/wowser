//
//  WWAutocompletion.h
//  wowser
//
//  Created by Nate Parrott on 5/4/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class WWTab;

@protocol WWAutocompletion

- (NSString *)title;
- (NSArray<NSString *> *)potentialTypingCompletions;
- (NSURL *)url;

@end

@interface WWTestAutocompletion: NSObject<WWAutocompletion>

@property (nonatomic) NSString *title;
@property (nonatomic) NSArray<NSString *> *potentialTypingCompletions;
@property (nonatomic) NSURL *url;

@end
