//
//  TTDiamondLabels.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/7/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTDiamondLabel.h"
#import "TTDiamondView.h"

@class TTAppDelegate;
@class TTDiamondLabel;

@interface TTDiamondLabels : NSView {
    TTAppDelegate *appDelegate;
    NSRect diamondRect;
    CGSize textSize;
    BOOL interactive;
    
    TTDiamondLabel *northLabel;
    TTDiamondLabel *eastLabel;
    TTDiamondLabel *westLabel;
    TTDiamondLabel *southLabel;
    
    TTDiamondView *diamondView;
}

@property (nonatomic) NSRect diamondRect;
@property (nonatomic, readwrite) BOOL interactive;

- (id)initWithInteractive:(BOOL)_interactive;
- (void)drawLabels;

@end
