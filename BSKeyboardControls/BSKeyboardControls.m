//
//  BSKeyboardControls.m
//  Example
//
//  Created by Simon B. Støvring on 11/01/13.
//  Copyright (c) 2013 simonbs. All rights reserved.
//

#import "BSKeyboardControls.h"

@interface BSKeyboardControls ()
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIBarButtonItem *prevButton;
@property (nonatomic, strong) UIBarButtonItem *nextButton;

- (void)prevButtonPressed:(id)sender;
- (void)nextButtonPressed:(id)sender;
- (void)updatePrevNextStates;
@end

@implementation BSKeyboardControls

#pragma mark -
#pragma mark Lifecycle

- (id)initWithFields:(NSArray *)fields
{
    if (self = [super init])
    {
        self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
        [self.toolbar setBarStyle:UIBarStyleBlackTranslucent];
        [self.toolbar setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth)];
        
        self.prevButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Prev", @"BSKeyboardControls", @"Previous button title.")
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(prevButtonPressed:)];
        self.nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Next", @"BSKeyboardControls", @"Next button title.")
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self
                                                          action:@selector(nextButtonPressed:)];
        
        self.doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Done", @"BSKeyboardControls", @"Done button title.")
                                                           style:UIBarButtonItemStyleDone
                                                          target:self
                                                          action:@selector(doneButtonPressed:)];
        
        [self setVisibleControls:(BSKeyboardControlAll)];
        
        self.fields = fields;
    }
    
    return self;
}

- (void)dealloc
{
    [self setFields:nil];
    [self setActiveField:nil];
    [self setToolbar:nil];
    [self setDoneButton:nil];
}

#pragma mark -
#pragma mark Public Methods

- (void)setActiveField:(id)activeField
{
    if (activeField != _activeField)
    {
        if ([self.fields containsObject:activeField])
        {
            _activeField = activeField;
        
            if (![activeField isFirstResponder])
            {
                [activeField becomeFirstResponder];
            }
        
            [self updatePrevNextStates];
        }
    }
}

- (void)setFields:(NSArray *)fields
{
    if (fields != _fields)
    {
        for (UIView *field in fields) {
            if ([field respondsToSelector:@selector(setInputAccessoryView:)]) {
                [field performSelector:@selector(setInputAccessoryView:) withObject:self.toolbar];
            }
        }
        _fields = fields;
    }
}

- (void)setBarStyle:(UIBarStyle)barStyle
{
    self.toolbar.barStyle = barStyle;
}

- (UIBarStyle)barStyle
{
    return self.toolbar.barStyle;
}

- (void)setBarTintColor:(UIColor *)barTintColor
{
    [self.toolbar setTintColor:barTintColor];
}

- (UIColor *)barTintColor
{
    return self.toolbar.tintColor;
}

- (void)setPreviousTitle:(NSString *)previousTitle
{
    self.prevButton.title = previousTitle;
}

- (NSString *)previousTitle
{
    return self.prevButton.title;
}

- (void)setNextTitle:(NSString *)nextTitle
{
    self.nextButton.title = nextTitle;

}

- (NSString *)nextTitle
{
    return self.nextButton.title;
}

- (void)setDoneTitle:(NSString *)doneTitle
{
    [self.doneButton setTitle:doneTitle];
}

- (NSString *)doneTitle
{
    return self.doneButton.title;
}


- (void)setDoneTintColor:(UIColor *)doneTintColor
{
    [self.doneButton setTintColor:doneTintColor];
}

- (UIColor *)doneTintColor
{
    return self.doneButton.tintColor;
}

- (void)setVisibleControls:(BSKeyboardControl)visibleControls
{
    if (visibleControls != _visibleControls)
    {
        _visibleControls = visibleControls;

        [self.toolbar setItems:[self toolbarItems]];
    }
}

#pragma mark - Private Methods

- (void)prevButtonPressed:(id)sender
{
    [self selectPreviousField];
}

- (void)nextButtonPressed:(id)sender
{
    [self selectNextField];
}

- (void)doneButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(keyboardControlsDonePressed:)])
    {
        [self.delegate keyboardControlsDonePressed:self];
    }
}

- (void)updatePrevNextStates
{
    NSInteger index = [self.fields indexOfObject:self.activeField];
    if (index != NSNotFound)
    {
        [self.prevButton setEnabled:(index > 0)];
        [self.nextButton setEnabled:(index < [self.fields count] - 1)];
    }
}

- (void)selectPreviousField
{
    NSInteger index = [self.fields indexOfObject:self.activeField];
    if (index > 0)
    {
        index -= 1;
        UIView *field = [self.fields objectAtIndex:index];
        [self setActiveField:field];
        
        if ([self.delegate respondsToSelector:@selector(keyboardControls:selectedField:inDirection:)])
        {
            [self.delegate keyboardControls:self selectedField:field inDirection:BSKeyboardControlsDirectionPrevious];
        }
    }
}

- (void)selectNextField
{
    NSInteger index = [self.fields indexOfObject:self.activeField];
    if (index < [self.fields count] - 1)
    {
        index += 1;
        UIView *field = [self.fields objectAtIndex:index];
        [self setActiveField:field];
        
        if ([self.delegate respondsToSelector:@selector(keyboardControls:selectedField:inDirection:)])
        {
            [self.delegate keyboardControls:self selectedField:field inDirection:BSKeyboardControlsDirectionNext];
        }
    }
}

- (NSArray *)toolbarItems
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:3];
    if (self.visibleControls & BSKeyboardControlPrevious)
    {
        [items addObject:self.prevButton];
    }
    if (self.visibleControls & BSKeyboardControlNext)
    {
        [items addObject:self.nextButton];
    }
    
    if (self.visibleControls & BSKeyboardControlDone)
    {
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
        [items addObject:self.doneButton];
    }
    
    return items;
}

@end
