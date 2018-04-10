//
//  KYCreateQRCodeViewController.m
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

#import "KYCreateQRCodeViewController.h"
#import <KYQRCode/KYQRCode.h>

@interface KYCreateQRCodeViewController ()

@end

@implementation KYCreateQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithWhite:0.87 alpha:1.0];
  
    if ([self.title isEqualToString:@"生成普通二维码"]) {
      [self setupGenerateQRCode];
    }else if ([self.title isEqualToString:@"生成带logo的二维码"]) {
      [self setupGenerate_Icon_QRCode];
    }else if ([self.title isEqualToString:@"生成带色彩的二维码"]) {
      [self setupGenerate_Color_QRCode];
    }else{
      self.title = @"生成普通二维码";
      [self setupGenerateQRCode];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// 生成二维码
- (void)setupGenerateQRCode {
  
  // 1、借助UIImageView显示二维码
  UIImageView *imageView = [[UIImageView alloc] init];
  CGFloat imageViewW = 150;
  CGFloat imageViewH = imageViewW;
  CGFloat imageViewX = (self.view.frame.size.width - imageViewW) / 2;
  CGFloat imageViewY = 100;
  imageView.frame =CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
  [self.view addSubview:imageView];
  
  // 2、将CIImage转换成UIImage，并放大显示
  imageView.image = [KYQRCodeGenerateManager generateWithDefaultQRCodeData:@"https://github.com/kingly09" imageViewWidth:imageViewW];
  
#pragma mark - - - 模仿支付宝二维码样式（添加用户头像）
  CGFloat scale = 0.22;
  CGFloat borderW = 5;
  UIView *borderView = [[UIView alloc] init];
  CGFloat borderViewW = imageViewW * scale;
  CGFloat borderViewH = imageViewH * scale;
  CGFloat borderViewX = 0.5 * (imageViewW - borderViewW);
  CGFloat borderViewY = 0.5 * (imageViewH - borderViewH);
  borderView.frame = CGRectMake(borderViewX, borderViewY, borderViewW, borderViewH);
  borderView.layer.borderWidth = borderW;
  borderView.layer.borderColor = [UIColor purpleColor].CGColor;
  borderView.layer.cornerRadius = 10;
  borderView.layer.masksToBounds = YES;
  borderView.layer.contents = (id)[UIImage imageNamed:@"icon60x60"].CGImage;
  
}


#pragma mark  - 中间带有图标二维码生成

- (void)setupGenerate_Icon_QRCode {
  
  // 1、借助UIImageView显示二维码
  UIImageView *imageView = [[UIImageView alloc] init];
  CGFloat imageViewW = 150;
  CGFloat imageViewH = imageViewW;
  CGFloat imageViewX = (self.view.frame.size.width - imageViewW) / 2;
  CGFloat imageViewY = 240;
  imageView.frame =CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
  [self.view addSubview:imageView];
  
  CGFloat scale = 0.2;
  
  // 2、将最终合得的图片显示在UIImageView上
  imageView.image = [KYQRCodeGenerateManager generateWithLogoQRCodeData:@"https://github.com/kingly09/KYQRCode.git" logoImageName:@"icon60x60" logoScaleToSuperView:scale];
  
}

#pragma mark  - 彩色图标二维码生成
- (void)setupGenerate_Color_QRCode {
  
  // 1、借助UIImageView显示二维码
  UIImageView *imageView = [[UIImageView alloc] init];
  CGFloat imageViewW = 150;
  CGFloat imageViewH = imageViewW;
  CGFloat imageViewX = (self.view.frame.size.width - imageViewW) / 2;
  CGFloat imageViewY = 400;
  imageView.frame =CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
  [self.view addSubview:imageView];
  
  // 2、将二维码显示在UIImageView上
  imageView.image = [KYQRCodeGenerateManager generateWithColorQRCodeData:@"hhttps://github.com/kingly09/KYQRCode.git" backgroundColor:[CIColor colorWithRed:1 green:0 blue:0.8] mainColor:[CIColor colorWithRed:0.3 green:0.2 blue:0.4]];
}



@end
