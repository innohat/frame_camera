//
//  CustomCameraViewController.m
//  CustomCamera
//
//  Created by Chris van Es on 24/02/2014.
//
//

#import "CustomCameraViewController.h"

#import <Cordova/CDV.h>
#import <AVFoundation/AVFoundation.h>

#import "UIImage+fixOrientation.h"

@implementation CustomCameraViewController {
    void(^_callback)(UIImage*);
    AVCaptureSession *_captureSession;
    AVCaptureDevice *_rearCamera;
    AVCaptureStillImageOutput *_stillImageOutput;
    UIButton *_captureButton;
    UIImageView *_topOverlay;
    UIImageView *_bottomOverlay;
    UIImageView *_frameImage;
    UIImage *_frame;
    NSString *_frameURL;
    UIActivityIndicatorView *_activityIndicator;
}

static const CGFloat kCaptureButtonWidthPhone = 50;
static const CGFloat kCaptureButtonHeightPhone = 50;

static const CGFloat kCaptureButtonWidthTablet = 75;
static const CGFloat kCaptureButtonHeightTablet = 75;

- (id)initWithFrame:(NSString*)frame callback:(void(^)(UIImage*))callback {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _callback = callback;
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
        _frameURL = frame;
    }
    return self;
}

- (void)dealloc {
    [_captureSession stopRunning];
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor blackColor];
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.view.bounds;
    [[self.view layer] addSublayer:previewLayer];
    [self.view addSubview:[self createOverlay]];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self layoutOverlayForTablet];
    } else {
        [self layoutOverlayForPhone];
    }
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityIndicator.center = self.view.center;
    [self.view addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
}

- (UIView*)createOverlay {
    UIView *overlay = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    _frameImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"www/img/cameraoverlay/overlay-default.png"]];
    [overlay addSubview:_frameImage];

    _topOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"www/img/cameraoverlay/overlay-top.png"]];
    [overlay addSubview:_topOverlay];

    _bottomOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"www/img/cameraoverlay/overlay-bottom.png"]];
    [overlay addSubview:_bottomOverlay];

    _captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_captureButton setImage:[UIImage imageNamed:@"www/img/cameraoverlay/capture_button.png"] forState:UIControlStateNormal];
    [_captureButton setImage:[UIImage imageNamed:@"www/img/cameraoverlay/capture_button_pressed.png"] forState:UIControlStateHighlighted];
    [_captureButton addTarget:self action:@selector(takePictureWaitingForCameraToFocus) forControlEvents:UIControlEventTouchUpInside];
    [overlay addSubview:_captureButton];

    return overlay;
}

- (void)layoutOverlayForPhone {
    CGRect bounds = [[UIScreen mainScreen] bounds];

    _captureButton.frame = CGRectMake((bounds.size.width / 2) - (kCaptureButtonWidthPhone / 2),
                                      bounds.size.height - kCaptureButtonHeightPhone - 20,
                                      kCaptureButtonWidthPhone,
                                      kCaptureButtonHeightPhone);

    _frameImage.frame = CGRectMake(0, (bounds.size.height - bounds.size.width) / 2,
                                   bounds.size.width, bounds.size.width);

    _topOverlay.frame = CGRectMake(0, 0,
                                   bounds.size.width, (bounds.size.height - bounds.size.width) / 2);
    _bottomOverlay.frame = CGRectMake(0, (bounds.size.width + bounds.size.height) / 2 ,
                                      bounds.size.width, (bounds.size.height - bounds.size.width) / 2);
}

- (void)layoutOverlayForTablet {
    CGRect bounds = [[UIScreen mainScreen] bounds];

    _captureButton.frame = CGRectMake((bounds.size.width / 2) - (kCaptureButtonWidthTablet / 2),
                                      bounds.size.height - kCaptureButtonHeightTablet - 20,
                                      kCaptureButtonWidthTablet,
                                      kCaptureButtonHeightTablet);

}

- (void)viewDidLoad {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSURLRequest * frameRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:_frameURL]
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:60.0];
        NSURLResponse* response;
        NSError* error = nil;
        NSData* frameData = [NSURLConnection sendSynchronousRequest:frameRequest returningResponse:&response error:&error];
        
        _frame = [UIImage imageWithData: frameData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_frameImage setImage:_frame];
        });

        for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
            if ([device hasMediaType:AVMediaTypeVideo] && [device position] == AVCaptureDevicePositionBack) {
                _rearCamera = device;
            }
        }
        AVCaptureDeviceInput *cameraInput = [AVCaptureDeviceInput deviceInputWithDevice:_rearCamera error:nil];
        [_captureSession addInput:cameraInput];
        _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        [_captureSession addOutput:_stillImageOutput];
        [_captureSession startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_activityIndicator stopAnimating];
        });
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return orientation == UIDeviceOrientationPortrait;
}

- (void)takePictureWaitingForCameraToFocus {
    if (_rearCamera.adjustingFocus) {
        [_rearCamera addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
    } else {
        [self takePicture];
    }
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if ([keyPath isEqualToString:@"adjustingFocus"] && !_rearCamera.adjustingFocus) {
        [_rearCamera removeObserver:self forKeyPath:@"adjustingFocus"];
        [self takePicture];
    }
}

- (void)takePicture {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_activityIndicator startAnimating];
    });
    AVCaptureConnection *videoConnection = [self videoConnectionToOutput:_stillImageOutput];
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *rawImage = [[UIImage imageWithData:imageData] fixOrientation];
        _callback([UIImage squareImageFromImage:rawImage scaledToSize: 700.0]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [_activityIndicator stopAnimating];
        });
    }];
}

- (AVCaptureConnection*)videoConnectionToOutput:(AVCaptureOutput*)output {
    for (AVCaptureConnection *connection in output.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                return connection;
            }
        }
    }
    return nil;
}

@end
