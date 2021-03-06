//
//  TTTitleBarView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/9/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTSettingsButton.h"

@class TTAppDelegate;

@interface TTTitleBarView : NSView <NSStackViewDelegate, NSMenuDelegate>

@property (nonatomic, strong) TTAppDelegate *appDelegate;

@end
