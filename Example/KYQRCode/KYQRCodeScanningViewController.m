//
//  KYQRCodeScanningViewController.m
//  KYQRCode_Example
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

#import "KYQRCodeScanningViewController.h"
#import <KYQRCode/KYQRCode.h>

@interface KYQRCodeScanningViewController ()<KYQRCodeScanManagerDelegate, KYQRCodeAlbumManagerDelegate>

@property (nonatomic, strong) KYQRCodeScanManager *manager;
@property (nonatomic, strong) KYQRCodeScanningView *scanningView;
@property (nonatomic, strong) UILabel *promptLabel;

@end

@implementation KYQRCodeScanningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  self.view.backgroundColor = [UIColor blackColor];
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  [self.view addSubview:self.scanningView];
  [self setupNavigationBar];

  [self.view addSubview:self.promptLabel];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  //不延时，可能会导致界面黑屏并卡住一会
  [self performSelector:@selector(startScan) withObject:nil afterDelay:0.05];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.scanningView removeTimer];
  
  
}

- (void)dealloc {
  NSLog(@"KYQRCodeScanningViewController - dealloc");
  [self removeScanningView];
}

#pragma mark - 私有方法
- (void)setupNavigationBar {
  self.navigationItem.title = @"扫一扫";
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItenAction)];
}


- (void)setupQRCodeScanning {
  
  self.manager = [KYQRCodeScanManager sharedManager];

  NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
  // AVCaptureSessionPreset1920x1080 推荐使用，对于小型的二维码读取率较高
  [_manager setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:arr currentController:self];
  [_manager cancelSampleBufferDelegate];
  _manager.delegate = self;
  
  
}

- (void)rightBarButtonItenAction {
  
  KYQRCodeAlbumManager *manager = [KYQRCodeAlbumManager sharedManager];
  [manager readQRCodeFromAlbumWithCurrentController:self];
  manager.delegate = self;
  
  if (manager.isPHAuthorization == YES) {
    [self.scanningView removeTimer];
  }
}

- (void)removeScanningView {
  [self.scanningView removeTimer];
  [self.scanningView removeFromSuperview];
  self.scanningView = nil;

  [_manager cancelSampleBufferDelegate];
  _manager = nil;
  
}

/**
 开始扫描二维码
 */
- (void) startScan {
  
  [self setupQRCodeScanning];
  
  [self.scanningView addTimer];
  [_manager startRunning];
  
  [self.scanningView stopDeviceReadying];
  
}


#pragma mark - - - KYQRCodeAlbumManagerDelegate

- (void)QRCodeAlbumManagerDidCancelWithImagePickerController:(KYQRCodeAlbumManager *)albumManager {
  [self.view addSubview:self.scanningView];

}

- (void)QRCodeAlbumManager:(KYQRCodeAlbumManager *)albumManager didFinishPickingMediaWithResult:(NSString *)result {
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                  message:[NSString stringWithFormat:@"结果：%@",result]
                                                 delegate:self
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil,nil];
  [alert show];
  
}

- (void)QRCodeAlbumManagerDidReadQRCodeFailure:(KYQRCodeAlbumManager *)albumManager {
  NSLog(@"暂未识别出二维码");
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                  message:@"暂未识别出二维码"
                                                 delegate:self
                                        cancelButtonTitle:@"确定"
                                        otherButtonTitles:nil,nil];
  [alert show];
}


#pragma mark - KYQRCodeScanManagerDelegate

- (void)QRCodeScanManager:(KYQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects {
  NSLog(@"metadataObjects - - %@", metadataObjects);
  if (metadataObjects != nil && metadataObjects.count > 0) {
    
    NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:@"sound.caf" ofType:nil];
    [scanManager playSoundNameWithAudioFilePath:audioFilePath];
    [scanManager stopRunning];
    
    AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:[NSString stringWithFormat:@"结果：%@",[obj stringValue]]
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil,nil];
    [alert show];
    
    
  } else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:@"暂未识别出二维码"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil,nil];
    [alert show];
  }
  
}

#pragma mark - 懒加载
- (UILabel *)promptLabel {
  if (!_promptLabel) {
    _promptLabel = [[UILabel alloc] init];
    _promptLabel.backgroundColor = [UIColor clearColor];
    CGFloat promptLabelX = 0;
    CGFloat promptLabelY = 0.73 * self.view.frame.size.height;
    CGFloat promptLabelW = self.view.frame.size.width;
    CGFloat promptLabelH = 25;
    _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
    _promptLabel.textAlignment = NSTextAlignmentCenter;
    _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
    _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    _promptLabel.text = @"将二维码/条码放入框内, 即可自动扫描";
  }
  return _promptLabel;
}

- (KYQRCodeScanningView *)scanningView {
  if (!_scanningView) {
    _scanningView = [[KYQRCodeScanningView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    _scanningView.scanningAnimationStyle = ScanningAnimationStyleGrid;
    _scanningView.cornerColor = [UIColor orangeColor];
  }
  return _scanningView;
}


- (void)QRCodeScanVC:(UIViewController *)scanVC {
  AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  if (device) {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
      case AVAuthorizationStatusNotDetermined: {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
          if (granted) {
            dispatch_sync(dispatch_get_main_queue(), ^{
              [self.navigationController pushViewController:scanVC animated:YES];
            });
            NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
          } else {
            NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
          }
        }];
        break;
      }
      case AVAuthorizationStatusAuthorized: {
        [self.navigationController pushViewController:scanVC animated:YES];
        break;
      }
      case AVAuthorizationStatusDenied: {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
          
        }];
        
        [alertC addAction:alertA];
        [self presentViewController:alertC animated:YES completion:nil];
        break;
      }
      case AVAuthorizationStatusRestricted: {
        NSLog(@"因为系统原因, 无法访问相册");
        break;
      }
        
      default:
        break;
    }
    return;
  }
  
  UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
  UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    
  }];
  
  [alertC addAction:alertA];
  [self presentViewController:alertC animated:YES completion:nil];
}


@end
