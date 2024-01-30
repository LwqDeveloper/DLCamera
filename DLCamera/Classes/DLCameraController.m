//
//  DLCameraController.m
//  DLCamera
//
//  Created by Muyang on 2024/1/30.
//  Copyright © 2024 liweiqiong. All rights reserved.
//

#import "DLCameraController.h"

#import "DLCameraView.h"

#define kTopViewHeight 0
#define kBottomViewHeight (KBottomHeight + 100)

@interface DLCameraController ()

/// 屏幕宽度
@property (nonatomic, assign) CGFloat screenWidth;
/// 屏幕长度
@property (nonatomic, assign) CGFloat screenHeight;

/// top
@property (nonatomic, strong) UIView *topView;
/// bottom
@property (nonatomic, strong) UIView *bottomView;
/// 相机
@property (nonatomic, strong) DLCameraView *cameraView;
/// 裁剪框
@property (nonatomic, strong) UIImageView *cropView;
/// 取消
@property (nonatomic, strong) UIButton *cancleButton;
/// 拍摄按钮
@property (nonatomic, strong) UIButton *takeButton;
/// 翻转
@property (nonatomic, strong) UIButton *changeButton;
/// 返回
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation DLCameraController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat bottomSafeAreaHeight = self.screenHeight >= 812.0 ? 34.0: 0.0;
    
    if (!self.toolbarHeight) {
        self.toolbarHeight = @(bottomSafeAreaHeight +100);
    }
    
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
    [self.cameraView startCamera];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    
    [self.cameraView stopCamera];
}

- (void)setupUI {
    self.view.backgroundColor = UIColor.blackColor;
        
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.cameraView];
    
    self.takeButton.frame = CGRectMake(self.screenWidth /2 -32.5, 15, 65, 65);
    [self.bottomView addSubview:self.takeButton];
    
    float spaceX = (self.screenWidth -65.0) /4.0;
    self.cancleButton.frame = CGRectMake(spaceX -16, CGRectGetMidY(self.takeButton.frame) -16, 32, 32);
    [self.bottomView addSubview:self.cancleButton];

    self.changeButton.frame = CGRectMake(self.screenWidth -spaceX -16, CGRectGetMidY(self.takeButton.frame) -16, 32, 32);
    [self.bottomView addSubview:self.changeButton];
    
    if (self.isNeedBackButton) {
        CGFloat topSafeAreaHeight = self.screenHeight >= 812.0 ? 44.0: 20.0;
        self.backButton.frame = CGRectMake(10, topSafeAreaHeight, 44, 44);
        [self.view addSubview:self.backButton];
    }
}

#pragma mark - custom
- (void)cancleButtonTap {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)takeButtonTap {
    [self.cameraView takePhoto];
}

- (void)changeButtonTap {
    [self.cameraView changeCameraPosition:self.cameraView.isFrontCamera];
}

- (void)backToLaskVC {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        if (self.navigationController.presentingViewController) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (NSBundle *)getDLCameraBundle {
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    return bundle;
}

- (UIImage *)getImageFromName:(NSString *)name {
    NSString *bundleName = @"DLCamera.bundle";
    NSString *imagePath = [[self getDLCameraBundle] pathForResource:name ofType:@"png" inDirectory:bundleName];
    return [UIImage imageWithContentsOfFile:imagePath];
}

#pragma mark - getter
- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, 0)];
        _topView.backgroundColor = [UIColor blackColor];
    }
    return _topView;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.screenHeight -self.toolbarHeight.floatValue, self.screenWidth, self.toolbarHeight.floatValue)];
        _bottomView.backgroundColor = UIColor.blackColor;
    }
    return _bottomView;
}

- (DLCameraView *)cameraView {
    if (!_cameraView) {
        float cameraViewY = 0;
        float cameraViewH = self.screenHeight -self.toolbarHeight.floatValue;
        if (self.widthHeightRadio) {
            cameraViewH = self.screenWidth /self.widthHeightRadio.floatValue;
            cameraViewY = (self.screenHeight -cameraViewH -self.toolbarHeight.floatValue) /2;
        }
        _cameraView = [[DLCameraView alloc] initWithFrame:CGRectMake(0, cameraViewY, self.screenWidth, cameraViewH) withPositionDevice:YES];
        
        __weak typeof(self) weakSelf = self;
        [_cameraView setResultHandler:^(UIImage * _Nullable image) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf.takePhotoHandler && image) {
                strongSelf.takePhotoHandler(image);
            }
            [strongSelf backToLaskVC];
        }];
    }
    return _cameraView;
}

- (UIImageView *)cropView {
    if (!_cropView) {
        _cropView = [[UIImageView alloc] init];
        _cropView.layer.borderColor = [UIColor whiteColor].CGColor;
        _cropView.layer.borderWidth = 2;
    }
    return _cropView;
}

- (UIButton *)cancleButton {
    if (!_cancleButton) {
        _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancleButton setImage:[self getImageFromName:@"icon_camera_cancle"] forState:UIControlStateNormal];
        _cancleButton.imageEdgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
        [_cancleButton addTarget:self action:@selector(cancleButtonTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleButton;
}

- (UIButton *)takeButton {
    if (!_takeButton) {
        _takeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_takeButton setImage:[self getImageFromName:@"icon_camera_take"] forState:UIControlStateNormal];
        [_takeButton addTarget:self action:@selector(takeButtonTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _takeButton;
}

- (UIButton *)changeButton {
    if (!_changeButton) {
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_changeButton setImage:[self getImageFromName:@"icon_camera_change"] forState:UIControlStateNormal];
        _changeButton.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4);
        [_changeButton addTarget:self action:@selector(changeButtonTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeButton;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[self getImageFromName:@"icon_back_white"] forState:UIControlStateNormal];
        _backButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [_backButton addTarget:self action:@selector(backToLaskVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

@end
