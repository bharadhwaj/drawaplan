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


typedef int OutCode;

const int INSIDE = 0; // 0000
const int LEFT = 1;   // 0001
const int RIGHT = 2;  // 0010
const int BOTTOM = 4; // 0100
const int TOP = 8;    // 1000

-(int) ComputeOutCode:(double)x andnum2:(double)y andNum3:(double)xmin andNum4:(double)ymin andNum5:(double)xmax andNum6:(double)ymax;
{
    OutCode code;
    
    code = INSIDE;          // initialised as being inside of clip window
    
    if (x < xmin)           // to the left of clip window
        code |= LEFT;
    else if (x > xmax)      // to the right of clip window
        code |= RIGHT;
    if (y < ymin)           // below the clip window
        code |= BOTTOM;
    else if (y > ymax)      // above the clip window
        code |= TOP;
    
    return code;
}



    - (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        
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
    
    // <--- Reading height from NSUserDefaults --->
    height = [[NSUserDefaults standardUserDefaults] stringForKey:@"Height"];
    heightInFloat = [height floatValue];
    
    // <--- Reading scale from NSUserDefaults --->
    scale = [[NSUserDefaults standardUserDefaults] stringForKey:@"Scale"];
    scaleInFloat = [scale floatValue];
    
    
    CGFloat cwidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat cheight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat xWmin, xWmax, yWmin, yWmax, xVmin, xVmax, yVmin, yVmax;
    CGFloat xVminBig, xVmaxBig, yVminBig, yVmaxBig;
    
    CGFloat sx, sy, tx, ty;
    CGFloat txBig, tyBig, sxbig, sybig;
    
    // <--- Translation and Scaling to map the point --->
    xWmin = 0;
    xWmax = cwidth;
    yWmin = 0;
    yWmax = cheight;
    
    xVmin = cwidth/2;
    xVmax = cwidth;
    yVmin = cheight/2;
    yVmax = cheight;
    
    xVminBig = 15;
    xVmaxBig = cwidth-10;
    yVminBig = 55;
    yVmaxBig = cheight-50;

    
    sx=(xVmax-xVmin)/(xWmax-xWmin);
    sy=(yVmax-yVmin)/(yWmax-yWmin);
    
    sxbig=(xVmaxBig-xVminBig)/(xWmax-xWmin);
    sybig=(yVmaxBig-yVminBig)/(yWmax-yWmin);
    
    tx = (xWmax*xVmin - xWmin*xVmax)/(xWmax - xWmin);
    ty = (yWmax*yVmin - yWmin*yVmax)/(yWmax - yWmin);
    
    txBig = (xWmax*xVminBig - xWmin*xVmaxBig)/(xWmax - xWmin);
    tyBig = (yWmax*yVminBig - yWmin*yVmaxBig)/(yWmax - yWmin);
    
    
    
    angleOne = rollAngle*180/M_PI;
    
    lengthOne = [self read];
    
    lengthList[count] = lengthOne;
    angleList[count] = angleOne;
    
    float angle = angleList[0];

    
    
    pointsList[count][0] =  -1 * sqrtf(2.0) * lengthOne * (pixel/scaleInFloat) * sinf((angleOne-angle)*M_PI/180)+(cwidth/2);
    if (pointsList[count][0] < 0) {
        pointsList[count][0] = -1 * pointsList[count][0];
    }
    
    pointsListBig[count][0] =  pointsList[count][0];
    pointsList[count][0] =  sx * pointsList[count][0] + cwidth/2 + 15;
    
    pointsList[count][1] = -1 * sqrtf(2.0) * lengthOne * (pixel/scaleInFloat) * cosf((angleOne-angle)*M_PI/180)+(cheight/2);
    if (pointsList[count][1] < 0) {
        pointsList[count][1] = -1 * pointsList[count][1];
    }
        pointsListBig[count][1] =   pointsList[count][1];
    pointsList[count][1] =  sy * pointsList[count][1] + cheight/2 + 45;
    NSLog(@"Sx: %f \n Sy: %f \n SxBig: %f \n SyBig: %f",sx,sy,sxbig,sybig);
    NSLog(@"Tx: %f \n Ty: %f \n TxBig: %f \n TyBig: %f",tx,ty,txBig,tyBig);
    NSLog(@"Point %d X: %f",count,pointsListBig[count][0]);
    NSLog(@"Point %d Y: %f",count,pointsListBig[count][1]);
    
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
            
            //NSLog(@"AngleTotal %d = %f",i,angleSweptList[i]);
            //NSLog(@"DistanceTotal %d = %f",i,distanceList[i]);
            
        }

        
        //cohen sutherlan algorithm
        
        int xmin=cwidth/2+15;
        int ymin=cheight/2+45;
        int xmax=cwidth-15;
        int ymax=cheight-55;
        
        int x0=pointsList[p][0];
        int y0=pointsList[p][1];
        int x1=pointsList[q][0];
        int y1=pointsList[q][1];
        [self ComputeOutCode:x0 andnum2:y0 andNum3:xmin andNum4:ymin andNum5:xmax andNum6:ymax];
        
        OutCode outcode0 = [self ComputeOutCode:x0 andnum2:y0 andNum3:xmin andNum4:ymin andNum5:xmax andNum6:ymax];
        OutCode outcode1 = [self ComputeOutCode:x1 andnum2:y1 andNum3:xmin andNum4:ymin andNum5:xmax andNum6:ymax];
        
        bool accept = false;
        
        while (true) {
            if (!(outcode0 | outcode1)) { // Bitwise OR is 0. Trivially accept and get out of loop
                accept = true;
                break;
            } else if (outcode0 & outcode1) { // Bitwise AND is not 0. Trivially reject and get out of loop
                break;
            } else {
                // failed both tests, so calculate the line segment to clip
                // from an outside point to an intersection with clip edge
                double x=0, y=0;
                
                // At least one endpoint is outside the clip rectangle; pick it.
                OutCode outcodeOut = outcode0 ? outcode0 : outcode1;
                
                // Now find the intersection point;
                // use formulas y = y0 + slope * (x - x0), x = x0 + (1 / slope) * (y - y0)
                if (outcodeOut & TOP) {           // point is above the clip rectangle
                    x = x0 + (x1 - x0) * (ymax - y0) / (y1 - y0);
                    y = ymax;
                } else if (outcodeOut & BOTTOM) { // point is below the clip rectangle
                    x = x0 + (x1 - x0) * (ymin - y0) / (y1 - y0);
                    y = ymin;
                } else if (outcodeOut & RIGHT) {  // point is to the right of clip rectangle
                    y = y0 + (y1 - y0) * (xmax - x0) / (x1 - x0);
                    x = xmax;
                } else if (outcodeOut & LEFT) {   // point is to the left of clip rectangle
                    y = y0 + (y1 - y0) * (xmin - x0) / (x1 - x0);
                    x = xmin;
                }
                
                // Now we move outside point to intersection point to clip
                // and get ready for next pass.
                if (outcodeOut == outcode0) {
                    x0 = x;
                    y0 = y;
                    outcode0 = [self ComputeOutCode:x0 andnum2:y0 andNum3:xmin andNum4:ymin andNum5:xmax andNum6:ymax];
                    
                } else {
                    x1 = x;
                    y1 = y;
                    outcode1 = [self ComputeOutCode:x1 andnum2:y1 andNum3:xmin andNum4:ymin andNum5:xmax andNum6:ymax];
                }
            }
        }
        if (accept) {
            // Following functions are left for implementation by user based on
            // their platform (OpenGL/graphics.h etc.)
            
            // LineSegment(x0, y0, x1, y1);
            CGFloat cwidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat cheight = [UIScreen mainScreen].bounds.size.height;
            NSLog(@"dist%f ",distanceList[count-1]);
            canv[count-1] = [[canvas alloc] initWithFrame:CGRectMake(0, 0, cwidth, cheight) withStartX: x0 withStartY: y0 withEndX: x1 withEndY: y1 withdist:distanceList[count-1]];
            [self addSubview:canv[count-1]];
            [canv[count-1] setNeedsDisplay];
            
        }

        
        //<--- Checking whether the point to draw is out of bound. --->
        /*if(pointsList[p][0] < cwidth/2+15 || pointsList[p][0] > cwidth - 15 || pointsList[p][1] > cheight - 55 || pointsList[p][1] < cheight/2 + 55 || pointsList[q][0] < cwidth/2 + 15 || pointsList[q][0] > cwidth - 15 || pointsList[q][1] > cheight - 55 || pointsList[q][1] < cheight/2 + 55) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot draw. Point out of drawing area." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            count--;
    
        }
        else {*/
         
            /* canv[count-1] = [[canvas alloc] initWithFrame:CGRectMake(0, 0, cwidth, cheight) withStartX: pointsList[p][0] withStartY: pointsList[p][1] withEndX: pointsList[q][0] withEndY: pointsList[q][1] withdist:distanceList[count-1]];
            [self addSubview:canv[count-1]];
            [canv[count-1] setNeedsDisplay];
        //}
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

- (void)endButtonTouchUpInside {
    
    
    CGFloat cwidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat cheight = [UIScreen mainScreen].bounds.size.height;
    
    // <--- For blurring the BG --->
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = [[UIScreen mainScreen] bounds];
    [self addSubview:visualEffectView];
    
    //<--- For Navigation bar at the top --->
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, cwidth, 40)];
    navBar.barTintColor = [UIColor colorWithRed:0.627 green:0.627 blue:0.627 alpha:1];
    [self addSubview:navBar];
    
    //<--- For Toolbar at the bottom --->
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, cheight-40, cwidth, 40)];
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
        
        
        // <--- Cohen-Sutherland algorithm --->
        
        int xmin = 15;
        int ymin = 55;
        int xmax = cwidth - 15;
        int ymax = cheight - 55;
        
        int x0 = pointsListBig[p][0];
        int y0 = pointsListBig[p][1];
        int x1 = pointsListBig[q][0];
        int y1 = pointsListBig[q][1];
        [self ComputeOutCode:x0 andnum2:y0 andNum3:xmin andNum4:ymin andNum5:xmax andNum6:ymax];
        
        OutCode outcode0 = [self ComputeOutCode:x0 andnum2:y0 andNum3:xmin andNum4:ymin andNum5:xmax andNum6:ymax];
        OutCode outcode1 = [self ComputeOutCode:x1 andnum2:y1 andNum3:xmin andNum4:ymin andNum5:xmax andNum6:ymax];
        
        bool accept = false;
        
        while (true) {
            if (!(outcode0 | outcode1)) { // Bitwise OR is 0. Trivially accept and get out of loop
                accept = true;
                break;
            } else if (outcode0 & outcode1) { // Bitwise AND is not 0. Trivially reject and get out of loop
                break;
            } else {
                // Failed both tests, so calculate the line segment to clip
                // From an outside point to an intersection with clip edge
                double x=0, y=0;
                
                // At least one endpoint is outside the clip rectangle; pick it.
                OutCode outcodeOut = outcode0 ? outcode0 : outcode1;
                
                // Now find the intersection point;
                // Use formulas y = y0 + slope * (x - x0), x = x0 + (1 / slope) * (y - y0)
                if (outcodeOut & TOP) {           // point is above the clip rectangle
                    x = x0 + (x1 - x0) * (ymax - y0) / (y1 - y0);
                    y = ymax;
                } else if (outcodeOut & BOTTOM) { // point is below the clip rectangle
                    x = x0 + (x1 - x0) * (ymin - y0) / (y1 - y0);
                    y = ymin;
                } else if (outcodeOut & RIGHT) {  // point is to the right of clip rectangle
                    y = y0 + (y1 - y0) * (xmax - x0) / (x1 - x0);
                    x = xmax;
                } else if (outcodeOut & LEFT) {   // point is to the left of clip rectangle
                    y = y0 + (y1 - y0) * (xmin - x0) / (x1 - x0);
                    x = xmin;
                }
                
                // Now we move outside point to intersection point to clip
                // and get ready for next pass.
                if (outcodeOut == outcode0) {
                    x0 = x;
                    y0 = y;
                    outcode0 = [self ComputeOutCode:x0 andnum2:y0 andNum3:xmin andNum4:ymin andNum5:xmax andNum6:ymax];
                    
                } else {
                    x1 = x;
                    y1 = y;
                    outcode1 = [self ComputeOutCode:x1 andnum2:y1 andNum3:xmin andNum4:ymin andNum5:xmax andNum6:ymax];
                }
            }
        }
        if (accept) {
            // Following functions are left for implementation by user based on
            // their platform (OpenGL/graphics.h etc.)
            
            // LineSegment(x0, y0, x1, y1);
            CGFloat cwidth = [UIScreen mainScreen].bounds.size.width;
            CGFloat cheight = [UIScreen mainScreen].bounds.size.height;
            NSLog(@"dist%f ",distanceList[count-1]);
            canvbig[p] = [[canvas alloc] initWithFrame:CGRectMake(0, 0, cwidth, cheight) withStartX: x0 withStartY: y0 withEndX: x1 withEndY: y1 withdist:distanceList[p]];
            [self addSubview:canvbig[p]];
            [canvbig[p] setNeedsDisplay];
            
        }

        
        
        
        
        
        
        
        // <--- Adding new big canvas --->
       /* canvbig[p] = [[canvas alloc] initWithFrame:CGRectMake(0, 0, cwidth, cheight) withStartX: pointsListBig[p][0] withStartY: pointsListBig[p][1] withEndX: pointsListBig[q][0] withEndY: pointsListBig[q][1] withdist: distanceList[p]];
        [self addSubview:canvbig[p]];
        [canvbig[p] setNeedsDisplay];*/
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
    
    count = -1;

}

- (void)closeButtonTouchUpInside {
    
    [self addSubview:heightButton];
    [self addSubview:scaleButton];
    [canvasViewbgBig removeFromSuperview];
    [canvasViewBig removeFromSuperview];
    [visualEffectView removeFromSuperview];
    [closeButton removeFromSuperview];
    
    // <--- For removing large canvas --->
    for(int i = 0; i < loop; i++) {
        [canvbig[i] removeFromSuperview];
    }
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

- (void)scaleButtonTouchUpInside {
    
    // <--- For blurring the BG --->
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = [[UIScreen mainScreen] bounds];
    [self addSubview:visualEffectView];
    
    
    // <--- Pop-up view asking height --->
    UIAlertView *scalePopUp = [[UIAlertView alloc]initWithTitle:@"Scale Information" message:@"Please enter scale" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    scalePopUp.tag = 300;
    [scalePopUp textFieldAtIndex:0].delegate = self;
    scalePopUp.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[scalePopUp textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDecimalPad];
    [[scalePopUp textFieldAtIndex:0] becomeFirstResponder];
    [scalePopUp show];
    
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
