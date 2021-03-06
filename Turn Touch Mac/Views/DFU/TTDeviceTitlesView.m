//
//  TTDFUView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/4/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTDeviceTitlesView.h"
#import "TTDeviceTitleView.h"
#import "SSZipArchive.h"
#import "UnzipFirmware.h"
#import "DFUHelper.h"
#include "DFUHelper.h"

@interface TTDeviceTitlesView ()

/*!
 * This property is set when the device has been selected on the Scanner View Controller.
 */
@property (strong, nonatomic) CBPeripheral *selectedPeripheral;
@property (strong, nonatomic) DFUOperations *dfuOperations;
@property (strong, nonatomic) DFUHelper *dfuHelper;

@property BOOL isTransferring;
@property BOOL isTransfered;
@property BOOL isTransferCancelled;
@property BOOL isConnected;
@property BOOL isErrorKnown;
@property BOOL isNotifying;

@property (nonatomic, strong) TTBorder *border;
@property (nonatomic, strong) TTDevice *currentDevice;

@end

@implementation TTDeviceTitlesView

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;

        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        [self setOrientation:NSUserInterfaceLayoutOrientationVertical];
        [self setAlignment:NSLayoutAttributeCenterX];
        [self setSpacing:0];
        [self setWantsLayer:YES];
        [self setHuggingPriority:NSLayoutPriorityDefaultHigh
                  forOrientation:NSLayoutConstraintOrientationVertical];
        
        [self registerAsObserver];

        // This is set to 10 elsewhere. Why make it user configurable?
//        PACKETS_NOTIFICATION_INTERVAL = [[[NSUserDefaults standardUserDefaults] valueForKey:@"dfu_number_of_packets"] intValue];
//        NSLog(@"PACKETS_NOTIFICATION_INTERVAL %d",PACKETS_NOTIFICATION_INTERVAL);
        self.dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
        self.dfuHelper = [[DFUHelper alloc] initWithData:self.dfuOperations];
        
        self.border = [[TTBorder alloc] init];
        
        [self assembleDeviceTitles];
    }

    return self;
}

- (void)registerAsObserver {
    [self.appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"nicknamedConnectedCount"
                                      options:0 context:nil];
    [self.appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"pairedDevicesCount"
                                      options:0 context:nil];
    [self.appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"unpairedDevicesCount"
                                      options:0 context:nil];
    [self.appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"unpairedDevicesConnected"
                                      options:0 context:nil];
    [self.appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"bluetoothState"
                                      options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(nicknamedConnectedCount))]) {
        [self assembleDeviceTitles];
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(pairedDevicesCount))]) {
        [self assembleDeviceTitles];
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(unpairedDevicesCount))]) {
        [self assembleDeviceTitles];
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(unpairedDevicesConnected))]) {
        [self assembleDeviceTitles];
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(bluetoothState))]) {
        [self assembleDeviceTitles];
        [self setNeedsDisplay:YES];
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"nicknamedConnectedCount"];
    [self removeObserver:self forKeyPath:@"pairedDevicesCount"];
    [self removeObserver:self forKeyPath:@"unpairedDevicesCount"];
    [self removeObserver:self forKeyPath:@"unpairedDevicesConnected"];
    [self removeObserver:self forKeyPath:@"bluetoothState"];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [self drawBackground];
}

- (void)drawBackground {
//    [NSColorFromRGB(0xFFFFFF) set];
//    NSRectFill(self.bounds);
    NSGradient* aGradient = [[NSGradient alloc]
                             initWithStartingColor:[NSColor whiteColor]
                             endingColor:NSColorFromRGB(0xE7E7E7)];
    [aGradient drawInRect:self.bounds angle:-90];
//    [aGradient drawInBezierPath:path angle:-90];
    
    
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(NSMinX([self bounds]), NSMinY([self bounds]))];
    [line lineToPoint:NSMakePoint(NSMaxX([self bounds]), NSMinY([self bounds]))];
    [line moveToPoint:NSMakePoint(NSMinX([self bounds]), NSMaxY([self bounds]))];
    [line lineToPoint:NSMakePoint(NSMaxX([self bounds]), NSMaxY([self bounds]))];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xC2CBCE) set];
    [line stroke];
}

- (void)assembleDeviceTitles {
    NSMutableArray *dfuDeviceViews = [NSMutableArray array];
    NSArray *devices = self.appDelegate.bluetoothMonitor.foundDevices.devices;
    
    [self removeConstraints:self.constraints];
    for (NSView *subview in [self viewsInGravity:NSStackViewGravityTop]) {
        [self removeView:subview];
    }
    
    for (TTDevice *device in devices) {
        if (![device isPaired] && ![device isPairing]) continue;
        TTDeviceTitleView *deviceView = [[TTDeviceTitleView alloc] initWithDevice:device];
        [dfuDeviceViews addObject:deviceView];
        [self addView:deviceView inGravity:NSStackViewGravityTop];
    }
    
//    [dfuDeviceViews addObject:self.border];
//    [self setViews:dfuDeviceViews inGravity:NSStackViewGravityTop];
    
    for (NSView *deviceView in self.views) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:deviceView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:0
                                                        multiplier:1.0
                                                          constant:deviceView == self.border ? 0.5f : 40]];
    }
}


#pragma mark Device Selection Delegate

-(void)centralManager:(CBCentralManager *)manager didPeripheralSelected:(CBPeripheral *)peripheral {
    self.selectedPeripheral = peripheral;
    [self.dfuOperations setCentralManager:manager];
    //    deviceName.text = peripheral.name;
    self.dfuOperations.bleOperations.bluetoothPeripheral = peripheral;
    [self.dfuOperations.bleOperations.bluetoothPeripheral setDelegate:self.dfuOperations.bleOperations];
    [self.dfuOperations.bleOperations centralManager:manager didConnectPeripheral:peripheral];
}

#pragma mark - DFU

-(void)performDFU:(TTDevice *)device {
    self.currentDevice = device;
    [self prepareFirmware];
    
    for (NSView *deviceView in self.views) {
        if (deviceView == self.border) continue;
        if (((TTDeviceTitleView *)deviceView).device != device) {
            [(TTDeviceTitleView *)deviceView disableUpgrade];
        }
    }

    [self centralManager:self.appDelegate.bluetoothMonitor.manager didPeripheralSelected:device.peripheral];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self disableOtherButtons];
        //        uploadStatus.hidden = NO;
        //        progress.hidden = NO;
        //        progressLabel.hidden = NO;
        //        uploadButton.enabled = NO;
    });
}

- (void)prepareFirmware {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger latestVersion = [[prefs objectForKey:@"TT:firmware:version"] integerValue];

    NSString *filePath = [NSString stringWithFormat:@"%@/firmwares/nrf51_%02ld.zip",
                          [[NSBundle mainBundle] resourcePath], (long)latestVersion];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    self.dfuHelper.selectedFileURL = fileUrl;
    [self.dfuHelper setFirmwareType:FIRMWARE_TYPE_APPLICATION];
    
    NSString *selectedFileName = [[fileUrl path] lastPathComponent];
    NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
    self.dfuHelper.selectedFileSize = fileData.length;
    NSLog(@" ---> Upgrading with %@", selectedFileName);

    self.dfuHelper.isSelectedFileZipped = YES;
    self.dfuHelper.isManifestExist = NO;
    [self.dfuHelper unzipFiles:self.dfuHelper.selectedFileURL];
}

- (void) clearUI {
    self.selectedPeripheral = nil;
}

-(void)disableOtherButtons {
    //    selectFileButton.enabled = NO;
    //    selectFileTypeButton.enabled = NO;
    //    connectButton.enabled = NO;
}

-(void)enableOtherButtons {
    //    selectFileButton.enabled = YES;
    //    selectFileTypeButton.enabled = YES;
    //    connectButton.enabled = YES;
}

-(void)enableUploadButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.dfuHelper.selectedFileSize > 0) {
            if ([self.dfuHelper isValidFileSelected]) {
                NSLog(@" valid file selected");
            } else {
                NSLog(@"Valid file not available in zip file");
                return;
            }
        }
        if (self.dfuHelper.isDfuVersionExist) {
            if (self.selectedPeripheral && self.dfuHelper.selectedFileSize > 0 && self.isConnected && self.dfuHelper.dfuVersion >= 1) {
                if ([self.dfuHelper isInitPacketFileExist]) {
                    //                    uploadButton.enabled = YES;
                }
                else {
                    //                    [Utility showAlert:[self.dfuHelper getInitPacketFileValidationMessage]];
                }
            }
            else {
                NSLog(@"cant enable Upload button");
            }
        }
        else {
            if (self.selectedPeripheral && self.dfuHelper.selectedFileSize > 0 && self.isConnected) {
                //                uploadButton.enabled = YES;
            }
            else {
                NSLog(@"cant enable Upload button");
            }
        }
        
    });
}

#pragma mark DFUOperations delegate methods

-(void)onDeviceConnected:(CBPeripheral *)peripheral {
    NSLog(@"onDeviceConnected %@",peripheral.name);
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = NO;
    [self enableUploadButton];
}

-(void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral {
    NSLog(@"onDeviceConnectedWithVersion %@",peripheral.name);
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = YES;
    [self enableUploadButton];
}

-(void)onDeviceDisconnected:(CBPeripheral *)peripheral {
    NSLog(@"device disconnected %@",peripheral.name);
    self.isTransferring = NO;
    self.isConnected = NO;
    
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
//        if (self.dfuHelper.dfuVersion >= 2) {
//            [self clearUI];
//            
//            self.isTransferCancelled = NO;
//            self.isTransfered = NO;
//            self.isErrorKnown = NO;
//            
//            [self returnBluetoothManager];
//        } else {
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self.dfuOperations connectDevice:peripheral];
            });
            
//        }
    });
}

-(void)onReadDFUVersion:(int)version {
    self.dfuHelper.dfuVersion = version;
    NSLog(@"DFU Version: %d",self.dfuHelper.dfuVersion);
    if (self.dfuHelper.dfuVersion >= 1) {
//        [self.dfuOperations setAppToBootloaderMode];
    }
    [self enableUploadButton];
}

- (void)onNotifyBeginForControlPoint {
    NSLog(@"Notifying for control point, begin... %d", self.isNotifying);
    if (self.isNotifying) {
        self.isNotifying = NO;
        [self.dfuHelper checkAndPerformDFU];
    } else {
        [self.dfuOperations setAppToBootloaderMode];
        self.isNotifying = YES;
    }
}

-(void)onDFUStarted {
    NSLog(@"onDFUStarted");
    self.isTransferring = YES;
    TTDeviceTitleView *dfuDeviceView = [self deviceInDFU];
    dispatch_async(dispatch_get_main_queue(), ^{
        [dfuDeviceView startIndeterminateProgress];
        //        uploadButton.enabled = YES;
        //        [uploadButton setTitle:@"Cancel" forState:UIControlStateNormal];
        //        NSString *uploadStatusMessage = [self.dfuHelper getUploadStatusMessage];
        //        if ([Utility isApplicationStateInactiveORBackground]) {
        //            [Utility showBackgroundNotification:uploadStatusMessage];
        //        } else {
        //            uploadStatus.text = uploadStatusMessage;
        //        }
    });
}

-(void)onDFUCancelled {
    NSLog(@"onDFUCancelled");
    self.isTransferring = NO;
    self.isTransferCancelled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self enableOtherButtons];
        [self returnBluetoothManager];
    });
}

-(void)onSoftDeviceUploadStarted {
    NSLog(@"onSoftDeviceUploadStarted");
}

-(void)onSoftDeviceUploadCompleted {
    NSLog(@"onSoftDeviceUploadCompleted");
}

-(void)onBootloaderUploadStarted {
    NSLog(@"onBootloaderUploadStarted");
    dispatch_async(dispatch_get_main_queue(), ^{
        //        if ([Utility isApplicationStateInactiveORBackground]) {
        //            [Utility showBackgroundNotification:@"uploading bootloader ..."];
        //        }
        //        else {
        //            uploadStatus.text = @"uploading bootloader ...";
        //        }
    });
    
}

-(void)onBootloaderUploadCompleted {
    NSLog(@"onBootloaderUploadCompleted");
}

-(void)onTransferPercentage:(int)percentage {
    NSLog(@"onTransferPercentage %d",percentage);
    
    TTDeviceTitleView *dfuDeviceView = [self deviceInDFU];
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        [dfuDeviceView setProgressPercentage:(float)percentage];
    });
}

- (TTDeviceTitleView *)deviceInDFU {
    for (NSView *deviceView in self.views) {
        if (deviceView == self.border) continue;
        if (((TTDeviceTitleView *)deviceView).device.inDFU) return (TTDeviceTitleView *)deviceView;
    }
    
    return nil;
}

-(void)onSuccessfulFileTranferred {
    NSLog(@"OnSuccessfulFileTransferred");
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isTransferring = NO;
        self.isTransfered = YES;
        self.isNotifying = NO;

        [self returnBluetoothManager];
        //        NSString* message = [NSString stringWithFormat:@"%lu bytes transfered in %lu seconds", (unsigned long)self.dfuOperations.binFileSize, (unsigned long)self.dfuOperations.uploadTimeInSeconds];
        //        if ([Utility isApplicationStateInactiveORBackground]) {
        //            [Utility showBackgroundNotification:message];
        //        }
        //        else {
        //            [Utility showAlert:message];
        //        }
        
    });
}

-(void)onError:(NSString *)errorMessage {
    NSLog(@"OnError %@",errorMessage);
    self.isErrorKnown = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        //        [Utility showAlert:errorMessage];
        [self clearUI];
    });
}

- (void)returnBluetoothManager {
    for (NSView *deviceView in self.views) {
        if (deviceView == self.border) continue;
        [(TTDeviceTitleView *)deviceView enableUpgrade];
    }

    NSLog(@" ---> Returning Bluetooth Monitor");
    [self.appDelegate.bluetoothMonitor.manager setDelegate:self.appDelegate.bluetoothMonitor];
}

@end
