//
//  Detector.m
//  MarksheetReader
//
//  Created by Nakayama on 2016/05/27.
//  Copyright © 2016年 Nakayama. All rights reserved.
//

#import "MarksheetReader-Bridging-Header.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
//#import <opencv2/highgui/ios.h>
//#import <opencv2/highgui/highgui.hpp>

@interface Detector()
{
    cv::CascadeClassifier cascade;
}
- (cv::Mat)convertUIImageToMat:(UIImage *)image;
- (cv::Mat)getBinaryImage:(cv::Mat) mat;
- (cv::Mat)changeOrientation:(cv::Mat) mat;
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
    cv::threshold(mat, mat, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
    //cv::adaptiveThreshold(mat, mat, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 7, 8);
    
    return mat;
}

- (cv::Mat)changeOrientation:(cv::Mat) mat {
    
    cv::Mat result(mat.rows,mat.cols, CV_8UC4);
    cv::transpose(mat, result);
    
    return result;
}

- (UIImage *)matchImage:(UIImage *)cameraImage templateImage:(UIImage *)templateImage {
    
    
    
    cv::Mat camera = [self getBinaryImage:[self convertUIImageToMat:cameraImage]];
    cv::Mat tmpImg = [self getBinaryImage:[self convertUIImageToMat:templateImage]];
    
    cv::Mat resultImg;
    
    //画像を左へ９０度回転
    camera = [self changeOrientation:camera];
    
    
    cv::matchTemplate(camera, tmpImg, resultImg, cv::TM_CCORR_NORMED);
    
    double min_val, max_val;
    cv::Point min_loc, max_loc;
    cv::minMaxLoc(resultImg, &min_val, &max_val, &min_loc, &max_loc);
//    cv::threshold(resultImg, resultImg, 0.7, 1.0, cv::THRESH_TOZERO);
    resultImg = [self convertUIImageToMat:cameraImage];
    resultImg = [self changeOrientation:resultImg];
//    for(int i=0;i<resultImg.rows;i++){
//        for(int j=0;j<resultImg.cols;j++){
//            if(resultImg.at<float>(i,j) > 0){
//                cv::rectangle(resultImg , cv::Point(j,i), cv::Point(j + tmpImg.cols, i + tmpImg.rows), CV_RGB(0,255,0), 2);
//            }
//        }
//    }
    //cv::rectangle(resultImg , max_loc, cv::Point(max_loc.x + tmpImg.cols, max_loc.y + tmpImg.rows), CV_RGB(0,255,0), 2);
    cv::rectangle(resultImg , max_loc, cv::Point(max_loc.x + tmpImg.cols, max_loc.y + tmpImg.rows), CV_RGB(0,255,0), 3);
    
    resultImg = [self changeOrientation:resultImg];
    
    return MatToUIImage(resultImg);
    
}

- (UIImage *)doMachingShape:(UIImage *)cameraImage templateImage:(UIImage *)templateImage {
    double threshold = 0.001;
    cv::Mat camera = [self getBinaryImage:[self convertUIImageToMat:cameraImage]];
    cv::Mat tmpImg = [self getBinaryImage:[self convertUIImageToMat:templateImage]];
    
    cv::morphologyEx(camera, camera, cv::MORPH_OPEN,cv::Mat(), cv::Point(-1, -1), 2);
    cv::morphologyEx(tmpImg, tmpImg, cv::MORPH_OPEN,cv::Mat(), cv::Point(-1, -1), 2);
    
    cv::Mat labels;
    cv::Mat stats;
    cv::Mat centroids;
    
    int nlanels = cv::connectedComponentsWithStats(camera, labels, stats, centroids);
    
    cv::Mat roiImg;
    cv::cvtColor(camera, roiImg, CV_GRAY2BGR);
    std::vector<cv::Rect> roiRects;
    
    for(int i=1; i<nlanels;i++){
        int *param = stats.ptr<int>(i);
        int x = param[cv::ConnectedComponentsTypes::CC_STAT_LEFT];
        int y = param[cv::ConnectedComponentsTypes::CC_STAT_TOP];
        int height = param[cv::ConnectedComponentsTypes::CC_STAT_HEIGHT];
        int width = param[cv::ConnectedComponentsTypes::CC_STAT_WIDTH];
        roiRects.push_back(cv::Rect(x, y, width, height));
        cv::rectangle(roiImg, roiRects.at(i-1), cv::Scalar(0, 255, 0), 2);
    }
    
    cv::Mat dst = [self convertUIImageToMat:cameraImage];
    double min = 1;
    for(int i=1; i< nlanels; i++) {
        cv::Mat roi = camera(roiRects.at(i-1));
        double similarity = cv::matchShapes(tmpImg, roi, CV_CONTOURS_MATCH_I1, 0);
        
        if(similarity < threshold){
            cv::rectangle(dst, roiRects.at(i-1), cv::Scalar(0, 255, 0), 3);
            if(min > similarity){
                min = similarity;
                std::printf("%f\n",similarity);
            }
        }
    }
    
    return MatToUIImage(dst);
}

@end
