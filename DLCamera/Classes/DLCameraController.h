//
//  DLCameraController.h
//  DLCamera
//
//  Created by Muyang on 2024/1/30.
//  Copyright © 2024 liweiqiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DLCameraController : UIViewController

/// 宽高比
@property (nonatomic, strong) NSNumber *widthHeightRadio;
/// 底部区域高度
@property (nonatomic, strong) NSNumber *toolbarHeight;
/// 是否需要返回按钮
@property (nonatomic, assign) BOOL isNeedBackButton;
/// 拍照结果回调
@property (nonatomic, copy) void(^takePhotoHandler)(UIImage *image);

@end

NS_ASSUME_NONNULL_END
