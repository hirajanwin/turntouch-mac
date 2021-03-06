//
//  TTModeIfttt.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/12/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIfttt.h"
#import "AFNetworking.h"

@implementation TTModeIfttt

NSString *const kIftttUserIdKey = @"TT:IFTTT:shared_user_id";
NSString *const kIftttDeviceIdKey = @"TT:IFTTT:device_id";
NSString *const kIftttIsActionSetup = @"isActionSetup";
NSString *const kIftttTapType = @"tapType";
NSString *const kIftttAuthorized = @"iftttAuthorized";

static TTIftttState iftttState;

- (instancetype)init {
    if (self = [super init]) {
        [self.delegate changeState:TTModeIfttt.iftttState withMode:self];
    }
    
    return self;
}


#pragma mark - Mode

+ (NSString *)title {
    return @"IFTTT";
}

+ (NSString *)description {
    return @"Buttons for If This Then That";
}

+ (NSString *)imageName {
    return @"mode_ifttt.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeIftttTriggerAction",
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeIftttTriggerAction {
    return @"Trigger action";
}

#pragma mark - Action Images

- (NSString *)imageTTModeIftttTriggerAction {
    return @"lightning";
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeIftttTriggerAction";
}
- (NSString *)defaultEast {
    return @"TTModeIftttTriggerAction";
}
- (NSString *)defaultWest {
    return @"TTModeIftttTriggerAction";
}
- (NSString *)defaultSouth {
    return @"TTModeIftttTriggerAction";
}

#pragma mark - Action methods

- (BOOL)shouldUseModeOptionsFor:(NSString *)actionName {
    if (iftttState != IFTTT_STATE_CONNECTED) {
//        return YES;
    }
    
    return NO;
}

- (void)runTTModeIftttTriggerAction:(TTModeDirection)direction {
    NSLog(@"Running runTTModeIftttTriggerAction");
    [self trigger:NO];
}

- (void)doubleRunTTModeIftttTriggerAction:(TTModeDirection)direction {
    NSLog(@"Running doublerunTTModeIftttTriggerAction");
    [self trigger:YES];
}

- (void)trigger:(BOOL)doubleTap {
    NSString *modeName = [[self.appDelegate.modeMap.selectedMode class] title];
    NSString *modeDirectionName = [self.appDelegate.modeMap directionName:self.modeDirection];
    NSString *actionName = self.action.actionName;
    NSString *actionTitle = [self actionTitleForAction:actionName buttonMoment:BUTTON_MOMENT_PRESSUP];
    NSString *actionDirection = [self.appDelegate.modeMap directionName:self.action.direction];
    NSString *tapType = [self.action optionValue:kIftttTapType];
    NSDictionary *trigger = @{@"app_label": modeName,
                              @"app_direction": modeDirectionName,
                              @"button_label": actionTitle,
                              @"button_direction": actionDirection,
                              @"button_tap_type": tapType,
                              };
    NSDictionary *params = @{@"user_id": [self.appDelegate.modeMap userId],
                             @"device_id": [self.appDelegate.modeMap deviceId],
                             @"triggers": @[trigger],
                             };
    
    NSString *url = @"https://turntouch.com/ifttt/button_trigger";
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@" ---> Button trigger: %@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@" ***> Button trigger failure: %@", error);
    }];
}

#pragma mark - Ifttt Device


- (void)beginConnectingToIfttt:(void (^)(void))callback {
    iftttState = IFTTT_STATE_CONNECTING;
    [self.delegate changeState:iftttState withMode:self];
    
    [self registerTriggers:callback];
}

- (void)cancelConnectingToIfttt {
    iftttState = IFTTT_STATE_CONNECTED;
    [self.delegate changeState:iftttState withMode:self];
}

- (void)iftttReady {
    iftttState = IFTTT_STATE_CONNECTED;
    [self.delegate changeState:iftttState withMode:self];
}

+ (TTIftttState)iftttState {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iftttState = IFTTT_STATE_NOT_CONNECTED;
    });
    return iftttState;
}

+ (void)setIftttState:(TTIftttState)state {
    @synchronized (self) {
        iftttState = state;
    }
}

- (void)registerTriggers:(void (^)(void))callback {
    NSString *url = @"https://turntouch.com/ifttt/register_triggers";
    NSArray *triggers = [self collectTriggers];
    NSDictionary *params = @{@"user_id": [self.appDelegate.modeMap userId],
                             @"device_id": [self.appDelegate.modeMap deviceId],
                             @"triggers": triggers,
                             };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@" ---> Registered IFTTT: %@ / %@", responseObject, params);
        if (callback) callback();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@" ---> IFTTT not authorized, can't register triggers");
        [self cancelConnectingToIfttt];
    }];
    
}

- (void)purgeRecipe:(TTModeDirection)actionDirection callback:(void (^)(void))callback {
    NSString *url = @"https://turntouch.com/ifttt/purge_trigger";
    NSDictionary *params = @{@"user_id": [self.appDelegate.modeMap userId],
                             @"device_id": [self.appDelegate.modeMap deviceId],
                             @"app_direction": [self.appDelegate.modeMap directionName:self.modeDirection],
                             @"button_direction": [self.appDelegate.modeMap directionName:actionDirection],
                             };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@" ---> Purged IFTTT: %@", responseObject);
        if (callback) callback();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@" ---> IFTTT not authorized, can't purge trigger");
        if (callback) callback();
    }];
    
}

- (NSArray *)collectTriggers {
    NSMutableArray *triggers = [NSMutableArray array];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    for (TTMode *mode in @[self.appDelegate.modeMap.northMode,
                           self.appDelegate.modeMap.eastMode,
                           self.appDelegate.modeMap.westMode,
                           self.appDelegate.modeMap.southMode,
                           ]) {
        NSString *modeName = [[mode class] title];
        for (TTModeDirection actionDirection=1; actionDirection <= 4; actionDirection++) {
            NSString *actionName = [mode actionNameInDirection:actionDirection];
            if ([actionName isEqualToString:@"TTModeIftttTriggerAction"]) {
                [triggers addObject:@{
                                     @"app_label": modeName,
                                     @"app_direction": [self.appDelegate.modeMap directionName:mode.modeDirection],
                                     @"button_label": [mode actionTitleForAction:actionName
                                                                     buttonMoment:BUTTON_MOMENT_PRESSUP],
                                     @"button_direction": [self.appDelegate.modeMap directionName:actionDirection],
                                     @"button_tap_type": [self.appDelegate.modeMap mode:mode
                                                                 actionOptionValue:kIftttTapType
                                                                        actionName:actionName
                                                                       inDirection:actionDirection],
                                     }];
            }
            
            NSString *modeBatchActionKey = [self.appDelegate.modeMap.batchActions
                                           modeBatchActionKey:mode.modeDirection
                                           actionDirection:actionDirection];
            NSArray *batchActionKeys = [prefs objectForKey:modeBatchActionKey];
            for (NSString *batchActionKey in batchActionKeys) {
                if ([batchActionKey containsString:@"TTModeIftttTriggerAction"]) {
                    TTAction *action = [[TTAction alloc] initWithBatchActionKey:batchActionKey
                                                                      direction:actionDirection];
                    action.mode.modeDirection = mode.modeDirection;
                    NSString *appDirection = [self.appDelegate.modeMap directionName:mode.modeDirection];
                    NSString *buttonLabel = [mode actionTitleForAction:actionName
                                                          buttonMoment:BUTTON_MOMENT_PRESSUP];
                    NSString *tapType = [self.appDelegate.modeMap mode:action.mode batchAction:action
                                                actionOptionValue:kIftttTapType
                                                      inDirection:actionDirection];
                    [triggers addObject:@{
                                          @"app_label": modeName,
                                          @"app_direction": appDirection,
                                          @"button_label": buttonLabel,
                                          @"button_direction": [self.appDelegate.modeMap directionName:actionDirection],
                                          @"button_tap_type": tapType,
                                          }];
                }
            }
        }
    }
    
    return triggers;
}

@end
