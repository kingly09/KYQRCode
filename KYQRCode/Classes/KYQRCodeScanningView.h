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


#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    /// 默认与边框线同中心点
    CornerLoactionDefault,
    /// 在边框线内部
    CornerLoactionInside,
    /// 在边框线外部
    CornerLoactionOutside
} CornerLoaction;

typedef enum : NSUInteger {
    /// 单线扫描样式
    ScanningAnimationStyleDefault,
    /// 网格扫描样式
    ScanningAnimationStyleGrid
} ScanningAnimationStyle;

@interface KYQRCodeScanningView : UIView
/** 扫描样式，默认 ScanningAnimationStyleDefault */
@property (nonatomic, assign) ScanningAnimationStyle scanningAnimationStyle;
/** 自定义扫描线名的图片资源 */
@property (nonatomic, strong) UIImage *scanningImage;
/** 边框颜色，默认白色 */
@property (nonatomic, strong) UIColor *borderColor;
/** 边角位置，默认 CornerLoactionDefault */
@property (nonatomic, assign) CornerLoaction cornerLocation;
/** 边角颜色，默认微信颜色 */
@property (nonatomic, strong) UIColor *cornerColor;
/** 边角宽度，默认 2.f */
@property (nonatomic, assign) CGFloat cornerWidth;
/** 扫描区周边颜色的 alpha 值，默认 0.2f */
@property (nonatomic, assign) CGFloat backgroundAlpha;
/** 扫描线动画时间，默认 0.02 */
@property (nonatomic, assign) NSTimeInterval animationTimeInterval;

/** 添加定时器 */
- (void)addTimer;

/** 移除定时器(切记：一定要在Controller视图消失的时候，停止定时器) */
- (void)removeTimer;
/**
 停止菊花等待
 */
- (void)stopDeviceReadying;

@end
