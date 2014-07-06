//
//  CVDetectorViewController.h
//  TerrorTorch
//
//  Created by Bobby Ren on 7/10/14.
//  Copyright (c) 2014 reBaked. All rights reserved.
//


#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif
#import <opencv2/highgui/cap_ios.h>

@protocol CVDetectorDelegate
-(void)motionTriggered;
@end

@interface CVDetectorViewController : UIViewController <CvVideoCameraDelegate>
{
    UIImageView *imageView;
    CvVideoCamera *camera;

    // testing
    UILabel *labelTrigger;

    int frame;
}

@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (nonatomic, weak) id delegate;
@end
