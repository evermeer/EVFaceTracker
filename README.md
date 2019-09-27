
# EVFaceTracker

TL;DR: Use face detection for calculating distance and angle of your phone.

[![Build Status](https://travis-ci.org/evermeer/EVFaceTracker.svg?style=flat)](https://travis-ci.org/evermeer/EVFaceTracker)
[![Issues](https://img.shields.io/github/issues-raw/evermeer/EVFaceTracker.svg?style=flat)](https://github.com/evermeer/EVFaceTracker/issues)
[![Stars](https://img.shields.io/github/stars/evermeer/EVFaceTracker.svg?style=flat)](https://github.com/evermeer/EVFaceTracker/stargazers)
[![Version](https://img.shields.io/cocoapods/v/EVFaceTracker.svg?style=flat)](http://cocoadocs.org/docsets/EVFaceTracker)
[![License](https://img.shields.io/cocoapods/l/EVFaceTracker.svg?style=flat)](http://cocoadocs.org/docsets/EVFaceTracker)
[![Platform](https://img.shields.io/cocoapods/p/EVFaceTracker.svg?style=flat)](http://cocoadocs.org/docsets/EVFaceTracker)
[![Documentation](https://img.shields.io/badge/documented-100%-brightgreen.svg?style=flat)](http://cocoadocs.org/docsets/EVFaceTracker)

[![Git](https://img.shields.io/badge/GitHub-evermeer-blue.svg?style=flat)](https://github.com/evermeer)
[![Twitter](https://img.shields.io/badge/twitter-@evermeer-blue.svg?style=flat)](http://twitter.com/evermeer)
[![LinkedIn](https://img.shields.io/badge/linkedin-Edwin%20Vermeer-blue.svg?style=flat)](http://nl.linkedin.com/in/evermeer/en)
[![Website](https://img.shields.io/badge/website-evict.nl-blue.svg?style=flat)](http://evict.nl)
[![eMail](https://img.shields.io/badge/email-edwin@evict.nl-blue.svg?style=flat)](mailto:edwin@evict.nl?SUBJECT=About%20EVFaceTracker)

Here is a demo where this is used for setting the shadow and size of a text.

![Screenshot0](https://github.com/evermeer/EVFaceTracker/blob/master/EVFaceTracker.gif?raw=true)

For a longer demo see: https://www.youtube.com/watch?v=yLAtc7AzjIk


## Introduction
Earlier this month I had a discussion with a colleague about new forms of user interaction. On mobile devices there are now many applications that are using the compass and or accelerator. On a game consoles it’s very common to use a camera to interact with a game (Xbox Kinect and Playstation move) I thought it would be nice if we could use the front facing camera of a phone for interacting with an app. I had to see if this idea could be implemented.

Since iOS 5 Apple has added a face detection api. My idea was to detect a face and estimate the distance the device is from your face based on the size of the detected face. If the rectangle of the detected face is big, then the device is close to your face, if it’s small, then the device is far away from your face. With a similar technique it is also possible to calculate the angle of the device in relation to the face. This angle is calculated based on how fare the detected face rectangle is away from the center of the screen.

The challenge here was to hook into the video stream and detect the face for each frame. Fortunately Apple has a sample project for this called SquareCam. With the code from that project it’s possible to detect faces in about 5 frames per second (on an iPhone 4S)

There are a couple of fun things that you could do with face tracking:

- Change the zoom level based on the distance.
- Change the shadow offset based on the angle
- ?


## Using EVFaceTracker in your own App 

'EVFaceTracker' is now available through the dependency manager [CocoaPods](http://cocoapods.org). 
You can install cocoapods by executing:

```
[sudo] gem install cocoapods
```

If you have installed cocoapods, then you can just add EVFaceTracker to your workspace by adding the following line to your Podfile:

```
pod "EVFaceTracker"
```

You can also just copy EVFaceTracker.m and .h to your project. 


## The demo code:

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Start tracking your face.
    evFaceTracker = [[EVFaceTracker alloc] initWithDelegate:self];
    // And give us a smooth update 10 times per second.
    [evFaceTracker fluidUpdateInterval:0.1f withReactionFactor:0.5f];
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
```

## License

EVFaceTracker is available under the MIT 3 license. See the LICENSE file for more info.

## My other libraries:
Also see my other open source iOS libraries:

- [EVReflection](https://github.com/evermeer/EVReflection) - Reflection based (Dictionary, CKRecord, JSON and XML) object mapping with extensions for Alamofire and Moya with RxSwift or ReactiveSwift 
- [EVCloudKitDao](https://github.com/evermeer/EVCloudKitDao) - Simplified access to Apple's CloudKit
- [EVFaceTracker](https://github.com/evermeer/EVFaceTracker) - Calculate the distance and angle of your device with regards to your face in order to simulate a 3D effect
- [EVURLCache](https://github.com/evermeer/EVURLCache) - a NSURLCache subclass for handling all web requests that use NSURLReques
- [AlamofireOauth2](https://github.com/evermeer/AlamofireOauth2) - A swift implementation of OAuth2 using Alamofire
- [EVWordPressAPI](https://github.com/evermeer/EVWordPressAPI) - Swift Implementation of the WordPress (Jetpack) API using AlamofireOauth2, AlomofireJsonToObjects and EVReflection (work in progress)
- [PassportScanner](https://github.com/evermeer/PassportScanner) - Scan the MRZ code of a passport and extract the firstname, lastname, passport number, nationality, date of birth, expiration date and personal numer.
- [AttributedTextView](https://github.com/evermeer/AttributedTextView) - Easiest way to create an attributed UITextView with support for multiple links (url, hashtags, mentions).

