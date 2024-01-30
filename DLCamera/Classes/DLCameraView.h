//
//  DLCameraView.h
//  DLCamera
//
//  Created by Muyang on 2024/1/30.
//  Copyright © 2024 liweiqiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DLCameraHandler)(UIImage * __nullable);


@interface DLCameraView : UIView

/// 摄像头
@property (nonatomic, assign, readonly) BOOL isFrontCamera;

/// 拍照回调
@property (nonatomic, copy) DLCameraHandler resultHandler;

/// 初始化相机+摄像头+回调
- (instancetype)initWithFrame:(CGRect)frame withPositionDevice:(BOOL)isBack;

/// 切换前置/后置摄像头
- (void)changeCameraPosition:(BOOL)isBack;

/// 拍照 -> takePhotoSuccess 取照片
- (void)takePhoto;

/// 开始拍照采集
- (void)startCamera;

/// 停止拍照采集
- (void)stopCamera;


@end

NS_ASSUME_NONNULL_END
