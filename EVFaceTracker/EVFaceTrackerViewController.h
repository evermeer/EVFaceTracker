//
//  EVFaceTrackerViewController.h
//  EVFaceTracker 
//
//  Created by Edwin Vermeer on 3/13/12.
//  Copyright (c) 2012 EVICT B.V. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EVFaceTracker.h"

@class CIDetector;

@interface EVFaceTrackerViewController : UIViewController <EVFaceTrackerDelegate> {
    IBOutlet UIView *dynamicView;
    IBOutlet UILabel *dynamicLabel;
    EVFaceTracker *evFaceTracker;
    float distance;
    float previousDistance;
}

@end
