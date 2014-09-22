//
//  UIImage+fixOrientation.h
//  SnapViva
//
//  Created by sorpa'as plat on 3/8/14.
//
//

#import <Foundation/Foundation.h>

@interface UIImage (fixOrientation)

- (UIImage*)fixOrientation;
+ (UIImage*)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize;

@end
