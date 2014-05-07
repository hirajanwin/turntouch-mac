//
//  TTMode.h
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAppDelegate.h"
#import "TTModeProtocol.h"

@class TTAppDelegate;

@interface TTMode : NSObject <TTModeProtocol> {
    TTAppDelegate *appDelegate;
}

- (void)runDirection:(TTModeDirection)direction;
- (NSString *)titleInDirection:(TTModeDirection)direction;
- (NSImage *)imageInDirection:(TTModeDirection)direction;

@end
