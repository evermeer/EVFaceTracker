//
//  EVFaceTrackerViewController.m
//
//  Created by Edwin Vermeer on 3/13/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "EVFaceTrackerViewController.h"


@implementation EVFaceTrackerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Start tracking your face.
    evFaceTracker = [[EVFaceTracker alloc] initWithDelegate:self];
    // And give us a smooth update 20 times per second.
    [evFaceTracker fluidUpdateInterval:0.05f withReactionFactor:0.3f];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - <EVFaceTrackerDelegate>
// This delegate method is called every time the face recognition has detected something (including change)
- (void)faceIsTracked:(CGRect)faceRect withOffsetWidth:(float)offsetWidth andOffsetHeight:(float)offsetHeight andDistance:(float) distance {
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.2];
    CALayer *layer = dynamicLabel.layer;
    layer.masksToBounds = NO;
    layer.shadowOffset = CGSizeMake(offsetWidth / 5.0f, offsetHeight / 10.0f);
    layer.shadowRadius = 5;
    layer.shadowOpacity = 0.5;
    [CATransaction commit];
}

// When the fluidUpdateInterval method is called, then this delegate method will be called on a regular interval
- (void)fluentUpdateDistance:(float)distance {
    // Animate to the zoom level.
    float effectiveScale = distance / 60.0f;
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.1f];
    [dynamicView.layer setAffineTransform:CGAffineTransformMakeScale(effectiveScale, effectiveScale)];
    [CATransaction commit];
}

@end
