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
  
  self.view.backgroundColor = [UIColor clearColor];
  self.automaticallyAdjustsScrollViewInsets = NO;
  
  [self.view addSubview:self.scanningView];
  [self setupNavigationBar];
  [self setupQRCodeScanning];
  [self.view addSubview:self.promptLabel];
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
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self.scanningView addTimer];
  [_manager startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.scanningView removeTimer];
}

- (void)dealloc {
  NSLog(@"KYQRCodeScanningViewController - dealloc");
  [self removeScanningView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    
    [scanManager playSoundName:@"KYQRCode.bundle/sound.caf"];
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
    _scanningView.scanningImageName = @"KYQRCode.bundle/QRCodeScanningLineGrid";
    _scanningView.scanningAnimationStyle = ScanningAnimationStyleGrid;
    _scanningView.cornerColor = [UIColor orangeColor];
  }
  return _scanningView;
}




@end
