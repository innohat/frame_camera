//
//  FrameCamera.h
//  FrameCamera
//
//  Created by sorpa'as plat on 6/6/14.
//
//

#import <Cordova/CDV.h>
#import "DOODCameraViewController.h"

@interface FrameCamera : CDVPlugin

// Cordova command method
-(void) openCamera:(CDVInvokedUrlCommand*)command;

// Create and override some properties and methods (these will be explained later)
-(void) capturedImageWithPath:(NSString*)imagePath;
// @property (strong, nonatomic) DOODCameraViewController* overlay;
@property (strong, nonatomic) CDVInvokedUrlCommand* latestCommand;
@property (readwrite, assign) BOOL hasPendingOperation;

@end
