// 
//  canvas.m
//  CameraLaunch
//
//  Created by Bharadhwaj on 23/06/15.
//

#import "canvas.h"
#import<QuartzCore/QuartzCore.h>

@implementation canvas

- (id)initWithFrame:(CGRect)frame withStartX: (float)xs withStartY: (float)ys withEndX: (float)xe withEndY: (float)ye withdist: (float)ds {
    
    xStart = xs;
    yStart = ys;
    xEnd = xe;
    yEnd = ye;
    dist = ds;
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    int labelstartx,labelstarty;
    float slopeangle = atan2f((yEnd-yStart),(xEnd-xStart));
    
    int distance= sqrtf(powf((yEnd-yStart),2) + powf((xEnd-xStart),2));
    
    labelstartx = (xStart+xEnd)/2 - distance/2;
    labelstarty = (yStart+yEnd)/2 - 20;
    if(distance > 10) {
       
        NSString *measurestring = [NSString stringWithFormat:@"%d\n", dist];
        UILabel *measure;
        
        measure = [[UILabel alloc]initWithFrame:CGRectMake(labelstartx, labelstarty, distance, 40)];
        
        [measure setBackgroundColor:[UIColor clearColor]];
        measure.text =measurestring;
        measure.textColor = [UIColor redColor];
        
        if(xStart>xEnd)
            measure.transform=CGAffineTransformMakeRotation(M_PI+slopeangle);
        else
            measure.transform = CGAffineTransformMakeRotation(slopeangle);
        
        measure.textAlignment = NSTextAlignmentCenter;
        measure.numberOfLines = 0;
        [measure sizeToFit];
        [self addSubview:measure];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0f);
    
    CGContextMoveToPoint(context, xStart, yStart); //start at this point
    
    CGContextAddLineToPoint(context, xEnd, yEnd); //draw to this point
    
    
    // and now draw the Path!
    CGContextStrokePath(context);
}

@end
