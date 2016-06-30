//
//  canvas.h
//  CameraLaunch
//
//  Created by Bharadhwaj on 23/06/15.
//

#import <UIKit/UIKit.h>
#import<QuartzCore/QuartzCore.h>


@interface canvas : UIView <UITextFieldDelegate> {
    
    float xStart;
    float yStart;
    float xEnd;
    float yEnd;
    int dist;
    
}

- (id)initWithFrame:(CGRect)frame withStartX: (float)xs withStartY: (float)ys withEndX: (float)xe withEndY: (float)ye withdist: (float)ds;

@end
