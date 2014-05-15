//
//  TTBackgroundView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTPanelController.h"
#import "TTBackgroundView.h"

#define STROKE_OPACITY .5f
#define SEARCH_INSET 10.0f
#define TITLE_BAR_HEIGHT 38.0f
#define MODE_TABS_HEIGHT 92.0f
#define MODE_TITLE_HEIGHT 64.0f
#define MODE_MENU_HEIGHT 146.0f
#define ACTION_MENU_HEIGHT 98.0f
#define MODE_OPTIONS_HEIGHT 148.0f
#define DIAMOND_LABELS_SIZE 270.0f

#pragma mark -

@implementation TTBackgroundView

@synthesize stackView;
@synthesize arrowView;
@synthesize titleBarView;
@synthesize modeTabs;
@synthesize modeTitle;
@synthesize modeMenu;
@synthesize actionMenu;
@synthesize diamondLabels;
@synthesize optionsView;
@synthesize optionsConstraint;

#pragma mark -

- (void)awakeFromNib {
    appDelegate = [NSApp delegate];
    
//    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    arrowView = [[TTPanelArrowView alloc] init];
    titleBarView = [[TTTitleBarView alloc] init];
    modeTabs = [[TTModeTabsContainer alloc] init];
    modeTitle = [[TTModeTitleView alloc] init];
    modeMenu = [[TTModeMenuContainer alloc] initWithType:MODE_MENU_TYPE];
    diamondLabels = [[TTDiamondLabels alloc] init];
    optionsView = [[TTOptionsView alloc] init];
    actionMenu = [[TTModeMenuContainer alloc] initWithType:ACTION_MENU_TYPE];

    stackView = [[NSStackView alloc] init];
    [stackView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [stackView setViews:@[arrowView,
                          titleBarView,
                          modeTabs,
                          modeTitle,
                          modeMenu,
                          diamondLabels,
                          actionMenu,
                          optionsView] inGravity:NSStackViewGravityTop];
    
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:arrowView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:stackView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0 constant:0]];
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:arrowView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:1.0 constant:ARROW_HEIGHT]];
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:titleBarView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:1.0 constant:TITLE_BAR_HEIGHT]];
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:modeTabs
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:1.0 constant:MODE_TABS_HEIGHT]];
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:modeTitle
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:1.0 constant:MODE_TITLE_HEIGHT]];
    modeMenuConstraint = [NSLayoutConstraint constraintWithItem:modeMenu
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:0
                                                     multiplier:1.0 constant:1];
    [stackView addConstraint:modeMenuConstraint];
    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:diamondLabels
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:0 constant:DIAMOND_LABELS_SIZE]];
    actionMenuConstraint = [NSLayoutConstraint constraintWithItem:actionMenu
                                                        attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:0
                                                       multiplier:1.0 constant:0];
    [stackView addConstraint:actionMenuConstraint];
    optionsConstraint = [NSLayoutConstraint constraintWithItem:optionsView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:optionsView.modeOptionsView
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0 constant:0];
    [stackView addConstraint:optionsConstraint];
    
    NSLog(@"Init modeOptionsView View height: %.f", NSHeight(optionsView.modeOptionsView.bounds));
    NSLog(@"Init options View height: %.f", NSHeight(optionsView.bounds));

    [stackView addConstraint:[NSLayoutConstraint constraintWithItem:stackView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:0
                                                         multiplier:0
                                                           constant:360]];
    
    stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    stackView.alignment = NSLayoutAttributeCenterX;
    stackView.spacing = 0;
    
    [self addSubview:stackView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:stackView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:stackView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:stackView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:stackView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0 constant:0.0]];

    [self registerAsObserver];
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedModeChangeMenu"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedActionChangeMenu"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedMode"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(openedModeChangeMenu))]) {
        [self toggleModeMenuFrame];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedActionChangeMenu))]) {
        [self toggleActionMenuFrame];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self resetPosition];
    }
}

#pragma mark - Drawing

- (void)toggleModeMenuFrame {
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 50;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [self.window invalidateShadow];
        [self.window update];
    }];
    
    if (appDelegate.modeMap.openedModeChangeMenu) {
        [[modeMenuConstraint animator] setConstant:MODE_MENU_HEIGHT];
    } else {
        [[modeMenuConstraint animator] setConstant:1];
    }
    
    [NSAnimationContext endGrouping];
}

- (void)toggleActionMenuFrame {
    NSTimeInterval openDuration = OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
    BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
    if (shiftPressed) openDuration *= 10;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [self.window invalidateShadow];
        [self.window update];
    }];
    
    if (appDelegate.modeMap.openedActionChangeMenu) {
        [[actionMenuConstraint animator] setConstant:ACTION_MENU_HEIGHT];
    } else {
        [[actionMenuConstraint animator] setConstant:0];
    }
    
    [NSAnimationContext endGrouping];
}

- (void)adjustOptionsHeight:(NSView *)optionsDetailView {
    if (!stackView) return;
    
    [stackView removeConstraint:optionsConstraint];

    if (!optionsDetailView) {
        optionsConstraint = [NSLayoutConstraint constraintWithItem:optionsView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:0
                                                        multiplier:1.0 constant:0];
        [stackView addConstraint:optionsConstraint];
    } else {
        optionsConstraint = [NSLayoutConstraint constraintWithItem:optionsView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:optionsDetailView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0 constant:0];
        [stackView addConstraint:optionsConstraint];
    }
    
//    NSLog(@"stackView constraints: %@", stackView.constraints);
//    NSLog(@"optionsView constraints: %@", optionsView.constraints);
//    NSLog(@"modeOptionsView constraints: %@", optionsView.modeOptionsView.constraints);
}

- (void)resetPosition {
    [appDelegate.modeMap reset];
    if (appDelegate.modeMap.openedModeChangeMenu) {
        [appDelegate.modeMap setOpenedModeChangeMenu:NO];
    }
    if (appDelegate.modeMap.openedActionChangeMenu) {
        [appDelegate.modeMap setOpenedActionChangeMenu:NO];
    }
}

- (void)viewDidMoveToWindow {
    [[self window] setAcceptsMouseMovedEvents:YES];
}

@end
