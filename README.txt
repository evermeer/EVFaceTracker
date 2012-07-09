Implementing face tracking Earlier this month I had a discussion with a colleague about new forms of user interaction. On mobile devices there are now many applications that are using the compass and or accelerator. On a game consoles it’s very common to use a camera to interact with a game (Xbox Kinect and Playstation move) I thought it would be nice if we could use the front facing camera of a phone for interacting with an app. I had to see if this idea could be implemented.

Since iOS 5 Apple has added a face detection api. My idea was to detect a face and estimate the distance the device is from your face based on the size of the detected face. If the rectangle of the detected face is big, then the device is close to your face, if it’s small, then the device is far away from your face. With a similar technique it is also possible to calculate the angle of the device in relation to the face. This angle is calculated based on how fare the detected face rectangle is away from the center of the screen.

The challenge here was to hook into the video stream and detect the face for each frame. Fortunately Apple has a sample project for this called SquareCam. With the code from that project it’s possible to detect faces in about 5 frames per second (on an iPhone 4S)

There are a couple of fun things that you could do with face tracking:

Change the zoom level based on the distance.
Change the shadow offset based on the angle
?
For implementing face detection in your own application I created a class that can easily be added plus a demo project that changes the zoom level and shadow offset for a text. The only thing you have to do in your application is to add the EVFaceTracker class and listen to a deligate message so that you can react on the rectangle of the detected face.