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
#define pixel 37.795276

@implementation OverlayView

    canvas *canv[50];
    canvas *canvbig[50];

    int count;

    @synthesize delegate;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        // <--- Screen's width and height --->
        cwidth = [UIScreen mainScreen].bounds.size.width;
        cheight = [UIScreen mainScreen].bounds.size.height;
        
        // <--- Reseting count --->
        count = -1;
       
        // <--- Reading height from NSUserDefaults --->
        height = [[NSUserDefaults standardUserDefaults] stringForKey:@"Height"];
        heightInFloat = [height floatValue];
        
        // <--- Reading scale from NSUserDefaults --->
        scale = [[NSUserDefaults standardUserDefaults] stringForKey:@"Scale"];
        scaleInFloat = [scale floatValue];
        
        
        if(height != nil & scale != nil) {
            [self yesButtonTouchUpInside];
        }
      
    
        NSLog(@"Height read: %@",height);
        NSLog(@"Scale read: %@",scale);
        
        //<--- Clear the background of the overlay --->
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        //<--- For the cross hair on camera view --->
        lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cheight/2.0, cwidth, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:0.345 green:0.345 blue:0.345 alpha:1];
        [self addSubview:lineView];
        
        lineView = [[UIView alloc] initWithFrame:CGRectMake(cwidth/2.0, 0, 1, cheight)];
        lineView.backgroundColor = [UIColor colorWithRed:0.345 green:0.345 blue:0.345 alpha:1];
        [self addSubview:lineView];
        
        
        //<--- For Navigation bar at the top --->
        navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, cwidth, 40)];
        navBar.barTintColor = [UIColor colorWithRed:0.627 green:0.627 blue:0.627 alpha:1];
        [self addSubview:navBar];
        
        
        //<--- For Toolbar at the bottom --->
        toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, cheight-40, cwidth, 40)];
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
    
    CGFloat xWmin, xWmax, yWmin, yWmax, xVmin, xVmax, yVmin, yVmax,xmin = 0,xmax = 0,ymin = 0,ymax = 0;
    
    xWmin = 0;
    xWmax = cwidth;
    yWmin = 0;
    yWmax = cheight;
    
    // cwidth/2+15, cheight/2+45, cwidth/2-30, cheight/2-100
    
    xVmin = cwidth/2+15;
    xVmax = cwidth-30;
    yVmin = cheight/2+45;
    yVmax = cheight;

    
    count++;
    loop = count;
    
    // <--- Reading height from NSUserDefaults --->
    height = [[NSUserDefaults standardUserDefaults] stringForKey:@"Height"];
    heightInFloat = [height floatValue];
    
    // <--- Reading scale from NSUserDefaults --->
    scale = [[NSUserDefaults standardUserDefaults] stringForKey:@"Scale"];
    scaleInFloat = [scale intValue];
    
    NSString* scaleString = [NSString stringWithFormat:@"%i", scaleInFloat];
    
    
    long len = [scaleString length];
    
    angleOne = rollAngle*180/M_PI;
    
    lengthOne = [self read];
    
    lengthList[count] = lengthOne;
    angleList[count] = angleOne;
    
    float angle = angleList[0];
    

    pointsList[count][0] = -1 * sqrtf(2.0) * lengthOne * (pixel/scaleInFloat) * sinf((angleOne-angle)*M_PI/180)+(cwidth/2);
    if (pointsList[count][0] < 0)
        pointsList[count][0] = -1 * pointsList[count][0];
    pointsListBig[count][0] = pointsList[count][0];
    pointsList[count][0] = -3 * (scaleInFloat/len) *  lengthOne * sinf((angleOne-angle)*M_PI/180)+(cwidth/2);
    
    pointsList[count][1] = -1 * sqrtf(2.0) * lengthOne * (pixel/scaleInFloat) * cosf((angleOne-angle)*M_PI/180)+(cheight/2);
    if (pointsList[count][1] < 0)
        pointsList[count][1] = -1 * pointsList[count][1];
    pointsListBig[count][1] = pointsList[count][1];
    pointsList[count][1] =  -3 * (scaleInFloat/len) * lengthOne  * cosf((angleOne-angle)*M_PI/180)+(cheight/2);

    
    pointsList1[count][0]=pointsList[count][0];
    pointsList1[count][1]=pointsList[count][1];
    
    
    
    //find edge points
    if(flag==1)
    {
        NSLog(@" at main point sx1 sy1 tx1 ty1 %f %f %f %f",sx1,sy1,tx1,ty1);
        
        pointsList1[count][0]= sx1*pointsList1[count][0]+tx1;
        pointsList1[count][1]= sy1*pointsList1[count][1]+ty1;
        
    }
    

    
    
    if(count >= 1) {
        int j;
        int p = count - 1;
        int q = count;
        numberOfPoints = count+1;
    
        if(count == 1) {
            
            // <--- Small canvas border -->
            canvasViewbg=[[UIView alloc]initWithFrame:CGRectMake(cwidth/2+10, cheight/2+40, cwidth/2-20, cheight/2-90)];
            [canvasViewbg setBackgroundColor: [UIColor colorWithRed:0.059 green:0.059 blue:0.059 alpha:1]];
            [self addSubview:canvasViewbg];
            
            
            canvasView=[[UIView alloc]initWithFrame:CGRectMake(cwidth/2+15, cheight/2+45, cwidth/2-30, cheight/2-100)];
            [canvasView setBackgroundColor: [UIColor colorWithRed:0.227 green:0.227 blue:0.227 alpha:1]];
            [self addSubview:canvasView];
            
            // <--- Pinch Gesture --->
            pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
            [self addGestureRecognizer:pinchRecognizer];
            
            // <--- Pan Gesture --->
            panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveSmall:)];
            [self addGestureRecognizer:panRecognizer];
        }
        
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
            
        }
        
        xVmin = cwidth/2 + 30;
        xVmax = cwidth - 30;
        yVmin = cheight/2 + 100;
        yVmax = yVmin + (xVmax - xVmin);

        
        
        if(pointsList1[p][0] < xVmin || pointsList1[p][0] > xVmax || pointsList1[p][1] > yVmax || pointsList1[p][1] < yVmin  || pointsList1[q][0] < xVmin|| pointsList1[q][0] > xVmax || pointsList1[q][1] > yVmax  || pointsList1[q][1] < yVmin) {
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning: " message:@"Image has been scaled!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            for(int k = 0;k <= count; k++) {
                if(k == 0) {
                    xmin=pointsList1[k][0];
                    ymin=pointsList1[k][1];
                    xmax=pointsList1[k][0];
                    ymax=pointsList1[k][1];
                }
                if(pointsList1[k][0]>xmax)
                    xmax=pointsList1[k][0];
                if(pointsList1[k][0]<xmin)
                    xmin=pointsList1[k][0];
                if(pointsList1[k][1]>ymax)
                    ymax=pointsList1[k][1];
                if(pointsList1[k][1]<ymin)
                    ymin=pointsList1[k][1];
            }
            NSLog(@" at scaling xmin xmax,ymin ymax %f %f %f %f",xmin,xmax,ymin,ymax);

            float temp;
            
            if(ymax-ymin>xmax-xmin) {
                temp=(ymax-ymin);
                temp=temp-(xmax-xmin);
                xmax=xmax+temp;
            }
            
            else {
                temp=(xmax-xmin);
                temp=temp-(ymax-ymin);
                ymax=ymax+temp;
            }
            
            
            
            NSLog(@"scaled points");
            sx1=(xVmax-xVmin)/(xmax-xmin);
            sy1=(yVmax-yVmin)/(ymax-ymin);
            
            
            
            tx1 = (xmax*xVmin - xmin*xVmax)/(xmax - xmin);
            ty1 = (ymax*yVmin - ymin*yVmax)/(ymax - ymin);
            
            NSLog(@" at scaling sx1 sy1 tx1 ty1 %f %f %f %f",sx1,sy1,tx1,ty1);
            
            for(int k=0;k<count;k++)
                [canv[k] removeFromSuperview];
            
            flag=1;
            for(int k=0;k<=count;k++)
            {
                // NSLog(@" sx1 sy1 tx1 ty1 %f %f %f %f",sx1,sy1,tx1,ty1);
                NSLog(@"orginal points %f %f ",pointsList1[k][0],pointsList1[k][1]);
                pointsList1[k][0]= sx1*pointsList1[k][0]+tx1;
                pointsList1[k][1]= sy1*pointsList1[k][1]+ty1;
                NSLog(@" x and y %f %f",pointsList1[k][0],pointsList1[k][1]);
            }
            
            for(int k=1;k<=count;k++)
            {
                p=k-1;
                q=k;
                canv[p] = [[canvas alloc] initWithFrame:CGRectMake(0, 0, cwidth, cheight) withStartX: pointsList1[p][0] withStartY: pointsList1[p][1] withEndX: pointsList1[q][0] withEndY: pointsList1[q][1] withdist: distanceList[p]];
                [self addSubview:canv[p]];
                [canv[p] setNeedsDisplay];
                
            }
            
            /* NSLog(@" x and y are %f %f %f %f",pointsList[p][0],pointsList[p][1],pointsList[q][0],pointsList[q][1]);
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot draw. Point out of drawing area." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             count--;
             */
            
        }
        else {
            
            pointsList1[count][0]= sx1*pointsList1[count][0]+tx1;
            pointsList1[count][1]= sy1*pointsList1[count][1]+ty1;

            
            for(int k=1;k<=count;k++)
            {
                p=k-1;
                q=k;
                canv[p] = [[canvas alloc] initWithFrame:CGRectMake(0, 0, cwidth, cheight) withStartX: pointsList1[p][0] withStartY: pointsList1[p][1] withEndX: pointsList1[q][0] withEndY: pointsList1[q][1] withdist: distanceList[p]];
                [self addSubview:canv[p]];
                [canv[p] setNeedsDisplay];
                
            }
            
        }
        

        
        
        
     /*   canv[count-1] = [[canvas alloc] initWithFrame:CGRectMake(0, 0, cwidth, cheight) withStartX: pointsList[p][0] withStartY: pointsList[p][1] withEndX: pointsList[q][0] withEndY: pointsList[q][1] withdist:distanceList[count-1]];
        [self addSubview:canv[count-1]];
        [canv[count-1] setNeedsDisplay];
      */
            
        
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

-(void)scale:(id)sender {
    
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
    }
    
    for(int i = 0; i < loop; i++) {
        CGFloat scales = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
        CGAffineTransform currentTransform = canv[i].transform;
        CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scales, scales);
        [canv[i] setTransform:newTransform];
    }
    
    lastScale = [(UIPinchGestureRecognizer*)sender scale];
}

-(void)moveSmall:(id)sender {
    
    for(int i = 0; i < loop; i++) {
        CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:canv[i]];
        if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
            firstX = [canv[i] center].x;
            firstY = [canv[i] center].y;
        }
        translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
        [canv[i] setCenter:translatedPoint];
    }
}

-(void)moveBig:(id)sender {
    
    for(int i = 0; i < loop; i++) {
        CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:canv[i]];
        if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
            firstXBig = [canvbig[i] center].x;
            firstYBig = [canvbig[i] center].y;
        }
        translatedPoint = CGPointMake(firstX+translatedPoint.x, firstY+translatedPoint.y);
        [canvbig[i] setCenter:translatedPoint];
    }
}

- (void)endButtonTouchUpInside {

    flag=0;
    // <--- For blurring the BG --->
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = [[UIScreen mainScreen] bounds];
    [self addSubview:visualEffectView];
    
    //<--- For Navigation bar at the top --->
    navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, cwidth, 40)];
    navBar.barTintColor = [UIColor colorWithRed:0.627 green:0.627 blue:0.627 alpha:1];
    [self addSubview:navBar];
    
    //<--- For Toolbar at the bottom --->
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, cheight-40, cwidth, 40)];
    toolBar.barTintColor = [UIColor colorWithRed:0.627 green:0.627 blue:0.627 alpha:1];
    [self addSubview:toolBar];
    
    //<--- For loading Big canvas Screen --->
    canvasViewbgBig=[[UIView alloc]initWithFrame:CGRectMake(10, 50, cwidth-20, cheight-100)];
    [canvasViewbgBig setBackgroundColor: [UIColor colorWithRed:0.059 green:0.059 blue:0.059 alpha:1]];
    [self addSubview:canvasViewbgBig];
    canvasViewBig=[[UIView alloc]initWithFrame:CGRectMake(15, 55, cwidth-30, cheight-110)];
    [canvasViewBig setBackgroundColor: [UIColor colorWithRed:0.227 green:0.227 blue:0.227 alpha:1]];
    [self addSubview:canvasViewBig];
    
    
    [canvasViewbg removeFromSuperview];
    [canvasView removeFromSuperview];
    loop = count;
    
    for(int j = 1; j <= loop; j++) {
        int p = j - 1;
        int q = j;
        
        // <--- Removing old small canvas --->
        [canv[p] removeFromSuperview];

        canvbig[p] = [[canvas alloc] initWithFrame:CGRectMake(0, 0, cwidth, cheight) withStartX: pointsListBig[p][0] withStartY: pointsListBig[p][1] withEndX: pointsListBig[q][0] withEndY: pointsListBig[q][1] withdist:distanceList[p]];
        [self addSubview:canvbig[p]];
        [canvbig[p] setNeedsDisplay];
            
        
    }
    
    //<--- For close button after clicking end--->
    [endButton removeFromSuperview];
    [heightButton removeFromSuperview];
    [scaleButton removeFromSuperview];
    closeButton = [[UIButton alloc] initWithFrame:CGRectMake(cwidth/2.0-35, 5, 70, 30)];
    UIImage *closeImage = [UIImage imageNamed:@"close.png"];
    UIImage *closeHighlightImage = [UIImage imageNamed:@"closehighlight.png"];
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    [closeButton setImage:closeHighlightImage forState:UIControlStateHighlighted];
    [closeButton addTarget:self action:@selector(closeButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    // <--- Rotate Gesture --->
    rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    [self addGestureRecognizer:rotationRecognizer];
    
    // <--- Pan Gesture --->
    panRecognizerBig = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveBig:)];
    [self addGestureRecognizer:panRecognizerBig];
    
    // <--- Reseting the count back to NIL --->
    count = -1;

}

- (void)closeButtonTouchUpInside {
    
    
    [self addSubview:navBar];
    [self addSubview:toolBar];
    [self addSubview:heightButton];
    [self addSubview:scaleButton];
    [self addSubview:snapButton];
    
    // <--- For Printing image --->
    CGRect imageRect = CGRectMake(10, 50, cwidth-20, cheight-100);
    UIGraphicsBeginImageContext(imageRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, -imageRect.origin.x, -imageRect.origin.y);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [visualEffectView removeFromSuperview];
    [snapButton removeFromSuperview];
    [canvasViewbgBig removeFromSuperview];
    [closeButton removeFromSuperview];
    
    // <--- Writing the subview as Image --->
    NSData* imageData = UIImageJPEGRepresentation(image, 1.0);
    imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/BluePrintImageInitial.jpg"];
    [imageData writeToFile:imagePath atomically:YES];
    
    // <--- For sending mail. Definition on ViewController.m -->
    [delegate finishButtonTouchUpInsideDelegate:imagePath];
    
    UIImage *customImage = [UIImage imageWithContentsOfFile:imagePath];
    
    // <--- Displaying the new image --->
    imageView = [[UIImageView alloc] init];
    imageView.image = customImage;
    imageView.frame = CGRectMake(150, 220, cwidth-300, cheight-440); // pass your frame here
    [self addSubview:imageView];
    
    // <--- For removing large canvas --->
    for(int i = 0; i < loop; i++) {
        [canvbig[i] removeFromSuperview];
    }
}


-(void)rotate:(id)sender {

    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        lastRotation = 0.0;
        return;
    }
    
    rotationTouch = 0.0 - (lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
    
    
    
    for(int i = 0; i < loop; i++) {
        CGAffineTransform currentTransform = canvbig[i].transform;
        CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotationTouch);
        [canvbig[i] setTransform:newTransform];
    }
    
    
    lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
}

- (void)drawline {
    endPoint.x = 500;
    endPoint.y = 500;
    
    //<--- Actual drawing --->
    [myPath moveToPoint:startPoint];
    [myPath addLineToPoint:endPoint];
    
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
    
    float rollRadian=[self walkaroundAngleFromAttitude:attitude fromHomeAngle:0];

    
    // <--- Obtaining three angles --->
    yawAngle = attitude.yaw;
    pitchAngle = attitude.pitch;
    rollAngle = rollRadian;
    
    // <--- Obtaining height entered in text box from Alertview function --->
    heightInFloat = [height floatValue];
   
    // <-- Distance to the point on cross hair --->
    lengthFinal = tan(pitchAngle) * heightInFloat;
    
    return lengthFinal;
}

- (void)scaleButtonTouchUpInside {
    
    // <--- For blurring the BG --->
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = [[UIScreen mainScreen] bounds];
    [self addSubview:visualEffectView];
    
    
    // <--- Pop-up view asking scale --->
    UIAlertView *scalePopUp = [[UIAlertView alloc]initWithTitle:@"Scale Information" message:@"Please enter scale" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    scalePopUp.tag = 300;
    scalePopUp.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[scalePopUp textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
    [[scalePopUp textFieldAtIndex:0] becomeFirstResponder];
    [scalePopUp show];
    
}


- (void) heightButtonTouchUpInside {
     
    // <--- For blurring the BG --->
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = [[UIScreen mainScreen] bounds];
    [self addSubview:visualEffectView];
    
    
    // <--- Pop-up view asking height --->
    UIAlertView *heightPopUp = [[UIAlertView alloc]initWithTitle:@"Height Information" message:@"Please enter height" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    heightPopUp.tag = 100;
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
        UIAlertView *alertPopUp = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Invalid Height Entry!"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertPopUp.tag = 200;
        [alertPopUp show];
    }
    
    if ([scale isEqualToString:@""] || [scale intValue] == 0 ) {
        UIAlertView *alertPopUp = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Invalid Scale Entry!"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertPopUp.tag = 400;
        [alertPopUp show];
    }
    
    else {
        
        //<--- Snap Button --->
        snapButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 41, cwidth, cheight/2)];
        snapButton.backgroundColor = [UIColor clearColor];
        [snapButton addTarget:self action:@selector(snapButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:snapButton];
        
        
        // <--- Removing the overlay blur view --->
        [visualEffectView removeFromSuperview];
    
        //<---- Gyro values --->
        motionManager = [[CMMotionManager alloc] init];
        motionManager.deviceMotionUpdateInterval = .01;
        [motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
        timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(read) userInfo:nil repeats:YES];
    
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
            NSString *expression = @"^([0-9]+)?([\\.]?([0-9])+)?$";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:nil];
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:heightEntered options:0 range:NSMakeRange(0, [heightEntered length])];
            if (numberOfMatches == 0) {
                UIAlertView *alertPopUp = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Invalid Height Entry!"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                alertPopUp.tag = 200;
                [alertPopUp show];
                [self noButtonTouchUpInside];
            }
            else {
                height = heightEntered;
                [self yesButtonTouchUpInside];
            
                // <--- Using NSUserDefaults for persistent storage of Height--->
                [[NSUserDefaults standardUserDefaults] setObject:height forKey:@"Height"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSLog(@"Height wrote: %@",height);
            }
        }
    }
    if (alertView.tag == 200) { // Error pop-up with no value for height
        if (buttonIndex == 0) {  // Cancel Button
            
            [visualEffectView removeFromSuperview];
            [self heightButtonTouchUpInside];
        }
    }
    
    if (alertView.tag == 300) { // Scale input pop-up
        if (buttonIndex == 0) {  // Cancel Button
            [self noButtonTouchUpInside];
        }
        else if (buttonIndex == 1) {   // Done Button
            
            NSString *scaleEntered = [alertView textFieldAtIndex:0].text;
            
            // <--- To validate the text box to ensure only one dot is present --->
            NSString *expression = @"^([0-9]+)?([\\.]?([0-9])+)?$";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:nil];
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:scaleEntered options:0 range:NSMakeRange(0, [scaleEntered length])];
            
            if (numberOfMatches == 0) {
                UIAlertView *alertPopUp = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Invalid Scale Entry!"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                alertPopUp.tag = 400;
                [alertPopUp show];
                [self noButtonTouchUpInside];
            }
            else {
                scale = scaleEntered;
                [self yesButtonTouchUpInside];
                
                // <--- Using NSUserDefaults for persistent storage of height value --->
                [[NSUserDefaults standardUserDefaults] setObject:scale forKey:@"Scale"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSLog(@"Scale wrote: %@",scale);
            }
        }
    }
    if (alertView.tag == 400) { // Error pop-up with no value for Scale
        if (buttonIndex == 0) {  // Cancel Button
            [visualEffectView removeFromSuperview];
            [self scaleButtonTouchUpInside];
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
