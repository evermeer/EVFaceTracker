//
//  EVFaceTracker.h
//
//  Created by Edwin Vermeer on 3/13/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol EVFaceTrackerDelegate <NSObject>
- (void)faceIsTracked:(CGRect)faceRect withOffsetWidth:(float)offsetWidth andOffsetHeight:(float)offsetHeight andDistance:(float) distance;
- (void)fluentUpdateDistance:(float)distance;
@end


@interface EVFaceTracker : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoDataOutput *videoDataOutput;
    AVCaptureVideoPreviewLayer *previewLayer;
    dispatch_queue_t videoDataOutputQueue;
    CIDetector *faceDetector;
    CGRect faceRect;
    float reactionFactor;
    float distance;
    float previousDistance;
    float updateInterval;
}

@property (nonatomic, unsafe_unretained, readwrite) id <EVFaceTrackerDelegate> delegate;
@property (nonatomic, assign, readwrite) CGRect faceRect;
@property (nonatomic, assign, readwrite) float reactionFactor;
@property (nonatomic, assign, readwrite) float updateInterval;

- (id)initWithDelegate:(id)theDelegate;
- (void)fluidUpdateInterval:(float)interval withReactionFactor:(float) factor;

@end
