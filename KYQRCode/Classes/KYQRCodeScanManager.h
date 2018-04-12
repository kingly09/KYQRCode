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
#import <AVFoundation/AVFoundation.h>
@class KYQRCodeScanManager;

@protocol KYQRCodeScanManagerDelegate <NSObject>

@required

/**
 二维码扫描获取数据的回调方法

 @param scanManager 二维码管理对象
 @param metadataObjects 扫描二维码数据信息
 */
- (void)QRCodeScanManager:(KYQRCodeScanManager *)scanManager didOutputMetadataObjects:(NSArray *)metadataObjects;
@optional

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
withAVCaptureVideoDataOutput:(AVCaptureVideoDataOutput *)captureVideoDataOutput;

/**
 根据光线强弱值打开手电筒的方法

 @param scanManager 二维码管理对象
 @param brightnessValue 光线强弱值
 */
- (void)QRCodeScanManager:(KYQRCodeScanManager *)scanManager brightnessValue:(CGFloat)brightnessValue;
@end

@interface KYQRCodeScanManager : NSObject
/** 快速创建单利方法 */
+ (instancetype)sharedManager;
/**  KYQRCodeScanManagerDelegate */
@property (nonatomic, weak) id<KYQRCodeScanManagerDelegate> delegate;
@property (nonatomic,copy) NSString *currAudioFilePath; //自定义音频路径
/**
 *  创建扫描二维码会话对象以及会话采集数据类型和扫码支持的编码格式的设置，必须实现的方法
 *
 *  @param sessionPreset    会话采集数据类型
 *  @param metadataObjectTypes    扫码支持的编码格式
 *  @param currentController      KYQRCodeScanManager 所在控制器
 */
- (void)setupSessionPreset:(NSString *)sessionPreset metadataObjectTypes:(NSArray *)metadataObjectTypes currentController:(UIViewController *)currentController;
//默认支持码的类别 扫码支持的编码格式
- (NSArray *)defaultMetaDataObjectTypes;
//该设备没有打开摄像头
+(BOOL)checkMediaTypeVideo;
//检查是否有相机权限
+ (BOOL)checkAuthority;
/** 开启会话对象扫描 */
- (void)startRunning;
/** 停止会话对象扫描 */
- (void)stopRunning;
/** 移除 videoPreviewLayer 对象 */
- (void)videoPreviewLayerRemoveFromSuperlayer;
/** 播放音效文件 */
- (void)playSoundNameWithAudioFilePath:(NSString *)audioFilePath;
/** 重置根据光线强弱值打开手电筒的 delegate 方法 */
- (void)resetSampleBufferDelegate;
/** 取消根据光线强弱值打开手电筒的 delegate 方法 */
- (void)cancelSampleBufferDelegate;

#pragma mark - 摄像机镜头
/**
 @brief 获取摄像机最大拉远镜头
 @return 放大系数
 */
- (CGFloat)getVideoMaxScale;

/**
 @brief 获取摄像机当前镜头系数
 @return 系数
 */
-(CGFloat)getVideoZoomFactor;
/**
 @brief 拉近拉远镜头
 @param scale 系数
 */
- (void)setVideoScale:(CGFloat)scale;
@end

