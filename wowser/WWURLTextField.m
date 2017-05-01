//
//  WWURLTextField.m
//  wowser
//
//  Created by Nate Parrott on 5/1/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWURLTextField.h"


NSString *const WWURLTextFieldDidBecomeFirstResponderNotification = @"WWURLTextFieldDidBecomeFirstResponderNotification";
NSString *const WWURLTextFieldDidResignFirstResponderNotification = @"WWURLTextFieldDidResignFirstResponderNotification";

@implementation WWURLTextField

- (BOOL)becomeFirstResponder {
    BOOL s = [super becomeFirstResponder];
    if (s) {
        [self performSelector:@selector(_postNotification:) withObject:WWURLTextFieldDidBecomeFirstResponderNotification afterDelay:0];
    }
    return s;
}

- (BOOL)resignFirstResponder {
    BOOL s = [super resignFirstResponder];
    if (s) {
        [self performSelector:@selector(_postNotification:) withObject:WWURLTextFieldDidResignFirstResponderNotification afterDelay:0];
    }
    return s;
}

- (void)_postNotification:(NSString *)name {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self];
}

@end
