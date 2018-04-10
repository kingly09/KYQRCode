//  KYQRCode
//
//
//  Created by kingly on 2018/4/10.
//  Copyright © 2018年 KYQRCode Software https://github.com/kingly09/KYQRCode  by kingly inc.

//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE. All rights reserved.
//


#import "KYQRCodeAlbumManager.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "UIImage+SGImageSize.h"

#ifdef DEBUG
#define KYQRCodeLog(...) NSLog(__VA_ARGS__)
#else
#define KYQRCodeLog(...)
#endif

@interface KYQRCodeAlbumManager () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic, strong) NSString *detectorString;
@end

@implementation KYQRCodeAlbumManager

+ (instancetype)sharedManager {
    static KYQRCodeAlbumManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KYQRCodeAlbumManager alloc] init];
    });
    return manager;
}

- (void)initialization {
    _isOpenLog = YES;
}

- (void)readQRCodeFromAlbumWithCurrentController:(UIViewController *)currentController {
    [self initialization];
    self.currentVC = currentController;
    
    if (currentController == nil) {
        @throw [NSException exceptionWithName:@"KYQRCode" reason:@"readQRCodeFromAlbumWithCurrentController: 方法中的 currentController 参数不能为空" userInfo:nil];
    }
    
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        // 判断授权状态
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) { // 用户还没有做出选择
            // 弹框请求用户授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) { // 用户第一次同意了访问相册权限
                    self.isPHAuthorization = YES;
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self enterImagePickerController];
                    });
                    if (self.isOpenLog) {
                        KYQRCodeLog(@"用户第一次同意了访问相册权限 - - %@", [NSThread currentThread]);
                    }
                } else { // 用户第一次拒绝了访问相机权限
                    if (self.isOpenLog) {
                        KYQRCodeLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
                    }
                }
            }];
            
        } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许当前应用访问相册
            self.isPHAuthorization = YES;
            if (self.isOpenLog) {
                KYQRCodeLog(@"访问相机权限 - - %@", [NSThread currentThread]);
            }
            [self enterImagePickerController];
        } else if (status == PHAuthorizationStatusDenied) { // 用户拒绝当前应用访问相册
            [self enterImagePickerController];
        } else if (status == PHAuthorizationStatusRestricted) {
            UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"由于系统原因, 无法访问相册" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [alertC addAction:alertA];
            [self.currentVC presentViewController:alertC animated:YES completion:nil];
        }
    }
}

// 进入 UIImagePickerController
- (void)enterImagePickerController {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self.currentVC presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - - - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.currentVC dismissViewControllerAnimated:YES completion:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(QRCodeAlbumManagerDidCancelWithImagePickerController:)]) {
        [self.delegate QRCodeAlbumManagerDidCancelWithImagePickerController:self];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // 对选取照片的处理，如果选取的图片尺寸过大，则压缩选取图片，否则不作处理
    UIImage *image = [UIImage SG_imageSizeWithScreenImage:info[UIImagePickerControllerOriginalImage]];
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    // 声明一个 CIDetector，并设定识别类型 CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];
    
    // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    if (features.count == 0) {
        if (self.isOpenLog) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(QRCodeAlbumManagerDidReadQRCodeFailure:)]) {
                [self.delegate QRCodeAlbumManagerDidReadQRCodeFailure:self];
            }
        }
        [self.currentVC dismissViewControllerAnimated:YES completion:nil];
        return;
        
    } else {
        for (int index = 0; index < [features count]; index ++) {
            CIQRCodeFeature *feature = [features objectAtIndex:index];
            NSString *resultStr = feature.messageString;
            if (self.isOpenLog) {
                KYQRCodeLog(@"相册中读取二维码数据信息 - - %@", resultStr);
            }
            self.detectorString = resultStr;
        }
        [self.currentVC dismissViewControllerAnimated:YES completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(QRCodeAlbumManager:didFinishPickingMediaWithResult:)]) {
                [self.delegate QRCodeAlbumManager:self didFinishPickingMediaWithResult:self.detectorString];
            }
        }];
    }
}


#pragma mark - - - set
- (void)setIsOpenLog:(BOOL)isOpenLog {
    _isOpenLog = isOpenLog;
}


@end

