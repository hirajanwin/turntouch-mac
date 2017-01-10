//
//  TTOptionsActionTitle.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/27/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTOptionsActionTitle.h"

#define X_MARGIN 12.0f
#define Y_MARGIN 24.0f
#define DIAMOND_SIZE 18.0f
#define BUTTON_WIDTH 82.0f
#define BUTTON_HEIGHT 24.0f

@implementation TTOptionsActionTitle

@synthesize changeButton;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self registerAsObserver];
        [self setupLabels];
        
        diamondView = [[TTDiamondView alloc] initWithFrame:CGRectZero];
        [diamondView setIgnoreSelectedMode:YES];
        [diamondView setIgnoreActiveMode:YES];
        [diamondView setOverrideActiveDirection:appDelegate.modeMap.inspectingModeDirection];
        [self addSubview:diamondView];

        changeButton = [[TTChangeButtonView alloc] init];
        [self setChangeButtonTitle:@"Change"];
        [changeButton setBezelStyle:NSRoundRectBezelStyle];
        [changeButton setAction:@selector(showChangeActionMenu:)];
        [changeButton setTarget:self];
        [self addSubview:changeButton];
    }
    return self;
}

#pragma mark - KVO

- (void)dealloc {
    [appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
}

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        [diamondView setOverrideActiveDirection:appDelegate.modeMap.inspectingModeDirection];
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    NSRect diamondRect = NSMakeRect(X_MARGIN, NSMaxY(self.bounds) - DIAMOND_SIZE/2 - Y_MARGIN,
                                    DIAMOND_SIZE * 1.3, DIAMOND_SIZE);
    [diamondView setFrame:diamondRect];
    
    NSRect buttonFrame = NSMakeRect(NSWidth(self.bounds) - BUTTON_WIDTH - 12,
                                    NSMaxY(self.bounds) - BUTTON_HEIGHT/2 - Y_MARGIN,
                                    BUTTON_WIDTH,
                                    BUTTON_HEIGHT);
    changeButton.frame = buttonFrame;
}

- (void)drawRect:(NSRect)dirtyRect {
    if (appDelegate.modeMap.inspectingModeDirection == NO_DIRECTION) return;
    
    [super drawRect:dirtyRect];
    
    TTModeDirection labelDirection = appDelegate.modeMap.inspectingModeDirection;
    
    NSString *actionTitle;
    
    actionTitle = [appDelegate.modeMap.selectedMode titleInDirection:labelDirection buttonMoment:BUTTON_MOMENT_PRESSUP];
    NSSize titleSize = [actionTitle sizeWithAttributes:titleAttributes];
    
    NSPoint titlePoint = NSMakePoint(NSMaxX(diamondView.frame) + X_MARGIN,
                                     NSHeight(self.frame) - Y_MARGIN - floor(titleSize.height/2) + 1);
    
    [actionTitle drawAtPoint:titlePoint withAttributes:titleAttributes];
    
    if (appDelegate.modeMap.openedActionChangeMenu) {
        [self setChangeButtonTitle:@"Done"];
    } else {
        [self setChangeButtonTitle:@"Change"];
    }
}

#pragma mark - Attributes

- (void)setChangeButtonTitle:(NSString *)title {
//    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//    [centredStyle setLineHeightMultiple:0.6f];
//    [centredStyle setAlignment:NSCenterTextAlignment];
//    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
//                           NSParagraphStyleAttributeName,
//                           [NSFont fontWithName:@"Effra" size:10.f],
//                           NSFontAttributeName,
//                           NSColorFromRGB(0xA0A3A8),
//                           NSForegroundColorAttributeName,
//                           nil];
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
//                                                   initWithString:[title uppercaseString] attributes:attrs];
//    [changeButton setAttributedTitle:attributedString];
    [changeButton setTitle:title];
}

- (void)setupLabels {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    titleAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow,
                        NSParagraphStyleAttributeName: style
                        };
}

#pragma mark - Events

- (void)showChangeActionMenu:(id)sender {
    [appDelegate.modeMap setOpenedActionChangeMenu:!appDelegate.modeMap.openedActionChangeMenu];
    [self setNeedsDisplay:YES];
}

@end