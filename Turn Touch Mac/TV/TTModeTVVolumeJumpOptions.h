//
//  TTModeTVVolumeJumpOptions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/19/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

@interface TTModeTVVolumeJumpOptions : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSTextField *percentageLabel;
@property (nonatomic) IBOutlet NSSlider *volumeSlider;

- (IBAction)slideVolume:(id)sender;

@end
