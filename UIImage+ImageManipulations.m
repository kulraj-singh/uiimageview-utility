//
//  UIImage+ImageManipulations.m
//
//  Created by Kulraj on 04/09/14.
//

#import "UIImage+ImageManipulations.h"

@implementation UIImage (ImageManipulations)

- (UIImage *)fixrotation
{
  UIImage* image = self;
  if (image.imageOrientation == UIImageOrientationUp) return image;
  CGAffineTransform transform = CGAffineTransformIdentity;
  
  switch (image.imageOrientation) {
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
      transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
      transform = CGAffineTransformRotate(transform, M_PI);
      break;
      
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
      transform = CGAffineTransformTranslate(transform, image.size.width, 0);
      transform = CGAffineTransformRotate(transform, M_PI_2);
      break;
      
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      transform = CGAffineTransformTranslate(transform, 0, image.size.height);
      transform = CGAffineTransformRotate(transform, -M_PI_2);
      break;
    case UIImageOrientationUp:
    case UIImageOrientationUpMirrored:
      break;
  }
  
  switch (image.imageOrientation) {
    case UIImageOrientationUpMirrored:
    case UIImageOrientationDownMirrored:
      transform = CGAffineTransformTranslate(transform, image.size.width, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
      
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRightMirrored:
      transform = CGAffineTransformTranslate(transform, image.size.height, 0);
      transform = CGAffineTransformScale(transform, -1, 1);
      break;
    case UIImageOrientationUp:
    case UIImageOrientationDown:
    case UIImageOrientationLeft:
    case UIImageOrientationRight:
      break;
  }
  
  // Now we draw the underlying CGImage into a new context, applying the transform
  // calculated above.
  CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                           CGImageGetBitsPerComponent(image.CGImage), 0,
                                           CGImageGetColorSpace(image.CGImage),
                                           CGImageGetBitmapInfo(image.CGImage));
  CGContextConcatCTM(ctx, transform);
  switch (image.imageOrientation) {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
      // Grr...
      CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
      break;
      
    default:
      CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
      break;
  }
  
  // And now we just create a new UIImage from the drawing context
  CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
  UIImage *img = [UIImage imageWithCGImage:cgimg];
  CGContextRelease(ctx);
  CGImageRelease(cgimg);
  return img;
  
}

-(UIImage*)focusImageTopAndResizeTo:(CGSize)newSize
{
  UIGraphicsBeginImageContext(newSize);
  UIImage* newImage;
  
  [[UIColor whiteColor] setFill];
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextFillRect(context, CGRectMake(0, 0, newSize.width, newSize.height));
  
  CGSize oldSize = self.size;
  float scaleFactor = newSize.width/oldSize.width;
  // add 1 for taking cieling value
  int newHeight = oldSize.height * scaleFactor + 1;
  if (newHeight < newSize.height) {
    scaleFactor = newSize.height/oldSize.height;
    int newWidth = oldSize.width * scaleFactor;
    //absolute value will cover condition for scale factor < 1 and scale factor > 1
    int originX = -abs((newSize.width - newWidth)/2);
    [self drawInRect:CGRectMake(originX, 0, newWidth, newSize.height)];
  } else {
    [self drawInRect:CGRectMake(0,0,newSize.width,oldSize.height * scaleFactor)];
  }
  newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

-(void)getBoundsOfFace
{
  CIImage* myImage = [CIImage imageWithCGImage:self.CGImage];
  CIContext *context = [CIContext contextWithOptions:nil];
  NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
  CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                            context:context options:opts];
  
  NSArray *features = [detector featuresInImage:myImage options:opts];
  for (CIFeature* faceObject in features) {
    CGRect faceBounds = faceObject.bounds;
    faceBounds.origin.x += 1;
  }
}

//we downsize if image size is > 100 kb
-(UIImage*)getDownsizedImage
{
  float maxBytes = 10000;
  NSData *imgData = UIImageJPEGRepresentation(self, 1);
  //length returns the size of image in bytes
  float imageSizeInBytes = [imgData length];
  if (imageSizeInBytes > maxBytes)
  {
    //compress
    float compressionFactor = maxBytes/imageSizeInBytes;
    NSData* compressedImageData = UIImageJPEGRepresentation(self, compressionFactor);
    UIImage *newImage = [UIImage imageWithData:compressedImageData];
    return newImage;
  }
  return self;
}

-(UIImage*)getSquareImage
{
  UIImage *originalImage = [self fixrotation];
  //we need to scale the screen shot to size of the original image
  CGSize originalImageSize = originalImage.size;
  float newWidth, newHeight, x = 0, y = 0;
  //create square image with dimensions = lesser dimension
  if (originalImageSize.width > originalImageSize.height)
  {
    newHeight = originalImageSize.height;
    newWidth = newHeight;
    //origin to clip the extra portion
    x = (originalImageSize.width - newWidth)/2;
    
  }
  else
  {
    newWidth = originalImageSize.width;
    newHeight = newWidth;
    y = (originalImageSize.height - newHeight)/2;
  }
  CGRect clippedRect = CGRectMake(x, y, newWidth, newHeight);
  CGImageRef imageRef = CGImageCreateWithImageInRect([originalImage CGImage], clippedRect);
  UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  return newImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color boundingRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)imagewithScreenShotOfView:(UIView*)view
{
    //take screenshot of image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData * data = UIImagePNGRepresentation(image);
    
    UIImage *screenshot = [UIImage imageWithData:data];
    return screenshot;
}

+ (UIImage*)polygonWithPoints:(NSArray*)points color:(UIColor*)color size:(CGSize)size
{
    if (points.count < 2) {
        return nil;
    }
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context= UIGraphicsGetCurrentContext();
    
    int length = (int)points.count;
    
    CGPoint firstPoint = [points[0] CGPointValue] ;
    CGContextMoveToPoint(context, firstPoint.x, firstPoint.y);
    
    for (int i = 1; i < length; i++) {
        CGPoint point = [points[i] CGPointValue];
        CGContextAddLineToPoint(context, point.x, point.y);
    }
    
    CGContextAddLineToPoint(context, firstPoint.x, firstPoint.y);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

@end
