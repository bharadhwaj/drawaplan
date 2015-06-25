//
//  canvas.m
//  CameraLaunch
//
//  Created by Divya on 23/06/15.
//  Copyright (c) 2015 QBurst. All rights reserved.
//

#import "canvas.h"
#import<QuartzCore/QuartzCore.h>


@implementation canvas

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame withStartX: (float)xs withStartY: (float)ys withEndX: (float)xe withEndY: (float)ye{
    xStart = xs;
    yStart = ys;
    xEnd = xe;
    yEnd = ye;
    NSLog(@"xstart=%f",xStart);
    NSLog(@"ystart=%f",yStart);
    NSLog(@"xENd=%f",xEnd);
    NSLog(@"yEnd=%f",yEnd);
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor=[UIColor clearColor];
        // Initialization code
        NSLog(@"in init");
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    NSLog(@"in drawRect");
  
    
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
