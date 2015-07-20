//
//  UIImage+ImageManipulations.h
//
//  Created by Kulraj on 04/09/14.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageManipulations)

- (UIImage*)fixrotation;

//resizing is important for compression. pass the size of your imageview where you want to display the image
- (UIImage*)focusImageTopAndResizeTo:(CGSize)newSize;

- (UIImage*)getDownsizedImage;

- (void)getBoundsOfFace;

- (UIImage*)getSquareImage;

//create a solid color rectangular image
+ (UIImage*)imageWithColor:(UIColor *)color boundingRect:(CGRect)rect;

+ (UIImage*)imagewithScreenShotOfView:(UIView*)view;

//create a solid color image in the shape of a polygon. pass the vertices of the polygon
+ (UIImage*)polygonWithPoints:(NSArray*)points color:(UIColor*)color size:(CGSize)size;

@end
