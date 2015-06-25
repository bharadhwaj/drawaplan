//
//  button.m
//  CameraLaunch
//
//  Created by Divya V on 29/04/15.
//  Copyright (c) 2015 QBurst. All rights reserved.
//

#import "HeightButton.h"

@implementation HeightButton

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
        UIImageView *buttonImageHeight = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 48, 112)];
        buttonImageHeight.image = [UIImage imageNamed:@"button-3.png"];
        [self addSubview:buttonImageHeight];
        
    }
    return self;
}

@end
