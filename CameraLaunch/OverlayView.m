//
//  OverlayView.m
//  CameraLaunch
//
//  Created by Bharadhwaj on 28/04/15.
//  Copyright (c) 2015 QBurst. All rights reserved.
//

#import "ViewController.h"
#import "OverlayView.h"
#import<CoreMotion/CoreMotion.h>
#import<QuartzCore/QuartzCore.h>
#import "canvas.h"


#define degrees(x) (180 * x / M_PI)


@implementation OverlayView

    canvas *canv[50];
    int count;
    
- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
         count = -1;
        NSLog(@"count= %d",count);
       
        // <--- Reading height from NSUserDefaults --->
        height = [[NSUserDefaults standardUserDefaults] stringForKey:@"Height"];
        heightInFloat = [height floatValue];
        if(height != nil) {
            [self yesButtonTouchUpInside];
        }
        NSLog(@"Height read: %@",height);
        
        
        //<--- Clear the background of the overlay --->
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        
        //<--- For the cross hair on camera view --->
        CGFloat cwidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat cheight = [UIScreen mainScreen].bounds.size.height;
        
               
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cheight/2.0, cwidth, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:0.345 green:0.345 blue:0.345 alpha:1];
        [self addSubview:lineView];
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(cwidth/2.0, 0, 1, cheight)];
        lineView.backgroundColor = [UIColor colorWithRed:0.345 green:0.345 blue:0.345 alpha:1];
        [self addSubview:lineView];
        
        //<--- For Navigation bar at the top --->
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, cwidth, 40)];
        navBar.barTintColor = [UIColor colorWithRed:0.627 green:0.627 blue:0.627 alpha:1];
        [self addSubview:navBar];
        
        //<--- For Toolbar at the bottom --->
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, cheight-40, cwidth, 40)];
        toolBar.barTintColor = [UIColor colorWithRed:0.627 green:0.627 blue:0.627 alpha:1];
        [self addSubview:toolBar];
        
        //<--- For Height button --->
        heightButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 70, 30)];
        UIImage *heightImage = [UIImage imageNamed:@"height.png"];
        UIImage *heightHighlightImage = [UIImage imageNamed:@"heighthighlight.png"];
        [heightButton setImage:heightImage forState:UIControlStateNormal];
        [heightButton setImage:heightHighlightImage forState:UIControlStateHighlighted];
        [heightButton addTarget:self action:@selector(heightButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:heightButton];
        
        //<--- For Scale button --->
        scaleButton = [[UIButton alloc] initWithFrame:CGRectMake(cwidth-75, 5, 70, 30)];
        UIImage *scaleImage = [UIImage imageNamed:@"scale.png"];
        UIImage *scaleHighlightImage = [UIImage imageNamed:@"scalehighlight.png"];
        [scaleButton setImage:scaleImage forState:UIControlStateNormal];
        [scaleButton setImage:scaleHighlightImage forState:UIControlStateHighlighted];
        [scaleButton addTarget:self action:@selector(scaleButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:scaleButton];        
    }
    return self;
}


// <--- Action when Snap button on screen is pressed --->
- (void)snapButtonTouchUpInside {
    
    
    count++;
    loop = count;
    
    
    CGFloat cwidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat cheight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat xWmin, xWmax, yWmin, yWmax, xVmin, xVmax, yVmin, yVmax;
    
    CGFloat sx, sy, tx, ty;
    
    // <--- Translation and Scaling to map the point --->
    xWmin = 0;
    xWmax = cwidth;
    yWmin = 0;
    yWmax = cheight;
    
    xVmin = cwidth/2;
    xVmax = cwidth;
    yVmin = cheight/2;
    yVmax = cheight;
    
    sx = 0.5;
    sy = 0.5;
    
    tx = (xWmax*xVmin - xWmin*xVmax)/(xWmax - xWmin);
    ty = (yWmax*yVmin - yWmin*yVmax)/(yWmax - yWmin);
    
    
    angleOne = rollAngle*180/M_PI;
    lengthOne = [self read];
    lengthList[count] = lengthOne;
    angleList[count] = angleOne;
    float angle = angleList[0];
    
    pointsList[count][0] = -3 * lengthOne * sinf((angleOne-angle)*M_PI/180) + 250;
    pointsList[count][0] = sx * pointsList[count][0] + tx;
    
    pointsList[count][1] = -3 * lengthOne * cosf((angleOne-angle)*M_PI/180) + 250;
    pointsList[count][1] = sy * pointsList[count][1] + ty;
    
    
    for(int i = 0; i <= count; i++) {
        NSLog(@"Length %d = %f",i,lengthList[i] );
        NSLog(@"Angle %d = %f",i,angleList[i] );
    }
    
    
    
    if(count >= 1) {
        
        int p = count - 1;
        int q = count;
        NSLog(@"count= %d",count);
        
        NSLog(@"cwidth %f",cwidth);
        NSLog(@"cheight %f",cheight);

        if(count == 1) {
            canvasViewbg=[[UIView alloc]initWithFrame:CGRectMake(cwidth/2+10, cheight/2+40, cwidth/2-20, cheight/2-90)];
            [canvasViewbg setBackgroundColor: [UIColor colorWithRed:0.059 green:0.059 blue:0.059 alpha:1]];
            [self addSubview:canvasViewbg];
            canvasView=[[UIView alloc]initWithFrame:CGRectMake(cwidth/2+15, cheight/2+45, cwidth/2-30, cheight/2-100)];
            [canvasView setBackgroundColor: [UIColor colorWithRed:0.227 green:0.227 blue:0.227 alpha:1]];
            [self addSubview:canvasView];
        }
        
        // <--- Checking whether the point to draw is out of bound. --->
        if(pointsList[p][0] < cwidth/2 || pointsList[p][0] > cwidth || pointsList[p][1] > cheight || pointsList[p][1] < cheight/2 || pointsList[q][0] < cwidth/2 || pointsList[q][0] > cwidth || pointsList[q][1] > cheight || pointsList[q][1] < cheight/2) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot draw. Point out of drawing area." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
    
        }
        else {
            canv[count-1] = [[canvas alloc] initWithFrame:CGRectMake(0, 0, cwidth, cheight) withStartX: pointsList[p][0] withStartY: pointsList[p][1] withEndX: pointsList[q][0] withEndY: pointsList[q][1]];
            [self addSubview:canv[count-1]];
            [canv[count-1] setNeedsDisplay];
        
        }
        
    }
        
    // <--- For blurring the BG --->
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = [[UIScreen mainScreen] bounds];
    [self addSubview:visualEffectView];
        
    // <--- Details of length1 --->
    UIAlertView *snapOnePopUp = [[UIAlertView alloc]initWithTitle:@"Length Details" message:[NSString stringWithFormat:@"\n Length: %f \n",lengthOne] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    snapOnePopUp.tag = 500;
    [snapOnePopUp show];
    
    if (count > 0) {
        
        //<--- For end button after second Snap click--->
        [endButton removeFromSuperview];
        [heightButton removeFromSuperview];
        [scaleButton removeFromSuperview];
        endButton = [[UIButton alloc] initWithFrame:CGRectMake(cwidth/2.0-35, 5, 70, 30)];
        UIImage *endImage = [UIImage imageNamed:@"end.png"];
        UIImage *endHighlightImage = [UIImage imageNamed:@"endhighlight.png"];
        [endButton setImage:endImage forState:UIControlStateNormal];
        [endButton setImage:endHighlightImage forState:UIControlStateHighlighted];
        [endButton addTarget:self action:@selector(endButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:endButton];
    }
    
    
    
    
}

- (void)endButtonTouchUpInside {
    
    numberOfPoints = count+1;
    NSLog(@"Points : %d",numberOfPoints);
    int j;
    
    for(int i = 0; i < numberOfPoints; i++) {
        if(i == numberOfPoints - 1)
            j = 0;
        else
            j = i+1;
        
        // <--- To find the total angle swept across --->
        if(angleList[i] > angleList[j])
            angleSweptList[i] = angleList[i]-angleList[j];
        else
            angleSweptList[i] = angleList[j]-angleList[i];
        
        // <-- Formula for finding the distance --->
        // C^2 = A^2 + B^2 - 2.A.B.cos(c)
        distanceList[i] = sqrtf((lengthList[i]*lengthList[i])+(lengthList[j]*lengthList[j])-(2.0*lengthList[i]*lengthList[j]*cosf(angleSweptList[i]*M_PI/180)));
        
        NSLog(@"AngleTotal %d = %f",i,angleSweptList[i]);
        NSLog(@"DistanceTotal %d = %f",i,distanceList[i]);

    }
    
    
    [self addSubview:heightButton];
    [self addSubview:scaleButton];
    [canvasViewbg removeFromSuperview];
    [canvasView removeFromSuperview];
    
    
    for(int i = 0; i < count; i++) {
        [canv[i] removeFromSuperview];
        [endButton removeFromSuperview];
            
    }
    count = -1;

}

- (void)scaleButtonTouchUpInside {
    
    
}

- (void)drawline
{
    endPoint.x = 500;
    endPoint.y = 500;
    
   // [myPath removeAllPoints];
   // [dict_path removeAllObjects];// remove prev object in dict (this dict is used for current drawing, All past drawings are managed by pathArry)
    
    //<--- Actual drawing --->
    [myPath moveToPoint:startPoint];
    [myPath addLineToPoint:endPoint];
    
    //[dict_path setValue:myPath forKey:@"path"];
    //[dict_path setValue:strokeColor forKey:@"color"];
    
    //NSDictionary *tempDict = [NSDictionary dictionaryWithDictionary:dict_path];
    //[pathArray addObject:tempDict];
    //[dict_path removeAllObjects];
    //s[self.view setNeedsDisplay];
    //startPoint=endPoint;
    //NSDictionary *tempDict = [NSDictionary dictionaryWithDictionary:dict_path];
    //[pathArray addObject:tempDict];
    //[dict_path removeAllObjects];
    //[self->canvas setNeedsDisplay];
    
    
}



- (CMQuaternion) multiplyQuanternion:(CMQuaternion)left withRight:(CMQuaternion)right {
    
    CMQuaternion newQ;
    newQ.w = left.w*right.w - left.x*right.x - left.y*right.y - left.z*right.z;
    newQ.x = left.w*right.x + left.x*right.w + left.y*right.z - left.z*right.y;
    newQ.y = left.w*right.y + left.y*right.w + left.z*right.x - left.x*right.z;
    newQ.z = left.w*right.z + left.z*right.w + left.x*right.y - left.y*right.x;
    
    return newQ;
}

-(float)walkaroundRawAngleFromAttitude:(CMAttitude*)attitude {
    
    CMQuaternion e =  (CMQuaternion){0,0,1,1};
    CMQuaternion quatConj = attitude.quaternion;
    quatConj.x *= -1; quatConj.y *= -1; quatConj.z *= -1;
    CMQuaternion quat1 = attitude.quaternion;
    CMQuaternion quat2 = [self multiplyQuanternion:quat1 withRight:e];
    CMQuaternion quat3 = [self multiplyQuanternion:quat2 withRight:quatConj];
    
    return atan2f(quat3.y, quat3.x);
}

-(float)walkaroundAngleFromAttitude:(CMAttitude*)attitude fromHomeAngle:(float)homeangle {
    
    float rawangle = [self walkaroundRawAngleFromAttitude:attitude];
    if (rawangle <0) rawangle += M_PI *2;
    if (homeangle < 0) homeangle += M_PI *2;
    float finalangle = rawangle - homeangle;
    if (finalangle < 0) finalangle += M_PI *2;
    
    return rawangle;
}




// <--- To obtain the Yaw, Pitch and Roll values --->
-(float) read {
    
    CMAttitude *attitude;
    CMDeviceMotion *motion = motionManager.deviceMotion;
    attitude = motion.attitude;
    
    //CMQuaternion quat = motionManager.deviceMotion.attitude.quaternion;
    //rolldeg = degrees(atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z)) ;
    //pitchdeg = degrees(atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z));
    //yawdeg = degrees(asin(2*quat.x*quat.y + 2*quat.w*quat.z));
    
    float rollRadian=[self walkaroundAngleFromAttitude:attitude fromHomeAngle:0];

    
    // <--- Obtaining three angles --->
    yawAngle = attitude.yaw;
    pitchAngle = attitude.pitch;
    rollAngle = rollRadian;
    
    // <--- Obtaining height entered in text box from Alertview function --->
    heightInFloat = [height floatValue];
   
    // <--- Displaying Yaw, Pitch and Roll on screen --->
    /*NSString *yawstring = [NSString stringWithFormat:@"Yaw: %f",attitude.yaw*180/M_PI];
    yaw = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 170, 30)];
    [yaw setBackgroundColor:[UIColor blackColor]];
    yaw.text = yawstring;
    yaw.textColor = [UIColor whiteColor];
    
    NSString *pitchstring = [NSString stringWithFormat:@"Pitch: %f",attitude.pitch*180/M_PI];
    pitch = [[UILabel alloc]initWithFrame:CGRectMake(10, 110, 170, 30)];
    [pitch setBackgroundColor:[UIColor blackColor]];
    pitch.text =pitchstring;
    pitch.textColor = [UIColor whiteColor];
    
    NSString *rollstring = [NSString stringWithFormat:@"Roll: %f",rollRadian*180/M_PI];
    roll = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 170, 30)];
    [roll setBackgroundColor:[UIColor blackColor]];
    roll.text = rollstring;
    roll.textColor = [UIColor whiteColor];
    
    NSString *len = [NSString stringWithFormat:@"Length: %f",tan(pitchAngle)*heightInFloat];
    length = [[UILabel alloc]initWithFrame:CGRectMake(10, 140, 170, 30)];
    [length setBackgroundColor:[UIColor blackColor]];
    length.text = len;
    length.textColor = [UIColor whiteColor];
    
    NSString *heightLab = [NSString stringWithFormat:@"Height: %f",heightInFloat];
    heightLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 170, 170, 30)];
    [heightLabel setBackgroundColor:[UIColor blackColor]];
    heightLabel.text = heightLab;
    heightLabel.textColor = [UIColor whiteColor];*/
    
    //[self addSubview:yaw];
    //[self addSubview:pitch];
    //[self addSubview:roll];
    //[self addSubview:length];
    //[self addSubview:heightLabel];

    // <-- Distance to the point on cross hair --->
    lengthFinal = tan(pitchAngle) * heightInFloat;
    
    return lengthFinal;
    
    
}



- (void) heightButtonTouchUpInside {
    
    // <--- Removing the Yaw, Pitch, Roll and Length --->
    //[yaw removeFromSuperview];
    //[pitch removeFromSuperview];
    //[roll removeFromSuperview];
    //[length removeFromSuperview];
    //[heightLabel removeFromSuperview];
     
    // <--- For blurring the BG --->
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = [[UIScreen mainScreen] bounds];
    [self addSubview:visualEffectView];
    
    
    // <--- Pop-up view asking height --->
    UIAlertView *heightPopUp = [[UIAlertView alloc]initWithTitle:@"Height Information" message:@"Please enter height" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    heightPopUp.tag = 100;
    [heightPopUp textFieldAtIndex:0].delegate = self;
    heightPopUp.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[heightPopUp textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
    [[heightPopUp textFieldAtIndex:0] becomeFirstResponder];
    [heightPopUp show];

}


- (void) noButtonTouchUpInside {

    // <--- Removing the overlay blur view --->
    [visualEffectView removeFromSuperview];
    
    
}

- (void) yesButtonTouchUpInside {
    
    if ([height isEqualToString:@""] || [height floatValue] == 0 ) {
        UIAlertView *alertPopUp = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Invalid Entry!"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertPopUp.tag = 200;
        [alertPopUp show];
    }
    
    else {
        
        CGFloat cwidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat cheight = [UIScreen mainScreen].bounds.size.height;
        

        
        //<--- Snap Button --->
        snapButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 41, cwidth, cheight-41)];
      //utton setTitle:@""  forState:UIControlStateNormal];
       // snapButton.layer.cornerRadius = 3;
       // snapButton.layer.borderWidth = 1;
       // snapButton.layer.borderColor = UIColor.blackColor.CGColor;
        snapButton.backgroundColor = [UIColor clearColor];
        [snapButton addTarget:self action:@selector(snapButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:snapButton];
        
        
        // <--- Removing the overlay blur view --->
        [visualEffectView removeFromSuperview];
    
        //<---- Gyro values --->
        motionManager = [[CMMotionManager alloc] init];
        motionManager.deviceMotionUpdateInterval = 1;
        [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
        timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(read) userInfo:nil repeats:YES];
    
        // <--- Checking whether Gyro is available on the device --->
        if(![motionManager isGyroAvailable]){
        
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle: @"Error" message:@"No Gyroscope found!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        
        }
    }

}

// <--- Controls what happens when buttons on UIAlertView is pressed --->
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    
    if (alertView.tag == 100) { // Height input pop-up
        if (buttonIndex == 0) {  // Cancel Button
            [self noButtonTouchUpInside];
        }
        else if (buttonIndex == 1) {   // Done Button
            
            NSString *heightEntered = [alertView textFieldAtIndex:0].text;
            
            // <--- To validate the text box to ensure only one dot is present --->
            NSString *expression = @"^([0-9]+)?([\\.]([0-9])+)?$";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:nil];
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:heightEntered options:0 range:NSMakeRange(0, [heightEntered length])];
            if (numberOfMatches == 0) {
                UIAlertView *alertPopUp = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Invalid Entry!"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                alertPopUp.tag = 200;
                [alertPopUp show];
                [self noButtonTouchUpInside];
            }
            else {
                height = heightEntered;
                [self yesButtonTouchUpInside];
            
                // <--- Using NSUserDefaults for persistent storage --->
                [[NSUserDefaults standardUserDefaults] setObject:height forKey:@"Height"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSLog(@"Height wrote: %@",height);
            }
        }
    }
    if (alertView.tag == 200) { // Error pop-up with no value
        if (buttonIndex == 0) {  // Cancel Button
            
            [visualEffectView removeFromSuperview];
            [self heightButtonTouchUpInside];
        }
    }
    
    
    if (alertView.tag == 500) { // Distance and length pop-up
        if (buttonIndex == 0) {  // Reset Button
            // <--- For changing names of button when snap is taken --->
            [snapButton setTitle:@""  forState:UIControlStateNormal];
            [self addSubview:snapButton];
            [visualEffectView removeFromSuperview];
            
        }
    }
    
}


- (void)dealloc {
}


@end
