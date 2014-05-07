//
//  TTMode.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import <ScriptingBridge/ScriptingBridge.h>

@implementation TTMode

- (id)init {
    self = [super init];
    if (self) {
        appDelegate = [NSApp delegate];
    }
    return self;
}
#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTAction1",
             @"TTAction2",
             @"TTAction3",
             @"TTAction4"
             ];
}

#pragma mark - Mode

+ (NSString *)title {
    return @"TT Mode";
}

+ (NSString *)description {
    return @"Stub mode to be filled in";
}

+ (NSString *)imageName {
    return @"equalizer-1";
}

#pragma mark - Action Titles

- (NSString *)titleTTAction1 {
    return @"Action 1st";
}
- (NSString *)titleTTAction2 {
    return @"Action 2nd";
}
- (NSString *)titleTTAction3 {
    return @"Action 3rd";
}
- (NSString *)titleTTAction4 {
    return @"Action 4th";
}

#pragma mark - Action methods

- (void)runTTAction1 {
    NSLog(@"Running TTAction1");
}
- (void)runTTAction2 {
    NSLog(@"Running TTAction2");
}
- (void)runTTAction3 {
    NSLog(@"Running TTAction3");
}
- (void)runTTAction4 {
    NSLog(@"Running TTAction4");
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTAction1";
}
- (NSString *)defaultEast {
    return @"TTAction2";
}
- (NSString *)defaultWest {
    return @"TTAction3";
}
- (NSString *)defaultSouth {
    return @"TTAction4";
}

#pragma mark - Map directions to actions

- (void)runDirection:(TTModeDirection)direction {
    NSString *actionName = [self actionNameInDirection:direction];
    NSLog(@"Running: %d - %@", direction, actionName);

    // TODO: Assert selector exists
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"title%@",
                                         actionName]);
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(self, selector);
}

- (NSString *)titleInDirection:(TTModeDirection)direction {
    NSString *actionName = [self actionNameInDirection:direction];
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"title%@",
                                         actionName]);
    IMP imp = [self methodForSelector:selector];
    NSString *(*func)(id, SEL) = (void *)imp;
    NSString *actionTitle = func(self, selector);

    return actionTitle;
}

- (NSImage *)imageInDirection:(TTModeDirection)direction {
    NSString *actionName = [self actionNameInDirection:direction];
    
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"image%@",
                                         actionName]);
    IMP imp = [self methodForSelector:selector];
    NSImage *(*func)(id, SEL) = (void *)imp;
    NSImage *actionImage = func(self, selector);
    
    return actionImage;
}

- (NSString *)actionNameInDirection:(TTModeDirection)direction {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *directionAction = [defaults stringForKey:[NSString stringWithFormat:@"%@-%d:action:%d",
                                                        [self class],
                                                        appDelegate.modeMap.selectedModeDirection,
                                                        direction]];
    if (directionAction && ![self.actions containsObject:directionAction]) {
        directionAction = nil;
    }
    if (!directionAction) {
        if (direction == NORTH) {
            directionAction = [self defaultNorth];
        } else if (direction == EAST) {
            directionAction = [self defaultEast];
        } else if (direction == WEST) {
            directionAction = [self defaultWest];
        } else if (direction == SOUTH) {
            directionAction = [self defaultSouth];
        }
    }
    
    return directionAction;
}
@end
