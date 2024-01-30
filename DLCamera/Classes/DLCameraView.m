//
//  DLCameraView.m
//  DLCamera
//
//  Created by Muyang on 2024/1/30.
//  Copyright © 2024 liweiqiong. All rights reserved.
//

#import "DLCameraView.h"
#import <AVFoundation/AVFoundation.h>

#ifdef OS_OBJECT_USE_OBJC
    #define DISPATCH_QUEUE_REFERENCE_TYPE strong
#else
    #define DISPATCH_QUEUE_REFERENCE_TYPE assign
#endif

@interface DLCameraView () <AVCapturePhotoCaptureDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCapturePhotoOutput *imageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preview;
@property (nonatomic, strong) AVCapturePhotoSettings *outputSettings;
/// queue
@property (nonatomic, DISPATCH_QUEUE_REFERENCE_TYPE) dispatch_queue_t sessionQueue;
/// 摄像头
@property (nonatomic, assign, readwrite) BOOL isFrontCamera;

@end


@implementation DLCameraView

- (void)dealloc {
    [_session stopRunning];
    _session = nil;
    _input = nil;
    _device = nil;
    _imageOutput = nil;
}

/// 初始化相机+摄像头+回调
- (instancetype)initWithFrame:(CGRect)frame withPositionDevice:(BOOL)isBack {
    if (self = [super initWithFrame:frame]) {
        self.sessionQueue = dispatch_queue_create("custom_camera_queue", DISPATCH_QUEUE_SERIAL);
        [self initCameraInPosition:isBack];
    }
    return self;
}

/// 切换前置/后置摄像头
- (void)changeCameraPosition:(BOOL)isBack {
    [self initCameraInPosition:isBack];
}

- (void)initCameraInPosition:(BOOL)isBack {
    self.isFrontCamera = !isBack;

    [self stopCamera];
    
    self.session = [AVCaptureSession new];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if (isBack) {
        self.device = [self getCaptureDevicePosition:AVCaptureDevicePositionBack];
    } else {
        self.device = [self getCaptureDevicePosition:AVCaptureDevicePositionFront];
    }
    
    NSError *error;
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
    if (error) {
        NSLog(@"DLCameraView Device error:%@", error.description);
        return;
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    self.imageOutput = [[AVCapturePhotoOutput alloc] init];
    if (@available(iOS 11.0, *)) {
        NSDictionary *setDic = @{AVVideoCodecKey: AVVideoCodecTypeJPEG};
        self.outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
    } else {
        // Fallback on earlier versions
    }
    [self.imageOutput setPhotoSettingsForSceneMonitoring:self.outputSettings];
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
    self.preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.preview setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.layer addSublayer:self.preview];
    
    [self startCamera];
    [self fixFrontCameraMirored];
}

/// 开始拍照采集
- (void)startCamera {
    dispatch_async(self.sessionQueue, ^{
        if (self.session && !self.session.isRunning) {
            [self.session startRunning];
        }
    });
}

/// 停止拍照采集
- (void)stopCamera {
    dispatch_async(self.sessionQueue, ^{
        if (self.session && self.session.isRunning) {
            [self.session stopRunning];
        }
    });
}

- (AVCaptureDevice *)getCaptureDevicePosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position].devices;
    for (AVCaptureDevice *d in devices) {
        if (position == d.position) {
            return d;
        }
    }
    return nil;
}

- (void)fixFrontCameraMirored {
    for (AVCaptureVideoDataOutput *output in self.session.outputs) {
        for (AVCaptureConnection *av in output.connections) {
            if (self.isFrontCamera) {
                if (av.supportsVideoMirroring) {
                    av.videoMirrored = YES;
                }
            }
        }
    }
}

/// 拍照 -> takePhotoSuccess 取照片
- (void)takePhoto {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (self.imageOutput) {
            if (@available(iOS 11.0, *)) {
                NSDictionary *setDic = @{AVVideoCodecKey: AVVideoCodecTypeJPEG};
                AVCapturePhotoSettings *outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
                [self.imageOutput capturePhotoWithSettings:outputSettings delegate:self];
            } else {
                // Fallback on earlier versions
            }
            return;
        }
    }
    NSLog(@"DLCamera 当前设备不支持拍照");
}

#pragma mark AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error  API_AVAILABLE(ios(11.0)){
    if (error) {
        NSLog(@"DLCameraView captureOutput error:%@", error.description);
        return;
    }
    if (@available(iOS 11.0, *)) {
        NSData *data = [photo fileDataRepresentation];
        if (data && self.resultHandler) {
            self.resultHandler([UIImage imageWithData:data]);
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)startRunning {
    [_session startRunning];
}

- (void)stopRunning {
    [_session stopRunning];
}


@end
