//
//  WWAutocompleteDropdownView.m
//  wowser
//
//  Created by Nate Parrott on 5/4/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWAutocompleteDropdownView.h"


static const CGFloat WWAutocompleteEntryFieldContentHeight = 20;
static const CGFloat WWAutocompleteEntryPadding = 20;
static const NSInteger WWAutocompleteMaxItems = 7;

@interface WWAutocompleteDropdownView ()

@property (nonatomic) NSView *highlightView;
@property (nonatomic) NSArray<NSButton *> *buttons;

@end


@implementation WWAutocompleteDropdownView

#pragma mark API

- (void)setCompletions:(NSArray<NSObject<WWAutocompletion> *> *)completions {
    _completions = completions;
    for (NSInteger i=0; i<completions.count; i++) {
        [self assignButton:self.buttons[i] toCompletion:completions[i]];
    }
    [self setNeedsLayout:YES];
}

- (NSSize)preferredContentSize {
    // compute the content height for N items:
    CGFloat height = WWAutocompleteMaxItems * WWAutocompleteEntryFieldContentHeight + (WWAutocompleteMaxItems + 1) * WWAutocompleteEntryPadding;
    return NSMakeSize(200, height);
}

- (void)setSelectedCompletion:(NSObject<WWAutocompletion> *)selectedCompletion {
    _selectedCompletion = selectedCompletion;
    [self setNeedsLayout:YES];
}

#pragma mark Subviews and layout

- (NSArray<NSButton *> *)buttons {
    if (!_buttons) {
        NSMutableArray *buttons = [NSMutableArray new];
        for (NSInteger i=0; i<WWAutocompleteMaxItems; i++) {
            NSButton *b = [NSButton buttonWithTitle:@"" target:self action:@selector(clickedButton:)];
            b.bordered = NO;
            [self addSubview:b];
            [buttons addObject:b];
        }
        _buttons = buttons;
    }
    return _buttons;
}

- (NSView *)highlightView {
    if (!_highlightView) {
        _highlightView = [NSView new];
        _highlightView.wantsLayer = YES;
        _highlightView.layer.backgroundColor = [NSColor colorWithWhite:0 alpha:0.05].CGColor;
        if (self.subviews.firstObject) {
            [self addSubview:_highlightView positioned:NSWindowBelow relativeTo:self.subviews.firstObject];
        } else {
            [self addSubview:_highlightView];
        }
    }
    return _highlightView;
}

- (void)layout {
    [super layout];
    
    CGFloat highlightViewYPos = - (WWAutocompleteEntryFieldContentHeight + WWAutocompleteEntryPadding);
    
    NSArray *buttons = [self buttons];
    for (NSInteger i=0; i<buttons.count; i++) {
        NSButton *button = buttons[i];
        button.hidden = (i >= self.completions.count);
        CGFloat y = i * WWAutocompleteEntryFieldContentHeight + (i + 0.5) * WWAutocompleteEntryPadding;
        button.frame = NSMakeRect(WWAutocompleteEntryPadding, y, self.bounds.size.width - WWAutocompleteEntryPadding * 2, WWAutocompleteEntryFieldContentHeight + WWAutocompleteEntryPadding);
        if (i < self.completions.count && self.selectedCompletion == self.completions[i]) {
            highlightViewYPos = button.frame.origin.y;
        }
    }
    
    self.highlightView.frame = NSMakeRect(0, highlightViewYPos, self.bounds.size.width, WWAutocompleteEntryFieldContentHeight + WWAutocompleteEntryPadding);
}

- (BOOL)isFlipped {
    return YES;
}

#pragma mark Helpers

- (void)assignButton:(NSButton *)button toCompletion:(NSObject<WWAutocompletion> *)completion {
    button.title = completion.title ? : @"";
}

- (void)clickedButton:(NSButton *)sender {
    self.onPickedCompletion(self.completions[[self.buttons indexOfObject:sender]]);
}


@end
