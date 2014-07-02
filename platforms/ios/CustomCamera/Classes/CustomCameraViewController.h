//
//  CustomCameraViewController.h
//  CustomCamera
//
//  Created by Chris van Es on 24/02/2014.
//
//

#import <UIKit/UIKit.h>

@interface CustomCameraViewController : UIViewController

- (id)initWithFrame:(NSString*)frame callback:(void(^)(UIImage*))callback;

@end
