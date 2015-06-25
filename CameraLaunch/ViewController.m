//
//  ViewController.m
//  CameraLaunch
//
//  Created by Bharadhwaj on 24/04/15.
//  Copyright (c) 2015 QBurst. All rights reserved.
//

#import "ViewController.h"
#import "OverlayView.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.condition = YES;

}
-(void)viewDidAppear:(BOOL) animated {
    
    [super viewDidAppear:animated];
    
    if (self.condition) {
        
        [self viewFrame];
        self.condition = NO;
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewFrame {
    
    CGFloat cwidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat cheight = [UIScreen mainScreen].bounds.size.height;
    OverlayView *overlay = [[OverlayView alloc] initWithFrame:CGRectMake(0, 0, cwidth, cheight)];
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    picker.showsCameraControls = NO;
    
    
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 71.0);
    self->picker.cameraViewTransform = translate;
    CGAffineTransform scale = CGAffineTransformScale(translate, 1.333333, 1.333333);
    self->picker.cameraViewTransform = scale;
    picker.cameraOverlayView = overlay;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

@end
