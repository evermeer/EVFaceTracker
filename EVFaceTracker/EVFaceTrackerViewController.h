//
//  EVFaceTrackerViewController.h
//
//  Created by Edwin Vermeer on 3/13/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EVFaceTracker.h"

@class CIDetector;

@interface EVFaceTrackerViewController : UIViewController <EVFaceTrackerDelegate> {
    IBOutlet UIView *dynamicView;
    IBOutlet UILabel *dynamicLabel;
    EVFaceTracker *evFaceTracker;
    IBOutlet UIView *borderView;
}

@end
