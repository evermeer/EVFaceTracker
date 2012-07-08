//
//  EVFaceTracker.m
//  EVFaceTracking 
//
//  Created by Edwin Vermeer on 3/13/12.
//  Copyright (c) 2012 EVICT B.V. All rights reserved.
//

#import "EVFaceTracker.h"
#import <AssertMacros.h>


enum {
    PHOTOS_EXIF_0ROW_TOP_0COL_LEFT = 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
    PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT = 2, //   2  =  0th row is at the top, and 0th column is on the right.
    PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
    PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
    PHOTOS_EXIF_0ROW_LEFT_0COL_TOP = 5, //   5  =  0th row is on the left, and 0th column is the top.
    PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP = 6, //   6  =  0th row is on the right, and 0th column is the top.
    PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
    PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
};

@interface EVFaceTracker (private)
- (BOOL)setupAVCapture;
- (void)calculateFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation;
+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize;
@end


@implementation EVFaceTracker

@synthesize delegate, faceRect;

- (id)initWithDelegate:(id)theDelegate {
    if ((self = [super init])) {
        self.delegate = theDelegate;
        if (![self setupAVCapture]) {
            return nil;
        };
    }
    return self;
}

- (void)dealloc {
    if (videoDataOutputQueue) {
        dispatch_release(videoDataOutputQueue);
    }
    [stillImageOutput removeObserver:self forKeyPath:@"isCapturingStillImage"];
    //    [previewLayer removeFromSuperlayer];

}


#pragma mark - <AVCaptureVideoDataOutputSampleBufferDelegate>

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // got an image
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *) attachments];
    if (attachments)
        CFRelease(attachments);
    NSDictionary *imageOptions = nil;
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
        
    int exifOrientation;
    switch (curDeviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            break;
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        default:
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
    }
    
    imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
    NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
    
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
    
    [self calculateFaceBoxesForFeatures:features forVideoBox:clap orientation:curDeviceOrientation];
}
@end


@implementation EVFaceTracker (private)

- (BOOL)setupAVCapture {
    NSError *error = nil;
    
    AVCaptureSession *session = [AVCaptureSession new];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [session setSessionPreset:AVCaptureSessionPreset640x480];
    } else {
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    [session setSessionPreset:AVCaptureSessionPreset352x288];
    
    // Select a video device, make an input
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if(error != nil) {
        if (error) {
            return FALSE;
        }
        return TRUE;
    }
        
    if ([session canAddInput:deviceInput]) {
        [session addInput:deviceInput];
    }
    
    // Make a still image output
    stillImageOutput = [AVCaptureStillImageOutput new];
    [stillImageOutput addObserver:self forKeyPath:@"capturingStillImage" options:NSKeyValueObservingOptionNew context:@"AVCaptureStillImageIsCapturingStillImageContext"];
    if ([session canAddOutput:stillImageOutput]) {
        [session addOutput:stillImageOutput];
    }
    
    // Make a video data output
    videoDataOutput = [AVCaptureVideoDataOutput new];
    
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
    NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id) kCVPixelBufferPixelFormatTypeKey];
    [videoDataOutput setVideoSettings:rgbOutputSettings];
    [videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
    videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
    
    if ([session canAddOutput:videoDataOutput])
        [session addOutput:videoDataOutput];
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    //    CALayer *rootLayer = [previewView layer];
    //    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:CGRectMake(0,0,320,480)];
    //    [rootLayer addSublayer:previewLayer];
    
    [session startRunning];
    
    // connect the front camara to the preview layer
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == AVCaptureDevicePositionFront) {
            [[previewLayer session] beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in [[previewLayer session] inputs]) {
                [[previewLayer session] removeInput:oldInput];
            }
            [[previewLayer session] addInput:input];
            [[previewLayer session] commitConfiguration];
            break;
        }
    }
    
    
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
    faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
    
    if (error) {
        return FALSE;
    }
    return TRUE;
}


// called asynchronously as the capture output is capturing sample buffers, this method asks the face detector (if on)
// to detect features and for each draw the red square in a layer and set appropriate orientation
- (void)calculateFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation {    
    
    CGSize parentFrameSize = [previewLayer frame].size;
    NSString *gravity = [previewLayer videoGravity];
    BOOL isMirrored = [previewLayer isMirrored];
    CGRect previewBox = [EVFaceTracker videoPreviewBoxForGravity:gravity frameSize:parentFrameSize apertureSize:clap.size];
    
    for (CIFaceFeature *ff in features) {
        // find the correct position for the square layer within the previewLayer
        // the feature box originates in the bottom left of the video frame.
        // (Bottom right if mirroring is turned on)
        faceRect = [ff bounds];
        
        // flip preview width and height
        CGFloat temp = faceRect.size.width;
        faceRect.size.width = faceRect.size.height;
        faceRect.size.height = temp;
        temp = faceRect.origin.x;
        faceRect.origin.x = faceRect.origin.y;
        faceRect.origin.y = temp;
        // scale coordinates so they fit in the preview box, which may be scaled
        CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
        CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
        faceRect.size.width *= widthScaleBy;
        faceRect.size.height *= heightScaleBy;
        faceRect.origin.x *= widthScaleBy;
        faceRect.origin.y *= heightScaleBy;
        
        if (isMirrored)
            faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
        else
            faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [delegate faceIsTracked];
        });
    }
    
    [CATransaction commit];
}


// find where the video box is positioned within the preview layer based on the video size and gravity
+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize {
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
    
    CGRect videoBox;
    videoBox.size = size;
    if (size.width < frameSize.width)
        videoBox.origin.x = (frameSize.width - size.width) / 2;
    else
        videoBox.origin.x = (size.width - frameSize.width) / 2;
    
    if (size.height < frameSize.height)
        videoBox.origin.y = (frameSize.height - size.height) / 2;
    else
        videoBox.origin.y = (size.height - frameSize.height) / 2;
    
    return videoBox;
}
@end
