//
//  TTModeIftttAuthViewController.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "TTAppDelegate.h"
#import "TTModeIfttt.h"

@interface TTModeIftttAuthViewController : NSViewController <WebResourceLoadDelegate> {
    TTAppDelegate *appDelegate;
    NSTimer *checkTokenTimer;
}

@property (nonatomic, strong) TTModeIfttt *modeIfttt;
@property (nonatomic) IBOutlet WebView *webView;
@property (nonatomic) NSPopover *authPopover;

@end
