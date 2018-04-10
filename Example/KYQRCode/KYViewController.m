//
//  KYViewController.m
//  KYQRCode
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

#import "KYViewController.h"
#import <KYQRCode/KYQRCode.h>
#import "KYCreateQRCodeViewController.h"

@interface KYViewController ()

@end

@implementation KYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 扫一扫二维码
 */
- (IBAction)onClickQRCodeScanning:(id)sender {
}
/**
 扫一扫二维码（网格状）
 */
- (IBAction)onClickQRCodeScanningWG:(id)sender {
}
/**
 生成普通二维码
 */
- (IBAction)onClickCreateQR:(id)sender {
  
  KYCreateQRCodeViewController *VC = [[KYCreateQRCodeViewController alloc] init];
  VC.title = @"生成普通二维码";
  [self.navigationController pushViewController:VC animated:YES];
  
}
/**
 生成带logo的二维码
 */
- (IBAction)onClickCreateQRWithLogo:(id)sender {
  KYCreateQRCodeViewController *VC = [[KYCreateQRCodeViewController alloc] init];
  VC.title = @"生成带logo的二维码";
  [self.navigationController pushViewController:VC animated:YES];
}
/**
 生成带色彩的二维码
 */
- (IBAction)onClickCreateQRWithColor:(id)sender {
  
  KYCreateQRCodeViewController *VC = [[KYCreateQRCodeViewController alloc] init];
  VC.title = @"生成带色彩的二维码";
  [self.navigationController pushViewController:VC animated:YES];
  
}



@end
