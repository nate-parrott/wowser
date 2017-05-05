//
//  WWAutocompleteDropdownView.h
//  wowser
//
//  Created by Nate Parrott on 5/4/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "WWAutocompletion.h"

@interface WWAutocompleteDropdownView : NSView

@property (nonatomic) NSArray<NSObject<WWAutocompletion> *> *completions;
@property (nonatomic) NSObject<WWAutocompletion> *selectedCompletion;

- (NSSize)preferredContentSize;

@property (nonatomic, copy) void (^onPickedCompletion)(NSObject<WWAutocompletion> *completion);

@end
