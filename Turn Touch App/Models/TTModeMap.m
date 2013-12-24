//
//  TTDiamond.m
//  Turn Touch App
//
//  Created by Samuel Clay on 8/21/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMap.h"
#import "TTModeMusic.h"
#import "TTModeVideo.h"
#import "TTModeAlarmClock.h"
#import "TTModeNews.h"
#import "TTModeMac.h"

@implementation TTModeMap

@synthesize selectedModeDirection;
@synthesize activeModeDirection;
@synthesize selectedMode;
@synthesize northMode;
@synthesize eastMode;
@synthesize westMode;
@synthesize southMode;

- (id)init {
    if (self = [super init]) {
        [self addObserver:self
               forKeyPath:@"selectedModeDirection"
                  options:0 context:nil];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [self setupModes];
        
        if ([[defaults objectForKey:@"TT:selectedModeDirection"] integerValue]) {
            selectedModeDirection = (TTModeDirection)[[defaults
                                                       objectForKey:@"TT:selectedModeDirection"]
                                                      integerValue];
            [self switchMode];
        }
    }
    
    return self;
}

- (void)setupModes {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    for (NSString *direction in @[@"north", @"east", @"west", @"south"]) {
        NSString *directionModeName = [prefs stringForKey:[NSString stringWithFormat:@"mode:%@", direction]];
        Class modeClass = NSClassFromString(directionModeName);
        [self setValue:[[modeClass alloc] init] forKey:[NSString stringWithFormat:@"%@Mode", direction]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:selectedModeDirection]
                 forKey:@"TT:selectedModeDirection"];
    [defaults synchronize];
    
    [self switchMode];
}

- (void)switchMode {
    if (selectedMode) {
        if ([selectedMode respondsToSelector:@selector(deactivate)]) {
            [selectedMode deactivate];
        }
        selectedMode = nil;
    }
    
    switch (selectedModeDirection) {
        case NORTH:
            selectedMode = northMode;
            break;
            
        case EAST:
            selectedMode = eastMode;
            break;
            
        case WEST:
            selectedMode = westMode;
            break;

        case SOUTH:
            selectedMode = southMode;
            break;
    }
    
    if (selectedMode && [selectedMode respondsToSelector:@selector(activate)]) {
        [selectedMode activate];
    }
}

- (void)runActiveButton {
    TTModeDirection direction = activeModeDirection;
    activeModeDirection = 0;
    
    if (!selectedMode) return;
    
    if (direction == NORTH) {
        [selectedMode runNorth];
    } else if (direction == EAST) {
        [selectedMode runEast];
    } else if (direction == WEST) {
        [selectedMode runWest];
    } else if (direction == SOUTH) {
        [selectedMode runSouth];
    }
    activeModeDirection = 0;
}

@end
