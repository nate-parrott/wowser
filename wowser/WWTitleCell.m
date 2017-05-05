//
//  WWTitleCell.m
//  wowser
//
//  Created by Nate Parrott on 4/13/17.
//  Copyright © 2017 Nate Parrott. All rights reserved.
//

#import "WWTitleCell.h"
#import "WWTransformView.h"
#import "WWWindowController.h"
#import "WWAutocompleteDropdownView.h"
@import QuartzCore;

@interface WWTitleCell () <NSTextFieldDelegate> {
    NSTrackingArea *_trackingArea;
    NSPopover *_popover;
}

@property (nonatomic) NSTextField *title, *url;
@property (nonatomic) NSImageView *divider;
@property (nonatomic) NSButton *closeButton, *menuButton;

@property (nonatomic) WWTransformView *titleTransformView, *urlTransformView;
@property (nonatomic) BOOL urlFieldFocused, mouseHovering, urlVisible;

@property (nonatomic) NSArray<NSObject<WWAutocompletion> *> *autocompletions; // popover will be shown if autocompletions != nil
@property (nonatomic) BOOL popoverVisible;
@property (nonatomic, weak) WWAutocompleteDropdownView *dropdownView;

@end



@implementation WWTitleCell

- (instancetype)init {
    self = [super init];
    
    self.wantsLayer = YES;
    
    self.urlTransformView = [WWTransformView new];
    [self addSubview:self.urlTransformView];
    
    self.titleTransformView = [WWTransformView new];
    [self addSubview:self.titleTransformView];
    
    self.title = [NSTextField new];
    self.title.bezeled = NO;
    self.title.editable = NO;
    self.title.drawsBackground = NO;
    self.title.selectable = NO;
    self.title.alignment = NSTextAlignmentCenter;
    self.title.stringValue = @"This is a Tab";
    self.title.font = [NSFont systemFontOfSize:14 weight:NSFontWeightMedium];
    self.title.textColor = [NSColor colorWithWhite:0 alpha:0.66];
    self.title.maximumNumberOfLines = 1;
    self.title.cell.truncatesLastVisibleLine = YES;
    self.titleTransformView.content = self.title;
    
    self.url = [NSTextField new];
    self.url.bezeled = NO;
    self.url.drawsBackground = NO;
    self.url.alignment = NSTextAlignmentCenter;
    self.url.font = [NSFont systemFontOfSize:12 weight:NSFontWeightRegular];
    self.url.stringValue = @"https://google.com";
    self.url.layer.opacity = 0;
    self.url.focusRingType = NSFocusRingTypeNone;
    self.url.delegate = self;
    self.url.target = self;
    self.url.action = @selector(textFieldDidReturn:);
    self.url.maximumNumberOfLines = 1;
    self.url.cell.truncatesLastVisibleLine = YES;
    self.urlTransformView.content = self.url;
    
    self.divider = [NSImageView imageViewWithImage:[NSImage imageNamed:@"TabDivider"]];
    [self addSubview:self.divider];
    
    self.closeButton = [NSButton buttonWithImage:[NSImage imageNamed:@"Close"] target:self action:@selector(close:)];
    self.menuButton = [NSButton buttonWithImage:[NSImage imageNamed:@"Chevron"] target:self action:@selector(showMenu:)];
    for (NSButton *b in @[self.closeButton, self.menuButton]) {
        [self addSubview:b];
        b.bordered = NO;
        b.alphaValue = 0.35;
    }
    
    self.urlVisible = NO;
    
    self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    
    return self;
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    [super viewWillMoveToWindow:newWindow];
    
    if (newWindow == nil && self.window) {
        // remove the observer for the window we're leaving:
        [[NSNotificationCenter defaultCenter] removeObserver:self name:WWWindowDidChangeFirstResponderNotification object:self.window];
    }
    
    if (newWindow) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstResponderChanged) name:WWWindowDidChangeFirstResponderNotification object:newWindow];
    }
}

- (void)layout {
    [super layout];
    
    CGFloat buttonWidth = self.bounds.size.height;
    self.closeButton.frame = NSMakeRect(0, 0, buttonWidth, self.bounds.size.height);
    self.menuButton.frame = NSMakeRect(self.bounds.size.width - buttonWidth, 0, buttonWidth, self.bounds.size.height);
    
    self.titleTransformView.frame = NSMakeRect(0, 0, self.bounds.size.width, 30 + 15);
    self.urlTransformView.frame = NSMakeRect(buttonWidth, 0, self.bounds.size.width - buttonWidth * 2, 29);
    self.titleTransformView.insets = NSEdgeInsetsMake(15, 0, 0, 0);
    
    CGSize imageSize = self.divider.image.size;
    self.divider.frame = NSMakeRect(self.bounds.size.width - imageSize.width, 0, imageSize.width, imageSize.height);
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    if (_trackingArea) {
        [self removeTrackingArea:_trackingArea];
    }
    _trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

- (void)firstResponderChanged {
    NSResponder *responder = self.window.firstResponder;
    if ([responder isKindOfClass:[NSView class]]) {
        NSView *responderView = (NSView *)responder;
        self.urlFieldFocused = (responderView == self.url || [responderView isDescendantOf:self.url]);
    } else {
        self.urlFieldFocused = NO;
    }
}

#pragma mark URL visibility

- (BOOL)shouldShowUrlField {
    return self.mouseHovering || self.urlFieldFocused;
}

- (void)mouseEntered:(NSEvent *)event {
    self.mouseHovering = YES;
    [self setUrlVisible:[self shouldShowUrlField] animated:YES];
}

- (void)mouseExited:(NSEvent *)event {
    self.mouseHovering = NO;
    [self setUrlVisible:[self shouldShowUrlField] animated:YES];
}

- (void)setUrlVisible:(BOOL)urlVisible {
    [self setUrlVisible:urlVisible animated:NO];
}

- (void)setUrlVisible:(BOOL)urlVisible animated:(BOOL)animated {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.allowsImplicitAnimation = YES;
        self.urlTransformView.alphaValue = urlVisible ? 1 : 0;
        self.titleTransformView.alphaValue = urlVisible ? 0.5 : 1;
        self.menuButton.alphaValue = urlVisible ? 0.35 : 0;
        self.closeButton.alphaValue = urlVisible ? 0.35 : 0;
        if (urlVisible) {
            self.urlTransformView.animator.transform = CATransform3DIdentity;
            self.titleTransformView.animator.transform = CATransform3DTranslate(CATransform3DMakeScale(0.8, 0.8, 1), 0, 20, 0);
        } else {
            self.urlTransformView.animator.transform = CATransform3DTranslate(CATransform3DMakeScale(0.8, 0.8, 1), 0, -5, 0);
            self.titleTransformView.animator.transform = CATransform3DIdentity;
        }
    } completionHandler:^{
        
    }];
}

#pragma mark URL field

- (void)setUrlFieldFocused:(BOOL)urlFieldFocused {
    if (urlFieldFocused != _urlFieldFocused) {
        _urlFieldFocused = urlFieldFocused;
        [self setUrlVisible:[self shouldShowUrlField] animated:YES];
        if (urlFieldFocused) {
            // select all text in the field:
            [self.url.currentEditor selectAll:nil];
        } else {
            // reset the field to show the current url:
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.url.stringValue = self.urlString ? : @"";
            });
            self.autocompletions = nil;
        }
    }
}

- (void)controlTextDidChange:(NSNotification *)obj {
    NSMutableArray *completions = [NSMutableArray new];
    NSInteger count = arc4random() % 5 + 1;
    for (NSInteger i=0; i<count; i++) {
        WWTestAutocompletion *ac = [WWTestAutocompletion new];
        NSString *query = [self urlFieldValueDisregardingSelection];
        ac.title = [query stringByAppendingString:query];
        ac.potentialTypingCompletions = @[ac.title];
        [completions addObject:ac];
    }
    self.autocompletions = completions;
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector {
    
    if (commandSelector == @selector(moveUp:)) {
        [self adjustIndexOfSelectedAutocompleteBy:-1];
        return YES;
    }
    if( commandSelector == @selector(moveDown:) ){
        [self adjustIndexOfSelectedAutocompleteBy:1];
        return YES;
    }
    
    return NO;
}

- (void)textFieldDidReturn:(NSTextField *)field {
    [self.delegate titleCell:self didTypeReturnWithText:field.stringValue];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.window makeFirstResponder:nil];
    });
}

- (void)setUrlString:(NSString *)urlString {
    _urlString = urlString;
    if (!self.urlFieldFocused) {
        self.url.stringValue = urlString;
    }
}

- (NSString *)urlFieldValueDisregardingSelection {
    NSString *str = self.url.stringValue;
    NSRange selectedRange = self.url.currentEditor.selectedRange;
    // is there a selection at the end of the string?
    if ([self urlFieldCursorIsAtEnd]) {
        str = [str stringByReplacingCharactersInRange:selectedRange withString:@""];
    }
    return str;
}

- (BOOL)urlFieldCursorIsAtEnd {
    NSString *str = self.url.stringValue;
    NSRange selectedRange = self.url.currentEditor.selectedRange;
    return (selectedRange.location != NSNotFound && selectedRange.location + selectedRange.length == str.length);
}

#pragma mark Actions

- (IBAction)close:(id)sender {
    [self.delegate titleCellWantsToCloseTab:self];
}

- (IBAction)showMenu:(id)sender {
    [self.delegate titleCell:self wantsTabMenuWithSource:sender];
}

- (void)focusAndSelectText {
    [self.url becomeFirstResponder];
}

#pragma mark Autocompletions popover

- (void)setAutocompletions:(NSArray<NSObject<WWAutocompletion> *> *)autocompletions {
    _autocompletions = autocompletions;
    self.popoverVisible = autocompletions != nil;
    self.dropdownView.completions = autocompletions;
    self.dropdownView.selectedCompletion = nil;
    [self updateURLFieldTypeahead];
}

- (void)adjustIndexOfSelectedAutocompleteBy:(NSInteger)delta {
    NSInteger index = -1;
    if (self.dropdownView.selectedCompletion) {
        index = [self.dropdownView.completions indexOfObject:self.dropdownView.selectedCompletion];
    }
    index += delta;
    index = MIN((NSInteger)self.dropdownView.completions.count-1, MAX(-1, index));
    self.dropdownView.selectedCompletion = (index == -1) ? nil : self.dropdownView.completions[index];
    [self updateURLFieldTypeahead];
}

- (void)updateURLFieldTypeahead {
    NSString *typeahead = @"";
    NSString *typed = [self urlFieldValueDisregardingSelection];
    if (self.dropdownView.selectedCompletion) {
        for (NSString *option in self.dropdownView.selectedCompletion.potentialTypingCompletions) {
            if ([option.lowercaseString rangeOfString:option.lowercaseString].location == 0) {
                typeahead = [option substringFromIndex:typed.length];
                break;
            }
        }
    }
    if ([self urlFieldCursorIsAtEnd]) {
        NSString *newText = [typed stringByAppendingString:typeahead];
        NSRange newSelectedRange = NSMakeRange(typed.length, typeahead.length);
        self.url.stringValue = newText;
        self.url.currentEditor.selectedRange = newSelectedRange;
    }
}

- (BOOL)popoverVisible {
    return _popover != nil;
}

- (void)setPopoverVisible:(BOOL)popoverVisible {
    if (popoverVisible != [self popoverVisible]) {
        if (popoverVisible) {
            // show popover
            _popover = [[NSPopover alloc] init];
            
            WWAutocompleteDropdownView *dropdownView = [WWAutocompleteDropdownView new];
            
            NSViewController *vc = [NSViewController new];
            vc.view = dropdownView;
            self.dropdownView = dropdownView;
            
            _popover.contentViewController = vc;
            _popover.contentSize = NSMakeSize(200, 300);
            [_popover showRelativeToRect:self.bounds ofView:self preferredEdge:NSRectEdgeMinY];
        } else {
            // hide popover
            [_popover close];
            _popover = nil;
        }
    }
}

@end
