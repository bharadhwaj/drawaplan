//
//  ViewController.h
//  CameraLaunch
//
//  Created by Bharadhwaj on 24/04/15.
//  Copyright (c) 2015 QBurst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "OverlayView.h"

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate,OverlayViewDelegate,MFMailComposeViewControllerDelegate> {
    
    UIImagePickerController *picker;

}

- (void)viewFrame;

@property (nonatomic) BOOL condition;

@end

