//
//  EVFaceTracker.h
//  EVFaceTracker 
//
//  Created by Edwin Vermeer on 3/13/12.
//  Copyright (c) 2012 EVICT B.V. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol EVFaceTrackerDelegate <NSObject>
-(void)faceIsTracked;
@end 


@interface EVFaceTracker : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoDataOutput *videoDataOutput;
    AVCaptureVideoPreviewLayer *previewLayer;
    dispatch_queue_t videoDataOutputQueue;
    CIDetector *faceDetector;
    CGRect faceRect;
}

@property (nonatomic, unsafe_unretained, readwrite) id <EVFaceTrackerDelegate> delegate;
@property (nonatomic, assign, readwrite) CGRect faceRect;

- (id)initWithDelegate:(id)theDelegate;
@end
