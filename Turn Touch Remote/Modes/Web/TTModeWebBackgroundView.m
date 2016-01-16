//
//  TTModeWebBackgroundView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/30/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTAppDelegate.h"
#import "TTModeWeb.h"
#import "TTModeWebBackgroundView.h"

@implementation TTModeWebBackgroundView

- (void)awakeFromNib {
    self.material = NSVisualEffectMaterialDark;
    self.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    self.state = NSVisualEffectStateActive;
    [self setWantsLayer:YES];
    
    NSTrackingAreaOptions options = (NSTrackingActiveAlways | NSTrackingInVisibleRect |
                                     NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved);
    
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                options:options
                                                  owner:self
                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)mouseMoved:(NSEvent *)theEvent {
    if (![NSAppDelegate.modeMap.selectedMode isKindOfClass:[TTModeWeb class]]) {
        [self removeTrackingArea:trackingArea];
        return;
    }
    [(TTModeWeb *)NSAppDelegate.modeMap.selectedMode startHideMouseTimer];
}


@end
