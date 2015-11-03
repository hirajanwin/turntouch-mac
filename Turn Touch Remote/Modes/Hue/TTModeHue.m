//
//  TTModeHue.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/25/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeHue.h"
#import "TTModeHueSceneOptions.h"
#import "TTModeHueSleepOptions.h"

#define MAX_HUE 65535
#define MAX_BRIGHTNESS 255

@interface TTModeHue()

@property (nonatomic, strong) PHBridgeSearching *bridgeSearch;

@end

@implementation TTModeHue

NSString *const kRandomColors = @"randomColors";
NSString *const kRandomBrightness = @"randomBrightness";
NSString *const kRandomSaturation = @"randomSaturation";
NSString *const kDoubleTapRandomColors = @"doubleTapRandomColors";
NSString *const kDoubleTapRandomBrightness = @"doubleTapRandomBrightness";
NSString *const kDoubleTapRandomSaturation = @"doubleTapRandomSaturation";

@synthesize delegate;
@synthesize hueState;

#pragma mark - Mode

+ (NSString *)title {
    return @"Hue";
}

+ (NSString *)description {
    return @"Lights and scenes";
}

+ (NSString *)imageName {
    return @"mode_hue.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeHueSceneEarlyEvening",
             @"TTModeHueSceneLateEvening",
             @"TTModeHueSleep",
             @"TTModeHueOff",
             @"TTModeHueRandom"
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeHueSceneEarlyEvening {
    return @"Early evening";
}
- (NSString *)doubleTitleTTModeHueSceneEarlyEvening {
    return @"Early evening 2";
}
- (NSString *)titleTTModeHueSceneLateEvening {
    return @"Late evening";
}
- (NSString *)doubleTitleTTModeHueSceneLateEvening {
    return @"Late evening 2";
}
- (NSString *)titleTTModeHueSleep {
    return @"Sleep";
}
- (NSString *)doubleTitleTTModeHueSleep {
    return @"Sleep fast";
}
- (NSString *)titleTTModeHueOff {
    return @"Lights off";
}
- (NSString *)titleTTModeHueRandom {
    return @"Random";
}
- (NSString *)doubleTitleTTModeHueRandom {
    return @"Random 2";
}

#pragma mark - Action Images

- (NSString *)imageTTModeHueSceneEarlyEvening {
    return @"hue_sunset.png";
}
- (NSString *)imageTTModeHueSceneLateEvening {
    return @"hue_evening.png";
}
- (NSString *)imageTTModeHueSleep {
    return @"hue_sleep.png";
}
- (NSString *)imageTTModeHueOff {
    return @"hue_sleep.png";
}
- (NSString *)imageTTModeHueRandom {
    return @"hue_random.png";
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeHueSceneEarlyEvening";
}
- (NSString *)defaultEast {
    return @"TTModeHueSceneLateEvening";
}
- (NSString *)defaultWest {
    return @"TTModeHueRandom";
}
- (NSString *)defaultSouth {
    return @"TTModeHueSleep";
}

#pragma mark - Action methods

- (void)runScene:(TTModeDirection)direction doubleTap:(BOOL)doubleTap {
    if (!self.phHueSDK.localConnected) {
        return;
    }
    
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHScene *activeScene;
    NSString *sceneIdentifier = [appDelegate.modeMap actionOptionValue:(doubleTap ? kDoubleTapHueScene : kHueScene)
                                                           inDirection:direction];

    NSMutableArray *scenes = [[NSMutableArray alloc] init];
    for (PHScene *scene in cache.scenes.allValues) {
        [scenes addObject:@{@"name": scene.name, @"identifier": scene.identifier}];
        if ([scene.identifier isEqualToString:sceneIdentifier]) {
            activeScene = scene;
        }
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [scenes sortUsingDescriptors:@[sd]];
    
    if (!sceneIdentifier || ![sceneIdentifier length]) {
        // Use default, which is first scene in sorted scene list
        sceneIdentifier = scenes[0][@"identifier"];
    }
    
    [bridgeSendAPI activateSceneWithIdentifier:sceneIdentifier onGroup:@"0" completionHandler:^(NSArray *errors) {
        NSLog(@"Scene change: %@ (%@)", sceneIdentifier, errors);
    }];
}

- (void)runTTModeHueSceneEarlyEvening:(TTModeDirection)direction {
    [self runScene:direction doubleTap:NO];
}

- (void)doubleRunTTModeHueSceneEarlyEvening:(TTModeDirection)direction {
    [self runScene:direction doubleTap:YES];
}

- (void)runTTModeHueSceneLateEvening:(TTModeDirection)direction {
    [self runScene:direction doubleTap:NO];
}

- (void)doubleRunTTModeHueSceneLateEvening:(TTModeDirection)direction {
    [self runScene:direction doubleTap:YES];
}

- (void)runTTModeHueOff:(TTModeDirection)direction {
//    NSLog(@"Running scene off... %d", direction);
    [self runTTModeHueSleep:direction duration:@(1)];
}

- (void)runTTModeHueSleep:(TTModeDirection)direction {
    NSNumber *sceneDuration = (NSNumber *)[appDelegate.modeMap actionOptionValue:kHueDuration inDirection:direction];
    [self runTTModeHueSleep:direction duration:sceneDuration];
}

- (void)doubleRunTTModeHueSleep:(TTModeDirection)direction {
    //    NSLog(@"Running scene off... %d", direction);
    NSNumber *sceneDuration = (NSNumber *)[appDelegate.modeMap actionOptionValue:kHueDoubleTapDuration inDirection:direction];
    [self runTTModeHueSleep:direction duration:sceneDuration];
}

- (BOOL)shouldIgnoreSingleBeforeDoubleTTModeHueSceneEarlyEvening {
    return YES;
}

- (BOOL)shouldIgnoreSingleBeforeDoubleTTModeHueSceneLateEvening {
    return YES;
}

- (BOOL)shouldIgnoreSingleBeforeDoubleTTModeHueSleep {
    return YES;
}

- (BOOL)shouldIgnoreSingleBeforeDoubleTTModeHueRandom {
    return YES;
}

- (void)runTTModeHueSleep:(TTModeDirection)direction duration:(NSNumber *)sceneDuration {
    //    NSLog(@"Running scene off... %d", direction);
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    NSNumber *sceneTransition = [NSNumber numberWithInteger:([sceneDuration integerValue] * 10)];

    for (PHLight *light in cache.lights.allValues) {
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setOn:[NSNumber numberWithBool:NO]];
        [lightState setTransitionTime:sceneTransition];
        [lightState setBrightness:[NSNumber numberWithInt:0]];
        
        lightState.transitionTime = sceneTransition;
        lightState.alert = 0;
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            NSLog(@"Sleep light in %@: %@", sceneTransition, errors);
        }];
    }
}

- (void)runTTModeHueRandom:(TTModeDirection)direction {
    [self runTTModeHueRandom:direction doubleTap:NO];
}

- (void)doubleRunTTModeHueRandom:(TTModeDirection)direction {
    [self runTTModeHueRandom:direction doubleTap:YES];
}

- (void)runTTModeHueRandom:(TTModeDirection)direction doubleTap:(BOOL)doubleTap {
    //    NSLog(@"Running scene off... %d", direction);
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    TTHueRandomColors randomColors = (TTHueRandomColors)[[NSAppDelegate.modeMap
                                                          actionOptionValue:doubleTap ? kDoubleTapRandomColors : kRandomColors] integerValue];
    TTHueRandomBrightness randomBrightnesses = (TTHueRandomBrightness)[[NSAppDelegate.modeMap
                                                                        actionOptionValue:doubleTap ? kDoubleTapRandomBrightness : kRandomBrightness] integerValue];
    TTHueRandomSaturation randomSaturation = (TTHueRandomSaturation)[[NSAppDelegate.modeMap
                                                                      actionOptionValue:doubleTap ? kDoubleTapRandomSaturation : kRandomSaturation] integerValue];
    NSNumber *randomColor = [NSNumber numberWithInt:arc4random() % MAX_HUE];
    
    for (PHLight *light in cache.lights.allValues) {
        PHLightState *lightState = [[PHLightState alloc] init];
        
        if ((randomColors == TTHueRandomColorsAllSame) ||
            (randomColors == TTHueRandomColorsSomeDifferent && arc4random() % 10 > 5)) {
            [lightState setHue:randomColor];
        } else {
            [lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
        }

        if (randomBrightnesses == TTHueRandomBrightnessLow) {
            [lightState setBrightness:[NSNumber numberWithInt:arc4random() % 100]];
        } else if (randomBrightnesses == TTHueRandomBrightnessVaried) {
            [lightState setBrightness:[NSNumber numberWithInt:arc4random() % MAX_BRIGHTNESS]];
        } else if (randomBrightnesses == TTHueRandomBrightnessHigh) {
            [lightState setBrightness:[NSNumber numberWithInt:254]];
        }
        
        if (randomSaturation == TTHueRandomSaturationLow) {
            [lightState setSaturation:[NSNumber numberWithInt:174]];
        } else if (randomSaturation == TTHueRandomSaturationVaried) {
            [lightState setSaturation:[NSNumber numberWithInt:254 - floor(arc4random() % 80)]];
        } else if (randomSaturation == TTHueRandomSaturationHigh) {
            [lightState setSaturation:[NSNumber numberWithInt:254]];
        }
        
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {}];
    }
}

#pragma mark - Hue Init

- (void)activate {
//    NSLog(@" ---> Activating Hue mode: %@", self.phHueSDK);
    
    if (self.phHueSDK) {
        [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
        [self disableLocalHeartbeat];
        [self.phHueSDK stopSDK];
        self.phHueSDK = nil;
    }
    self.phHueSDK = [[PHHueSDK alloc] init];
    [self.phHueSDK startUpSDK];
    [self.phHueSDK enableLogging:NO];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    [notificationManager deregisterObjectForAllNotifications:self];
    
    /***************************************************
     The SDK will send the following notifications in response to events:
     
     - LOCAL_CONNECTION_NOTIFICATION
     This notification will notify that the bridge heartbeat occurred and the bridge resources cache data has been updated
     
     - NO_LOCAL_CONNECTION_NOTIFICATION
     This notification will notify that there is no connection with the bridge
     
     - NO_LOCAL_AUTHENTICATION_NOTIFICATION
     This notification will notify that there is no authentication against the bridge
     *****************************************************/
    
    [notificationManager registerObject:self withSelector:@selector(localConnection)
                        forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection)
                        forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(notAuthenticated)
                        forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];

    // No Hue found, show connection button
    hueState = STATE_CONNECTING;
    [self.delegate changeState:hueState withMode:self showMessage:@"Connecting..."];
    
    [self enableLocalHeartbeat];
}

- (void)deactivate {
//    NSLog(@" ---> DE-Activating Hue mode: %@", self.phHueSDK);

    [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    [self disableLocalHeartbeat];
    [self.phHueSDK stopSDK];
    self.phHueSDK = nil;
}

#pragma mark - HueSDK

/**
 Notification receiver for successful local connection
 */
- (void)localConnection {
    // Check current connection state
    [self checkConnectionState];
}

/**
 Notification receiver for failed local connection
 */
- (void)noLocalConnection {
    // Check current connection state
    [self checkConnectionState];
}

/**
 Notification receiver for failed local authentication
 */
- (void)notAuthenticated {
    /***************************************************
     We are not authenticated so we start the authentication process
     *****************************************************/
    
    /***************************************************
     doAuthentication will start the push linking
     *****************************************************/
    
    // Start local authenticion process
    [self performSelector:@selector(doAuthentication) withObject:nil afterDelay:0.5];
}

/**
 Checks if we are currently connected to the bridge locally and if not, it will show an error when the error is not already shown.
 */
- (void)checkConnectionState {
    if (!self.phHueSDK.localConnected) {
        [self showNoConnectionDialog];
    }
    else {
        // One of the connections is made, remove popups and loading views
        hueState = STATE_CONNECTED;
        [self.delegate changeState:hueState withMode:self showMessage:nil];
        [self ensureScenes];
    }
}

/**
 Shows the first no connection alert
 */
- (void)showNoConnectionDialog {
    NSLog(@"Connection to bridge lost!");
    hueState = STATE_NOT_CONNECTED;
    [self.delegate changeState:hueState withMode:self showMessage:@"Connection to Hue bridge lost"];
}

/**
 Shows the no bridges found alert
 */
- (void)showNoBridgesFoundDialog {
    NSLog(@"Could not find bridge!");
    hueState = STATE_NOT_CONNECTED;
    [self.delegate changeState:hueState withMode:self showMessage:@"Could not find any Hue bridges"];
}

/**
 Shows the not authenticated alert
 */
- (void)showNotAuthenticatedDialog{
    hueState = STATE_NOT_CONNECTED;
    [self.delegate changeState:hueState withMode:self showMessage:@"Pushlink button not pressed within 30 seconds"];
    NSLog(@"Pushlink button not pressed within 30 sec!");
}

#pragma mark - Bridge searching and selection

/**
 Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
 */
- (void)searchForBridgeLocal {
    // Stop heartbeats
    [self disableLocalHeartbeat];
    
    // Start search
    hueState = STATE_CONNECTING;
    [self.delegate changeState:hueState withMode:self showMessage:@"Searching for a Hue bridge..."];
    
    self.bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES andIpAdressSearch:YES];
    [self.bridgeSearch startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
        /***************************************************
         The search is complete, check whether we found a bridge
         *****************************************************/
        
        // Check for results
        if (bridgesFound.count > 0) {
            hueState = STATE_CONNECTING;
            [self.delegate changeState:hueState withMode:self showMessage:@"Found Hue bridge..."];
            NSString *macAddress = [[bridgesFound allKeys] objectAtIndex:0];
            NSString *ipAddress = [bridgesFound objectForKey:macAddress];
            [self.phHueSDK setBridgeToUseWithId:macAddress ipAddress:ipAddress];
            [self enableLocalHeartbeat];
        }
        else {
            /***************************************************
             No bridge was found was found. Tell the user and offer to retry..
             *****************************************************/
            
            // No bridges were found, show this to the user
            [self showNoBridgesFoundDialog];
        }
    }];
    
}

#pragma mark - Heartbeat control

/**
 Starts the local heartbeat with a 10 second interval
 */
- (void)enableLocalHeartbeat {
    /***************************************************
     The heartbeat processing collects data from the bridge
     so now try to see if we have a bridge already connected
     *****************************************************/
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
        // Enable heartbeat with interval of 10 seconds
        [self.phHueSDK enableLocalConnection];
    } else {
        // Automaticly start searching for bridges
        [self searchForBridgeLocal];
    }
}

/**
 Stops the local heartbeat
 */
- (void)disableLocalHeartbeat {
    [self.phHueSDK disableLocalConnection];
}

#pragma mark - Bridge authentication

/**
 Start the local authentication process
 */
- (void)doAuthentication {
    // Disable heartbeats
    [self disableLocalHeartbeat];
    
    // Remove loading sheet view
    //    [self hideCurrentSheetWindow];
    
    /***************************************************
     To be certain that we own this bridge we must manually
     push link it. Here we display the view to do this.
     *****************************************************/
    
    hueState = STATE_PUSHLINK;
    [self.delegate changeState:hueState withMode:self showMessage:nil];
    
    /***************************************************
     Start the push linking process.
     *****************************************************/
    
    // Start pushlinking when the interface is shown
    [self startPushLinking];
}

- (void)startPushLinking {
    /***************************************************
     Set up the notifications for push linkng
     *****************************************************/
    
    // Register for notifications about pushlinking
    PHNotificationManager *phNotificationMgr = [PHNotificationManager defaultManager];
    [phNotificationMgr deregisterObjectForAllNotifications:self];
    
    [phNotificationMgr registerObject:self withSelector:@selector(authenticationSuccess)
                      forNotification:PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(authenticationFailed)
                      forNotification:PUSHLINK_LOCAL_AUTHENTICATION_FAILED_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(noLocalConnection)
                      forNotification:PUSHLINK_NO_LOCAL_CONNECTION_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(noLocalBridge)
                      forNotification:PUSHLINK_NO_LOCAL_BRIDGE_KNOWN_NOTIFICATION];
    [phNotificationMgr registerObject:self withSelector:@selector(buttonNotPressed:)
                      forNotification:PUSHLINK_BUTTON_NOT_PRESSED_NOTIFICATION];
    
    // Call to the hue SDK to start pushlinking process
    /***************************************************
     Call the SDK to start Push linking.
     The notifications sent by the SDK will confirm success
     or failure of push linking
     *****************************************************/
    
    [self.phHueSDK startPushlinkAuthentication];
}

#pragma mark - Notifications for Pushlink

/**
 Notification receiver which is called when the pushlinking was successful
 */
- (void)authenticationSuccess {
    /***************************************************
     The notification PUSHLINK_LOCAL_AUTHENTICATION_SUCCESS_NOTIFICATION
     was received. We have confirmed the bridge.
     De-register for notifications and call
     pushLinkSuccess on the delegate
     *****************************************************/
    // Deregister for all notifications
    [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    
    hueState = STATE_CONNECTED;
    [self.delegate changeState:hueState withMode:self showMessage:nil];
    [self disableLocalHeartbeat];
    
    // Start local heartbeat
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

/**
 Notification receiver which is called when the pushlinking failed because the time limit was reached
 */
- (void)authenticationFailed {
    // Deregister for all notifications
    [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    
    // Inform delegate
    [self pushlinkFailed:[PHError errorWithDomain:SDK_ERROR_DOMAIN
                                                      code:PUSHLINK_TIME_LIMIT_REACHED
                                                  userInfo:[NSDictionary dictionaryWithObject:@"Authentication failed: time limit reached." forKey:NSLocalizedDescriptionKey]]];
}

/**
 Notification receiver which is called when the pushlinking failed because we do not know the address of the local bridge
 */
- (void)noLocalBridge {
    // Deregister for all notifications
    [[PHNotificationManager defaultManager] deregisterObjectForAllNotifications:self];
    
    // Inform delegate
    [self pushlinkFailed:[PHError errorWithDomain:SDK_ERROR_DOMAIN code:PUSHLINK_NO_LOCAL_BRIDGE userInfo:[NSDictionary dictionaryWithObject:@"Authentication failed: No local bridge found." forKey:NSLocalizedDescriptionKey]]];
}

/**
 This method is called when the pushlinking is still ongoing but no button was pressed yet.
 @param notification The notification which contains the pushlinking percentage which has passed.
 */
- (void)buttonNotPressed:(NSNotification *)notification {
    // Update status bar with percentage from notification
    NSDictionary *dict = notification.userInfo;
    NSNumber *progressPercentage = [dict objectForKey:@"progressPercentage"];
    
    hueState = STATE_PUSHLINK;
    [self.delegate changeState:hueState withMode:self showMessage:progressPercentage];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was not successfull
 */
- (void)pushlinkFailed:(PHError *)error {
    // Check which error occured
    if (error.code == PUSHLINK_NO_CONNECTION) {
        // No local connection to bridge
        [self noLocalConnection];
        
        // Start local heartbeat (to see when connection comes back)
        [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
    }
    else {
        // Bridge button not pressed in time
        [self showNotAuthenticatedDialog];
    }
}

- (void)ensureScenes {
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];

    // Collect scene ids to check against
    NSDictionary *scenes = cache.scenes;
    NSMutableArray *foundScenes = [[NSMutableArray alloc] init];
    for (PHScene *scene in scenes.allValues) {
        [foundScenes addObject:scene.identifier];
    }

    // Scene: All Lights Off
    if (![foundScenes containsObject:@"TT-all-off"]) {
        PHScene *scene = [[PHScene alloc] init];
        scene.name = @"All Lights Off";
        scene.identifier = @"TT-all-off";
        scene.lightIdentifiers = cache.lights.allKeys;
        [bridgeSendAPI saveSceneWithCurrentLightStates:scene completionHandler:^(NSArray *errors) {
            NSLog(@"Hue:SceneOff scene: %@", errors);
            for (PHLight *light in cache.lights.allValues) {
                PHLightState *lightState = light.lightState;
                lightState.on = [NSNumber numberWithBool:NO];
                lightState.alert = 0;
                [bridgeSendAPI saveLightState:lightState forLightIdentifier:light.identifier inSceneWithIdentifier:scene.identifier completionHandler:^(NSArray *errors) {
                    NSLog(@"Hue:SceneOff light: %@", errors);
                }];
            }
        }];
    }
}
@end
