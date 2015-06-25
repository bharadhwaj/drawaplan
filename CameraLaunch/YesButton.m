//
//  YesButton.m
//  CameraLaunch
//
//  Created by Bharadhwaj on 05/05/15.
//  Copyright (c) 2015 QBurst. All rights reserved.
//

#import "YesButton.h"

@implementation YesButton

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
        UIImageView *buttonImageYes = [[UIImageView alloc] initWithFrame:CGRectMake(70, 440, 30, 70)];
        buttonImageYes.image = [UIImage imageNamed:@"yes.png"];
        [self addSubview:buttonImageYes];
        
    }
    return self;
}

@end
