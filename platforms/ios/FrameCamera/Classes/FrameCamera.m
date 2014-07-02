//
//  FrameCamera.m
//  FrameCamera
//
//  Created by sorpa'as plat on 6/6/14.
//
//

#import "FrameCamera.h"

@implementation FrameCamera

// Cordova command method
- (void) openCamera:(CDVInvokedUrlCommand *)command {
	// Set the hasPendingOperation field to prevent the webview from crashing
    self.hasPendingOperation = YES;
	// Save the CDVInvokedUrlCommand as a property.  We will need it later.
    self.latestCommand = command;
	// Make the overlay view controller.
	// self.overlay = [[DOODCameraViewController alloc] initWithNibName:@"DOODCameraViewController" bundle:nil];
	// self.overlay.plugin = self;
    
	// Display the view.  This will "slide up" a modal view from the bottom of the screen.
	// [self.viewController presentViewController:self.overlay.picker animated:YES completion:nil];
}

// Method called by the overlay when the image is ready to be sent back to the web view
-(void) capturedImageWithPath:(NSString*)imagePath {
	[self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:imagePath] callbackId:self.latestCommand.callbackId];
    
	// Unset the self.hasPendingOperation property
	self.hasPendingOperation = NO;
    
    // Hide the picker view
    [self.viewController dismissModalViewControllerAnimated:YES];
}

@end
