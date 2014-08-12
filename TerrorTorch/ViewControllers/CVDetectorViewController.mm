//
//  CVDetectorViewController.m
//  TerrorTorch
//
//  Created by Bobby Ren on 7/10/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//
// resources for openCV and documentation:
//
// Source for official openCV port for iOS
// http://opencv.org/downloads.html
//
// Installation instructions
// http://docs.opencv.org/trunk/doc/tutorials/ios/video_processing/video_processing.html#opencviosvideoprocessing
//
// Including c++ and objective C classes with swift
// https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html#//apple_ref/doc/uid/TP40014216-CH10-XID_74
//
// Simple openCV motion detection
// http://blog.cedric.ws/opencv-simple-motion-detection

#define TESTING 0

#import "CVDetectorViewController.h"
using namespace cv;

@interface CVDetectorViewController ()
{
#ifdef __cplusplus
    // openCV objects
    Mat prev;
    Mat curr;
    Mat next;
#endif
}
@end

@implementation CVDetectorViewController
@synthesize cameraPosition;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    frame = 0;

    [self setupView];
    [self setupCamera];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupView {
    CGRect newFrame = self.view.frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = 0;
    imageView = [[UIImageView alloc] initWithFrame:newFrame];
#if TESTING
    [self.view addSubview:imageView];
#endif
}

-(void)setupCamera {
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    self.videoCamera.defaultAVCaptureDevicePosition = self.cameraPosition;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.delegate = self;
    self.videoCamera.grayscaleMode = YES;
    [self.videoCamera start];
}

#pragma mark - Protocol CvVideoCameraDelegate

#ifdef __cplusplus
// Do some OpenCV stuff with the image
- (void)processImage:(Mat&)image;
{
    Mat gray;
    image.copyTo(gray);

    // store frames
    prev = curr;
    curr = next;
    next = gray;

    // only do calculation after we have all three frames, and let camera settle
    if (frame >= 10) {
        // calculate motion based on Collins et. al
        Mat d1, d2, result;
        absdiff(prev, next, d1);
        absdiff(curr, next, d2);
        bitwise_and(d1, d2, result);
        threshold(result, result, 35, 255, CV_THRESH_BINARY);

        // display to image
#if TESTING
        result.copyTo(image);
#endif

        // calculate total diff
        Mat hasPixel = (result == 255) / 255;
        Scalar total = sum(hasPixel);
        double value = total[0];

        if (value > 3000) { // this threshold seems ok
            [self triggerThreshold];
        }
    }
    frame++;
}
#endif

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)triggerThreshold {
    // todo: trigger recording, trigger terror mode
    NSLog(@"Triggered");

    // dismiss camera
    [self.videoCamera stop];

    // tell delegate
    [self.delegate motionTriggered];
}

-(void)dealloc {

}
@end
