//
//  EVFaceTrackerViewController.m
//  EVFaceTracker 
//
//  Created by Edwin Vermeer on 3/13/12.
//  Copyright (c) 2012 EVICT B.V. All rights reserved.
//

#import "EVFaceTrackerViewController.h"


@implementation EVFaceTrackerViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Start tracking your face.
    evFaceTracker = [[EVFaceTracker alloc] initWithDelegate:self];
    
    // Make sure the face distance is evaluated 10 times a second
    [self performSelector:@selector(setDistance) withObject:nil afterDelay:0.1f];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) setDistance {
    // The size of the recognized face does not change fluid. 
    // In order to still animate it fluient we do some calculations.
    float reactionFactor = 0.5f; // 0.1f is slow to new position, 1.0f is fast/instant to new position  
    previousDistance = (1.0f - reactionFactor) * previousDistance +  reactionFactor * distance;
    float effectiveScale = previousDistance / 60.0f; // calculate scale based on the distance

    // Animate to the zoom level.
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.1f];
    [dynamicView.layer setAffineTransform:CGAffineTransformMakeScale(effectiveScale, effectiveScale)];
    [CATransaction commit];

    // Make sure we do a recalculation 10 times every second in order to make sure we animate to the final position.
    [self performSelector:@selector(setDistance) withObject:nil afterDelay:0.1f];    
}

#pragma mark - <EVFaceTrackerDelegate>
// This delegate method is called every time the face recognition has detected something (including change)
-(void)faceIsTracked {
    // Calculate the distance of the face from the center
    float offsetWidth = (evFaceTracker.faceRect.origin.x - (160 - (evFaceTracker.faceRect.size.width / 2))) ;
    float offsetHeight = (evFaceTracker.faceRect.origin.y  - ( 240 -(evFaceTracker.faceRect.origin.y /2 )));

    // This is the current recongized distance. See the setDistance method for usages
    distance = (800.0f - (evFaceTracker.faceRect.size.width + evFaceTracker.faceRect.size.height)) / 10.0f;    

    // Set the shadow offset.
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.2];
    CALayer *layer = dynamicLabel.layer;
    layer.masksToBounds = NO;
    layer.shadowOffset = CGSizeMake(offsetWidth / 5.0f, offsetHeight / 10.0f);
    layer.shadowRadius = 5;
    layer.shadowOpacity = 0.5;
    [CATransaction commit];
}

@end
