
//
//  KYQRCodeScanningViewController
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
@property (nonatomic, strong) UIButton *flashlightBtn;
@property (nonatomic, strong) UILabel *promptLabel;
@property (nonatomic, assign) BOOL isSelectedFlashlightBtn;
@property (nonatomic, strong) UIView *bottomView;

@end

@implementation KYQRCodeScanningViewController

#pragma mark - 生命周期
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  [self setupUIView];
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self startScan];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.scanningView removeTimer];
  [self removeFlashlightBtn];
  [_manager cancelSampleBufferDelegate];
}

- (void)dealloc {
  NSLog(@"KYGridQRCodeScanningViewController - dealloc");
  [self removeScanningView];
}

#pragma mark - 初始化UI界面

- (void) setupUIView {
  
  self.view.backgroundColor = [UIColor blackColor];
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  [self.view addSubview:self.scanningView];
  [self setupNavigationBar];
  [self setupQRCodeScanning];
  
  [self.view addSubview:self.promptLabel];
  [self.view addSubview:self.bottomView];
  
  self.flashlightBtn.hidden = YES;
  [self.view addSubview:self.flashlightBtn];
  
}

- (void)setupNavigationBar {
  self.navigationItem.title = @"扫一扫";
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItenAction)];
}

- (void)setupQRCodeScanning {
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    self.manager = [KYQRCodeScanManager sharedManager];
    // AVCaptureSessionPreset1920x1080 推荐使用，对于小型的二维码读取率较高
    [_manager setupSessionPreset:AVCaptureSessionPreset1920x1080 metadataObjectTypes:nil currentController:self];
    _manager.delegate = self;
    
    // 自定义播放音频
    NSString *audioFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"/sound.caf"];
    _manager.currAudioFilePath = audioFilePath;
  });
}


- (void)rightBarButtonItenAction {
  KYQRCodeAlbumManager *manager = [KYQRCodeAlbumManager sharedManager];
  [manager readQRCodeFromAlbumWithCurrentController:self];
  manager.delegate = self;
  
  if (manager.isPHAuthorization == YES) {
    [self.scanningView removeTimer];
  }
}



#pragma mark  - KYQRCodeAlbumManagerDelegate
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

#pragma mark  - KYQRCodeScanManagerDelegate
/**
 启动扫描会话完成
 
 @param scanManager 二维码管理对象
 @param captureSession 会话
 @param captureDevice 摄像设备
 @param captureDeviceInput 摄像设备输入流
 @param captureVideoDataOutput 摄像数据输出流
 */
- (void)QRCodeScanManager:(KYQRCodeScanManager *)scanManager
     withAVCaptureSession:(AVCaptureSession *)captureSession
      withAVCaptureDevice:(AVCaptureDevice *)captureDevice
 withAVCaptureDeviceInput:(AVCaptureDeviceInput *)captureDeviceInput
withAVCaptureVideoDataOutput:(AVCaptureVideoDataOutput *)captureVideoDataOutput {
  
  
  [self.scanningView addTimer];
  [_manager resetSampleBufferDelegate];
  //停止loading
  [self.scanningView stopDeviceReadying];
}

/**
 二维码扫描获取数据的回调方法
 
 @param scanManager 二维码管理对象
 @param metadataObjects 扫描二维码数据信息
 */
- (void)QRCodeScanManager:(KYQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects {
  NSLog(@"metadataObjects - - %@", metadataObjects);
  if (metadataObjects != nil && metadataObjects.count > 0) {
    
    [scanManager stopRunning];
    [scanManager videoPreviewLayerRemoveFromSuperlayer];
    
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


/**
 根据光线强弱值打开手电筒的方法
 
 @param scanManager 二维码管理对象
 @param brightnessValue 光线强弱值
 */
- (void)QRCodeScanManager:(KYQRCodeScanManager *)scanManager brightnessValue:(CGFloat)brightnessValue {
  
  if (brightnessValue < - 1) {
    
    self.flashlightBtn.hidden = NO;
    [self.view addSubview:self.flashlightBtn];
    
  } else {
    if (self.isSelectedFlashlightBtn == NO) {
      [self removeFlashlightBtn];
    }
  }
}
#pragma mark - 自定义视图
//初始化可见扫描视图
- (KYQRCodeScanningView *)scanningView {
  if (!_scanningView) {
    _scanningView = [[KYQRCodeScanningView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.9 * self.view.frame.size.height)];
  }
  return _scanningView;
}
//提示文案
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
//解决复杂背景显示的问题
- (UIView *)bottomView {
  if (!_bottomView) {
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.scanningView.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(self.scanningView.frame))];
    _bottomView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
  }
  return _bottomView;
}

#pragma mark  - 闪光灯按钮
- (UIButton *)flashlightBtn {
  if (!_flashlightBtn) {
    // 添加闪光灯按钮
    _flashlightBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    CGFloat flashlightBtnW = 30;
    CGFloat flashlightBtnH = 30;
    CGFloat flashlightBtnX = 0.5 * (self.view.frame.size.width - flashlightBtnW);
    CGFloat flashlightBtnY = 0.55 * self.view.frame.size.height;
    _flashlightBtn.frame = CGRectMake(flashlightBtnX, flashlightBtnY, flashlightBtnW, flashlightBtnH);
    [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"KYQRCodeFlashlightOpenImage"] forState:(UIControlStateNormal)];
    [_flashlightBtn setBackgroundImage:[UIImage imageNamed:@"KYQRCodeFlashlightCloseImage"] forState:(UIControlStateSelected)];
    [_flashlightBtn addTarget:self action:@selector(flashlightBtn_action:) forControlEvents:UIControlEventTouchUpInside];
  }
  return _flashlightBtn;
}

- (void)flashlightBtn_action:(UIButton *)button {
  if (button.selected == NO) {
    [KYQRCodeHelperTool KY_openFlashlight];
    self.isSelectedFlashlightBtn = YES;
    button.selected = YES;
  } else {
    [self removeFlashlightBtn];
  }
}

#pragma mark - 私有方法
//开始扫描
- (void)startScan
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self.manager startRunning];
  });
}

- (void)removeFlashlightBtn {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [KYQRCodeHelperTool KY_CloseFlashlight];
    self.isSelectedFlashlightBtn = NO;
    self.flashlightBtn.selected = NO;
    [self.flashlightBtn removeFromSuperview];
  });
}


- (void)removeScanningView {
  [self.scanningView removeTimer];
  [self.scanningView removeFromSuperview];
  self.scanningView = nil;
  [_manager cancelSampleBufferDelegate];
  _manager = nil;
  
}



@end


////
////  KYQRCodeScanningViewController.m
////  KYQRCode_Example
////
////  Created by kingly on 2018/4/10.
////  Copyright © 2018年 KYQRCode Software https://github.com/kingly09/KYQRCode  by kingly inc.
//
////
//// Permission is hereby granted, free of charge, to any person obtaining a copy
//// of this software and associated documentation files (the "Software"), to deal
//// in the Software without restriction, including without limitation the rights
//// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//// copies of the Software, and to permit persons to whom the Software is
//// furnished to do so, subject to the following conditions:
////
//// The above copyright notice and this permission notice shall be included in
//// all copies or substantial portions of the Software.
////
//// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//// THE SOFTWARE. All rights reserved.
////
//
//#import "KYQRCodeScanningViewController.h"
//#import <KYQRCode/KYQRCode.h>
//
//@interface KYQRCodeScanningViewController ()<KYQRCodeScanManagerDelegate, KYQRCodeAlbumManagerDelegate>
//
//@property (nonatomic, strong) KYQRCodeScanManager *manager;
//@property (nonatomic, strong) KYQRCodeScanningView *scanningView;
//@property (nonatomic, strong) UILabel *promptLabel;
//
//@end
//
//@implementation KYQRCodeScanningViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//
//  self.view.backgroundColor = [UIColor blackColor];
//  self.automaticallyAdjustsScrollViewInsets = NO;
//
//  [self.view addSubview:self.scanningView];
//  [self setupNavigationBar];
//
//  [self.view addSubview:self.promptLabel];
//}
//
//- (void)didReceiveMemoryWarning {
//  [super didReceiveMemoryWarning];
//  // Dispose of any resources that can be recreated.
//
//}
//
//- (void)viewDidAppear:(BOOL)animated {
//  [super viewDidAppear:animated];
//  //不延时，可能会导致界面黑屏并卡住一会
//  //[self performSelector:@selector(startScan) withObject:nil afterDelay:0.05];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//  [super viewWillDisappear:animated];
//  [self.scanningView removeTimer];
//
//}
//
//- (void)dealloc {
//  NSLog(@"KYQRCodeScanningViewController - dealloc");
//  [self removeScanningView];
//}
//
//#pragma mark - 私有方法
//
//- (void)setupNavigationBar {
//  self.navigationItem.title = @"扫一扫";
//  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItenAction)];
//}
//
//
//- (void)setupQRCodeScanning {
//
//  self.manager = [KYQRCodeScanManager sharedManager];
//
//  NSArray *arr = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
//  // AVCaptureSessionPreset1920x1080 推荐使用，对于小型的二维码读取率较高
//  [_manager setupSessionPreset:AVCaptureSessionPresetHigh metadataObjectTypes:arr currentController:self];
//  [_manager cancelSampleBufferDelegate];
//  _manager.delegate = self;
//
//
//}
//
//- (void)rightBarButtonItenAction {
//
//  KYQRCodeAlbumManager *manager = [KYQRCodeAlbumManager sharedManager];
//  [manager readQRCodeFromAlbumWithCurrentController:self];
//  manager.delegate = self;
//
//  if (manager.isPHAuthorization == YES) {
//    [self.scanningView removeTimer];
//  }
//}
//
//- (void)removeScanningView {
//  [self.scanningView removeTimer];
//  [self.scanningView removeFromSuperview];
//  self.scanningView = nil;
//
//  [_manager cancelSampleBufferDelegate];
//  _manager = nil;
//
//}
//
///**
// 开始扫描二维码
// */
//- (void) startScan {
//
//  [self setupQRCodeScanning];
//
//  [self.scanningView addTimer];
//  [_manager startRunning];
//
//  [self.scanningView stopDeviceReadying];
//
//}
//
//
//#pragma mark - - - KYQRCodeAlbumManagerDelegate
//
//- (void)QRCodeAlbumManagerDidCancelWithImagePickerController:(KYQRCodeAlbumManager *)albumManager {
//  [self.view addSubview:self.scanningView];
//
//}
//
//- (void)QRCodeAlbumManager:(KYQRCodeAlbumManager *)albumManager didFinishPickingMediaWithResult:(NSString *)result {
//
//  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                  message:[NSString stringWithFormat:@"结果：%@",result]
//                                                 delegate:self
//                                        cancelButtonTitle:@"确定"
//                                        otherButtonTitles:nil,nil];
//  [alert show];
//
//}
//
//- (void)QRCodeAlbumManagerDidReadQRCodeFailure:(KYQRCodeAlbumManager *)albumManager {
//  NSLog(@"暂未识别出二维码");
//
//  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                  message:@"暂未识别出二维码"
//                                                 delegate:self
//                                        cancelButtonTitle:@"确定"
//                                        otherButtonTitles:nil,nil];
//  [alert show];
//}
//
//
//#pragma mark - KYQRCodeScanManagerDelegate
//
//- (void)QRCodeScanManager:(KYQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects {
//  NSLog(@"metadataObjects - - %@", metadataObjects);
//  if (metadataObjects != nil && metadataObjects.count > 0) {
//
//    NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:@"sound.caf" ofType:nil];
//    [scanManager playSoundNameWithAudioFilePath:audioFilePath];
//    [scanManager stopRunning];
//
//    AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
//
//
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                    message:[NSString stringWithFormat:@"结果：%@",[obj stringValue]]
//                                                   delegate:self
//                                          cancelButtonTitle:@"确定"
//                                          otherButtonTitles:nil,nil];
//    [alert show];
//
//
//  } else {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
//                                                    message:@"暂未识别出二维码"
//                                                   delegate:self
//                                          cancelButtonTitle:@"确定"
//                                          otherButtonTitles:nil,nil];
//    [alert show];
//  }
//
//}
//
//#pragma mark - 懒加载
//- (UILabel *)promptLabel {
//  if (!_promptLabel) {
//    _promptLabel = [[UILabel alloc] init];
//    _promptLabel.backgroundColor = [UIColor clearColor];
//    CGFloat promptLabelX = 0;
//    CGFloat promptLabelY = 0.73 * self.view.frame.size.height;
//    CGFloat promptLabelW = self.view.frame.size.width;
//    CGFloat promptLabelH = 25;
//    _promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
//    _promptLabel.textAlignment = NSTextAlignmentCenter;
//    _promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
//    _promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
//    _promptLabel.text = @"将二维码/条码放入框内, 即可自动扫描";
//  }
//  return _promptLabel;
//}
//
//- (KYQRCodeScanningView *)scanningView {
//  if (!_scanningView) {
//    _scanningView = [[KYQRCodeScanningView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//
//  }
//  return _scanningView;
//}
//
//
//- (void)QRCodeScanVC:(UIViewController *)scanVC {
//  AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//  if (device) {
//    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    switch (status) {
//      case AVAuthorizationStatusNotDetermined: {
//        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//          if (granted) {
//            dispatch_sync(dispatch_get_main_queue(), ^{
//              [self.navigationController pushViewController:scanVC animated:YES];
//            });
//            NSLog(@"用户第一次同意了访问相机权限 - - %@", [NSThread currentThread]);
//          } else {
//            NSLog(@"用户第一次拒绝了访问相机权限 - - %@", [NSThread currentThread]);
//          }
//        }];
//        break;
//      }
//      case AVAuthorizationStatusAuthorized: {
//        [self.navigationController pushViewController:scanVC animated:YES];
//        break;
//      }
//      case AVAuthorizationStatusDenied: {
//        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请去-> [设置 - 隐私 - 相机 - SGQRCodeExample] 打开访问开关" preferredStyle:(UIAlertControllerStyleAlert)];
//        UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
//
//        }];
//
//        [alertC addAction:alertA];
//        [self presentViewController:alertC animated:YES completion:nil];
//        break;
//      }
//      case AVAuthorizationStatusRestricted: {
//        NSLog(@"因为系统原因, 无法访问相册");
//        break;
//      }
//
//      default:
//        break;
//    }
//    return;
//  }
//
//  UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未检测到您的摄像头" preferredStyle:(UIAlertControllerStyleAlert)];
//  UIAlertAction *alertA = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
//
//  }];
//
//  [alertC addAction:alertA];
//  [self presentViewController:alertC animated:YES completion:nil];
//}
//
//
//@end
