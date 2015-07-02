//
//  OverlayView.h
//  CameraLaunch
//
//  Created by Bharadhwaj on 28/04/15.
//  Copyright (c) 2015 QBurst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<CoreMotion/CoreMotion.h>
#import <MessageUI/MessageUI.h>

@protocol OverlayViewDelegate;

@interface OverlayView : UIView <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIGestureRecognizerDelegate> {
    
    UIImagePickerController *picker;
    

    UIView *lineView;
    UIView *canvasView;
    UIView *canvasViewbg;
    UIView *canvasViewBig;
    UIView *canvasViewbgBig;
    
    NSString *height;
    NSString *scale;
    NSString *imagePath;
    
    UIButton *heightButton;
    UIButton *endButton;
    UIButton *closeButton;
    UIButton *snapButton;
    UIButton *scaleButton;
    
    UIImageView *overlayGraphicView;
    UIImageView *imageView;
    UIImage *image;
    
    CGPoint startPoint;
    CGPoint endPoint;
    
    
    CGFloat cwidth;
    CGFloat cheight;
    CGFloat lastRotation;
    CGFloat lastScale;
    CGFloat rotationTouch;
    CGFloat firstX;
    CGFloat firstY;
    CGFloat firstXBig;
    CGFloat firstYBig;
    
    UINavigationBar *navBar;
    
    UIToolbar *toolBar;
    
    UIVisualEffectView *visualEffectView;
    
    CMMotionManager *motionManager;
    
    NSTimer *timer;
    
    UIBezierPath *myPath;

    UIRotationGestureRecognizer *rotationRecognizer;
    
    UIPinchGestureRecognizer *pinchRecognizer;
    
    UIPanGestureRecognizer *panRecognizer;
    UIPanGestureRecognizer *panRecognizerBig;
    
    
    float lengthFinal;
    float rollAngle;
    float pitchAngle;
    float yawAngle;
    float angleOne;
  
    float lengthOne;
    float heightInFloat;
    float scaleInFloat;
    
    float pointsList[100][2]; // Contains the relative co-ordinate from zero plane
    float pointsListBig[100][2];
    
    float lengthList[100]; // Contains the length from camera to each point
    float angleList[100]; // Contains the roll angle to each point. (Roll angle is horizontal angle)
    
    float distanceList[100]; // Contains the distance between point n and point n-1
    float angleSweptList[100]; // Contains the angle swept between point n and point n-1
    
    int loop;
    int numberOfPoints; // Contains number of times snap is clicked.


}

@property (nonatomic, strong) id<OverlayViewDelegate> delegate;

-(int) ComputeOutCode:(double)x andnum2:(double)y andNum3:(double)xmin andNum4:(double)ymin andNum5:(double)xmax andNum6:(double)ymax;
- (void)snapButtonTouchUpInside;
- (void)heightButtonTouchUpInside;
- (void)noButtonTouchUpInside;
- (void)yesButtonTouchUpInside;
- (void)endButtonTouchUpInside;
- (void)scaleButtonTouchUpInside;


@end

// <--- For importing on ViewController.h -->
@protocol OverlayViewDelegate <NSObject>

-(void)finishButtonTouchUpInsideDelegate:(NSString*)imagePath;

@end
