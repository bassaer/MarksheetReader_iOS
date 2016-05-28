//
//  Detector.m
//  MarksheetReader
//
//  Created by Nakayama on 2016/05/27.
//  Copyright © 2016年 Nakayama. All rights reserved.
//

#import "MarksheetReader-Bridging-Header.h"
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/ios.h>
//#import <opencv2/highgui/highgui.hpp>

@interface Detector()
{
    cv::CascadeClassifier cascade;
}
- (cv::Mat)convertUIImageToMat:(UIImage *)image;
- (cv::Mat)getBinaryImage:(cv::Mat) mat;
@end

@implementation Detector: NSObject

- (id)init {
    self = [super init];
    
    //分類器の読み込み
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource: @"haarcascade_frontalface_alt" ofType:@"xml"];
    std::string cascadeName = (char *)[path UTF8String];
    
    if(!cascade.load(cascadeName)) {
        return nil;
    }
    
    return self;
}



- (UIImage *)recognizeFace:(UIImage *)image {
    cv::Mat gray_img;
    cv::Mat adaptive_img;
    cv::Mat mat = [self convertUIImageToMat: image];
    cv::cvtColor(mat, gray_img, CV_BGR2GRAY);
    cv::adaptiveThreshold(gray_img, adaptive_img, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 7, 8);
    
    
    
    /*
    
    //顔検出
    std::vector<cv::Rect> faces;
    cascade.detectMultiScale(mat, faces, 1.1, 2, CV_HAAR_SCALE_IMAGE, cv::Size(30,30));
    
    //顔の位置に丸を置く
    std::vector<cv::Rect>::const_iterator r = faces.begin();
    for(; r != faces.end(); ++r) {
        cv::Point center;
        int radius;
        center.x = cv::saturate_cast<int>((r->x + r->width*0.5));
        center.y = cv::saturate_cast<int>((r->y + r->height*0.5));
        radius = cv::saturate_cast<int>((r->width + r->height) / 2);
        cv::circle(mat, center, radius, cv::Scalar(80,80,255), 3, 8, 0);
    }
     
    UIImage *resultImage = MatToUIImage(mat);
     
    */
    
    UIImage *resultImage = MatToUIImage(adaptive_img);
    
    return resultImage;
}

- (cv::Mat)convertUIImageToMat:(UIImage *)image {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    cv::Mat mat(rows, cols, CV_8UC4);
    CGContextRef contextRef = CGBitmapContextCreate(
                                                    mat.data,
                                                    cols,
                                                    rows,
                                                    8,
                                                    mat.step[0],
                                                    colorSpace,
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return mat;
}

- (cv::Mat)getBinaryImage:(cv::Mat) mat {
    cv::cvtColor(mat, mat, CV_BGR2GRAY);
    cv::adaptiveThreshold(mat, mat, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 7, 8);
    
    return mat;
}

- (UIImage *)matchImage:(UIImage *)cameraImage templateImage:(UIImage *)templateImage {
    
    cv::Mat camera = [self getBinaryImage:[self convertUIImageToMat:cameraImage]];
    cv::Mat tmpImg = [self getBinaryImage:[self convertUIImageToMat:templateImage]];
    
    cv::Mat resultImg;
    
    cv::matchTemplate(camera, tmpImg, resultImg, cv::TM_CCORR);
    
    double min_val, max_val;
    cv::Point min_loc, max_loc;
    cv::minMaxLoc(resultImg, &min_val, &max_val, &min_loc, &max_loc);
    
    cv::rectangle(camera, max_loc, cv::Point(max_loc.x + tmpImg.cols, max_loc.y + tmpImg.rows), CV_RGB(0,255,0), 2);
    
    return MatToUIImage(camera);
}

@end
