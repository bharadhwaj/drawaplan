//
//  NoButton.m
//  CameraLaunch
//
//  Created by Divya V on 29/04/15.
//  Copyright (c) 2015 QBurst. All rights reserved.
//


#import "NoButton.h"

@implementation NoButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        // Set button image for Height:
        UIImageView *buttonImageNo = [[UIImageView alloc] initWithFrame:CGRectMake(70, 180, 30, 70)];
        buttonImageNo.image = [UIImage imageNamed:@"no.png"];
        [self addSubview:buttonImageNo];
        
    }
    return self;
}


@end
