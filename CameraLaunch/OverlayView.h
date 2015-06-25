//
//  OverlayView.h
//  CameraLaunch
//
//  Created by Bharadhwaj on 28/04/15.
//  Copyright (c) 2015 QBurst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<CoreMotion/CoreMotion.h>


@interface OverlayView : UIView <UITextFieldDelegate,UIPickerViewDelegate, UIPickerViewDataSource> {
    
    UIView *popView;
    UIImagePickerController *picker;
    NSString *height;
    UIButton *heightButton;
    UIButton *endButton;
    UIButton *snapButton;
    UIButton *scaleButton;
    UIImageView *overlayGraphicView;
    UIVisualEffectView *visualEffectView;
    UITextField *heightText;
    UILabel *myLabel;
    UIView *lineView;
    CMMotionManager *motionManager;
    NSTimer *timer;
    NSOperationQueue *operationQueue;
    UILabel *yaw ;
    UILabel *pitch;
    UILabel *roll;
    UILabel *length;
    UILabel *heightLabel;
    UILabel *snapLabel1;
    UILabel *snapLabel2;
    UILabel *snapLabel3;
    UILabel *snapLabel4;
    
    UIButton *back;

    NSMutableArray *pathArray;
    NSMutableDictionary *dict_path;
    CGPoint startPoint;
    CGPoint endPoint;
    UIBezierPath *myPath;
    UIColor *strokeColor;
    UIView *canvasView;


    
    float lengthFinal;
    float rollAngle;
    float pitchAngle;
    float yawAngle;
    
    float angleOne;
    float angleTwo;
    float angleTotal;
    float lengthOne;
    float lengthTwo;
    float distance;
    float heightInFloat;
    
    int loop;
    int numberOfPoints; // Contains number of times snap is clicked.
    
    float pointsList[100][2]; // Contains the relative co-ordinate from zero plane
    
    float lengthList[100]; // Contains the length from camera to each point
    float angleList[100]; // Contains the roll angle to each point. (Roll angle is horizontal angle)
    
    float distanceList[100]; // Contains the distance between point n and point n-1
    float angleSweptList[100]; // Contains the angle swept between point n and point n-1


}



- (void)snapButtonTouchUpInside;
- (void)heightButtonTouchUpInside;
- (void)noButtonTouchUpInside;
- (void)yesButtonTouchUpInside;
- (void)endButtonTouchUpInside;
- (void)scaleButtonTouchUpInside;

@end
