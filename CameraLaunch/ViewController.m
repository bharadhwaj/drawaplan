//
//  ViewController.m
//  CameraLaunch
//
//  Created by Bharadhwaj on 24/04/15.
//  Copyright (c) 2015 QBurst. All rights reserved.
//

#import "ViewController.h"
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

-(void)finishButtonTouchUpInsideDelegate:(NSString*)imagePath {
    
    NSString *emailTitle = @"Blue print plan.";
    NSString *messageBody = @"Hey, check in attachments for the image!";
    NSArray *toRecipents = [NSArray arrayWithObject:@"bharadhwaj10@gmail.com"];
    
    MFMailComposeViewController *mailSent = [[MFMailComposeViewController alloc] init];
    mailSent.mailComposeDelegate = self;
    [mailSent setSubject:emailTitle];
    [mailSent setMessageBody:messageBody isHTML:NO];
    [mailSent setToRecipients:toRecipents];
    
    // <--- Retrieving  image in local documents --->
    NSData *fileData = [NSData dataWithContentsOfFile:imagePath];
    [mailSent addAttachmentData:fileData mimeType:@"image/jpeg" fileName:@"BluePrintImage.jpg"];
    
    // <--- Get back the control to ViewController --->
    [picker dismissViewControllerAnimated:NO completion:NULL];
    
    if ([MFMailComposeViewController canSendMail] )
        [self presentViewController:mailSent animated:YES completion:NULL];
    else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle: @"Error" message:@"No e-mail account in the device are logged in. Please login and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    // <--- To check various possibilities on sending the mail --->
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }

    // <--- Close the Mail Interface --->
    [self dismissViewControllerAnimated:YES completion:NULL];

    // <--- Relaunch the app --->
    [self viewFrame];
    
}

- (void)viewFrame {
    
    CGFloat cwidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat cheight = [UIScreen mainScreen].bounds.size.height;
    
    OverlayView *overlay = [[OverlayView alloc] initWithFrame:CGRectMake(0, 0, cwidth, cheight)];
    overlay.delegate = self;
    
    picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    // <--- Loads camera screen --->
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    picker.showsCameraControls = NO;
    
    // <--- To strech the camera screen to the display size --->
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 71.0);
    self->picker.cameraViewTransform = translate;
    CGAffineTransform scale = CGAffineTransformScale(translate, 1.333333, 1.333333);
    self->picker.cameraViewTransform = scale;
    picker.cameraOverlayView = overlay;
    [self presentViewController:picker animated:YES completion:NULL];
    
}

@end
