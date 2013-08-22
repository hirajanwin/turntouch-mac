//
//  TTPanelController.h
//  Turn Touch App
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTBackgroundView.h"
#import "TTStatusItemView.h"

@class TTPanelController;

@protocol TTPanelControllerDelegate <NSObject>

@optional

- (TTStatusItemView *)statusItemViewForPanelController:(TTPanelController *)controller;

@end

#pragma mark -

@interface TTPanelController : NSWindowController <NSWindowDelegate> {
    BOOL _hasActivePanel;
    __unsafe_unretained TTBackgroundView *_backgroundView;
    __unsafe_unretained id<TTPanelControllerDelegate> _delegate;
    __unsafe_unretained NSSearchField *_searchField;
    __unsafe_unretained NSTextField *_textField;
}

@property (nonatomic, unsafe_unretained) IBOutlet TTBackgroundView *backgroundView;
@property (nonatomic, unsafe_unretained) IBOutlet NSSearchField *searchField;
@property (nonatomic, unsafe_unretained) IBOutlet NSTextField *textField;

@property (nonatomic) BOOL hasActivePanel;
@property (nonatomic, unsafe_unretained, readonly) id<TTPanelControllerDelegate> delegate;

- (id)initWithDelegate:(id<TTPanelControllerDelegate>)delegate;

- (void)openPanel;
- (void)closePanel;

@end