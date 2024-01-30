//
//  DLViewController.m
//  DLCamera
//
//  Created by liweiqiong on 01/30/2024.
//  Copyright (c) 2024 liweiqiong. All rights reserved.
//

#import "DLViewController.h"
#import "DLCamera/DLCameraController.h"

@interface DLViewController ()

@end

@implementation DLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)pushAction:(id)sender {
    DLCameraController *vc = [DLCameraController new];
    [vc setTakePhotoHandler:^(UIImage * _Nonnull image) {
        NSLog(@"result:%@", NSStringFromCGSize(image.size));
    }];
    vc.widthHeightRadio = @1;
    vc.isNeedBackButton = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)presentAction:(id)sender {
    DLCameraController *vc = [DLCameraController new];
    [vc setTakePhotoHandler:^(UIImage * _Nonnull image) {
        NSLog(@"result:%@", NSStringFromCGSize(image.size));
    }];
    vc.isNeedBackButton = YES;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
