//
//  KeyboardVisibilityHandler.m
//  Runner
//
//  Created by admin on 07/11/2018.
//  Copyright © 2018 The Chromium Authors. All rights reserved.
//

#import "FlutterKeyboardVisibilityPlugin.h"

@interface FlutterKeyboardVisibilityPlugin() <FlutterStreamHandler>

@property (copy, nonatomic) FlutterEventSink flutterEventSink;
@property (assign, nonatomic) BOOL flutterEventListening;
@property (assign, nonatomic) BOOL isVisible;

@end


@implementation FlutterKeyboardVisibilityPlugin

+(void) registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterEventChannel *stream = [FlutterEventChannel eventChannelWithName:@"flutter_keyboard_visibility" binaryMessenger:[registrar messenger]];

    FlutterKeyboardVisibilityPlugin *instance = [[FlutterKeyboardVisibilityPlugin alloc] init];
    [stream setStreamHandler:instance];
}

-(instancetype)init {
    self = [super init];

    self.isVisible = NO;

    // set up the notifier
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didShow) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(willShow) name:UIKeyboardWillShowNotification object:nil];
	[center addObserver:self selector:@selector(didHide) name:UIKeyboardWillHideNotification object:nil];

    return self;
}

- (void)didShow
{
    // if state changed and we have a subscriber, let him know
    if (!self.isVisible) {
        self.isVisible = YES;
        if (self.flutterEventListening) {
            self.flutterEventSink([NSNumber numberWithInt:1]);
        }
    }
}

- (void)willShow
{
    // if state changed and we have a subscriber, let him know
    if (!self.isVisible) {
        self.isVisible = YES;
        if (self.flutterEventListening) {
            self.flutterEventSink([NSNumber numberWithInt:1]);
        }
    }
}

- (void)didHide
{
    // if state changed and we have a subscriber, let him know
    if (self.isVisible) {
	    self.isVisible = NO;
		if (self.flutterEventListening) {
			self.flutterEventSink([NSNumber numberWithInt:0]);
		}
    }
}

-(FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    self.flutterEventSink = events;
    self.flutterEventListening = YES;

    // if keyboard is visible at startup, let our subscriber know
    if (self.isVisible) {
        self.flutterEventSink([NSNumber numberWithInt:1]);
    }

    return nil;
}

-(FlutterError*)onCancelWithArguments:(id)arguments {
    self.flutterEventListening = NO;
    return nil;
}

@end
