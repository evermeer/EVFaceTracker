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

/**
The delegate that will be set for the EVFaceTrackerDelegate events.
*/
@property (nonatomic, unsafe_unretained, readwrite) id <EVFaceTrackerDelegate> delegate;

/**
The last recogniced face position and size
 */
@property (nonatomic, assign, readwrite) CGRect faceRect;

/**
Variable that will set the speed how fast an animation must go when using fluentUpdateDistance (should be between 0 and 1)
 */
@property (nonatomic, assign, readwrite) float reactionFactor;

/**
How fast (in seconds) you will get events when useing fluentUpdate. The lower the better. If set to low you can get a performance impact. Set this to 0.05 for 20 frames per second
*/
@property (nonatomic, assign, readwrite) float updateInterval;

/**
 Initiate EVFaceTracker with the delegate that will be receiving the EVFaceTrackerDelegate events
 
 :param: theDelegate The class that conforms to EVFaceTrackerDelegate for receiving the callbacks
 */
- (id)initWithDelegate:(id)theDelegate;
/**
Face detection sometimes is not fast enought (especially on older devices) You can specify that you still want an update more often where the distance varialbe will gradually move from the previous position to the newly detected position. If this method is called then your delegate will also receive fluentUpdateDistance events.
 
 :param: interval
 */
- (void)fluidUpdateInterval:(float)interval withReactionFactor:(float) factor;

@end
