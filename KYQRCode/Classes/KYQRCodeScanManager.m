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


#import "KYQRCodeScanManager.h"

@interface KYQRCodeScanManager () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong)  AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property(nonatomic,strong)  AVCaptureStillImageOutput *stillImageOutput;//拍照
@property (nonatomic,weak) UIViewController *viewController;    //视频预览显示视图

@end

@implementation KYQRCodeScanManager

static KYQRCodeScanManager *_instance;

+ (instancetype)sharedManager {
  return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _instance = [super allocWithZone:zone];
  });
  return _instance;
}

-(id)copyWithZone:(NSZone *)zone {
  return _instance;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
  return _instance;
}

- (void)setupSessionPreset:(NSString *)sessionPreset metadataObjectTypes:(NSArray *)metadataObjectTypes currentController:(UIViewController *)currentController {
  
  //  if (sessionPreset == nil) {
  //    @throw [NSException exceptionWithName:@"KYQRCode" reason:@"setupSessionPreset:metadataObjectTypes:currentController: 方法中的 sessionPreset 参数不能为空" userInfo:nil];
  //  }
  
  //  if (metadataObjectTypes == nil) {
  //    @throw [NSException exceptionWithName:@"KYQRCode" reason:@"setupSessionPreset:metadataObjectTypes:currentController: 方法中的 metadataObjectTypes 参数不能为空" userInfo:nil];
  //  }
  
  if (sessionPreset == nil) {
    sessionPreset = AVCaptureSessionPresetHigh;
  }
  
  if (currentController == nil) {
    @throw [NSException exceptionWithName:@"KYQRCode" reason:@"setupSessionPreset:metadataObjectTypes:currentController: 方法中的 currentController 参数不能为空" userInfo:nil];
  }
  
  // 1、获取摄像设备
  _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  
  // 2、创建摄像设备输入流
  _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:nil];
  
  //添加自动白平衡，自动对焦功能，自动曝光
  if ([_deviceInput.device lockForConfiguration:nil])
  {
    //自动白平衡
    if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance])
    {
      NSLog(@"KYQRCode::AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance");
      [_deviceInput.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
    }
    //先进行判断是否支持控制对焦,不开启自动对焦功能，很难识别二维码。
    if (_device.isFocusPointOfInterestSupported &&[_device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
    {
      NSLog(@"KYQRCode::AVCaptureFocusModeContinuousAutoFocus");
      [_deviceInput.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    //自动曝光
    if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
    {
      NSLog(@"KYQRCode::AVCaptureExposureModeContinuousAutoExposure");
      [_deviceInput.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [_deviceInput.device unlockForConfiguration];
  }
  
  // 3、创建元数据输出流
  AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
  [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
  
  // 3(1)、创建摄像数据输出流
  self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
  [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
  
  // 设置扫描范围（每一个取值0～1，以屏幕右上角为坐标原点）
  // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）;
  // 如需限制扫描框范围，打开下一句注释代码并进行相应调整
  //    metadataOutput.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
  
  // 3(2)、创建摄像数据输出流(格式)
  _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
  NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  AVVideoCodecJPEG, AVVideoCodecKey,
                                  nil];
  [_stillImageOutput setOutputSettings:outputSettings];
  
  // 4、创建会话对象
  _session = [[AVCaptureSession alloc] init];
  // 会话采集率: AVCaptureSessionPresetHigh
  _session.sessionPreset = sessionPreset;
  
  // 5、添加元数据输出流到会话对象
  if ([_session canAddOutput:metadataOutput])
  {
    NSLog(@"session::AVCaptureMetadataOutput");
    [_session addOutput:metadataOutput];
  }
  
  // 5(1)添加摄像输出流到会话对象；与 3(1) 构成识了别光线强弱
  if ([_session canAddOutput:_videoDataOutput])
  {
    NSLog(@"session::AVCaptureVideoDataOutput");
    [_session addOutput:_videoDataOutput];
  }
  //添加静态图片输出
  if ([_session canAddOutput:_stillImageOutput])
  {
    NSLog(@"session::AVCaptureStillImageOutput");
    [_session addOutput:_stillImageOutput];
  }

  // 6、添加摄像设备输入流到会话对象
  if ([_session canAddInput:_deviceInput])
  {
    NSLog(@"session::AVCaptureDeviceInput");
    [_session addInput:_deviceInput];
  }
  
  // 7、设置数据输出类型，需要将数据输出添加到会话后，才能指定元数据类型，否则会报错
  // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
  // @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
  //如果没有设置的编码格式，设置扫码支持的编码格式，那么默认设置默认支持
  if (metadataObjectTypes.count == 0) {
    metadataObjectTypes = [self defaultMetaDataObjectTypes];
  }
  metadataOutput.metadataObjectTypes = metadataObjectTypes;
  
  
  // 8、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
  _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
  // 保持纵横比；填充层边界
  _videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  CGFloat x = 0;
  CGFloat y = 0;
  CGFloat w = [UIScreen mainScreen].bounds.size.width;
  CGFloat h = [UIScreen mainScreen].bounds.size.height;
  _videoPreviewLayer.frame = CGRectMake(x, y, w, h);
  [currentController.view.layer insertSublayer:_videoPreviewLayer atIndex:0];
  
  // 9、启动扫描会话
  [self loadScan];
 
}

//启动扫描
-(void)loadScan
{

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     [_session startRunning];
    dispatch_async(dispatch_get_main_queue(), ^{
      
      if (self.delegate && [self.delegate respondsToSelector:@selector(QRCodeScanManager:withAVCaptureSession:withAVCaptureDevice:withAVCaptureDeviceInput:withAVCaptureVideoDataOutput:)]) {
        [self.delegate QRCodeScanManager:self withAVCaptureSession:_session withAVCaptureDevice:_device withAVCaptureDeviceInput:_deviceInput withAVCaptureVideoDataOutput:_videoDataOutput];
      }
      });
  });
}

/**
 @brief  默认支持码的类别
 @return 支持类别 数组
 */
- (NSArray *)defaultMetaDataObjectTypes
{
  NSMutableArray *types = [@[AVMetadataObjectTypeQRCode,
                             AVMetadataObjectTypeUPCECode,
                             AVMetadataObjectTypeCode39Code,
                             AVMetadataObjectTypeCode39Mod43Code,
                             AVMetadataObjectTypeEAN13Code,
                             AVMetadataObjectTypeEAN8Code,
                             AVMetadataObjectTypeCode93Code,
                             AVMetadataObjectTypeCode128Code,
                             AVMetadataObjectTypePDF417Code,
                             AVMetadataObjectTypeAztecCode] mutableCopy];
  
  if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_0)
  {
    [types addObjectsFromArray:@[
                                 AVMetadataObjectTypeInterleaved2of5Code,
                                 AVMetadataObjectTypeITF14Code,
                                 AVMetadataObjectTypeDataMatrixCode
                                 ]];
  }
  
  return types;
}

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
  for ( AVCaptureConnection *connection in connections ) {
    for ( AVCaptureInputPort *port in [connection inputPorts] ) {
      if ( [[port mediaType] isEqual:mediaType] ) {
        return connection;
      }
    }
  }
  return nil;
}


#pragma mark  - AVCaptureMetadataOutputObjectsDelegate 扫瞄到二维码之后，会调用delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
  
  if (_currAudioFilePath.length > 0) {
    
    [self playSoundNameWithAudioFilePath:_currAudioFilePath];
    
  }else{
    
    NSString *bundlePath = [[NSBundle bundleForClass:[self class]].resourcePath
                            stringByAppendingPathComponent:@"/KYQRCode.bundle"];
    [self playSoundNameWithAudioFilePath:[NSString stringWithFormat:@"%@/sound.caf",bundlePath]];
  }
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(QRCodeScanManager:didOutputMetadataObjects:)]) {
    [self.delegate QRCodeScanManager:self didOutputMetadataObjects:metadataObjects];
  }
}

#pragma mark  - AVCaptureVideoDataOutputSampleBufferDelegate的方法 获取实时拍照的视频流

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    // 这个方法会时时调用，但内存很稳定
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    NSLog(@"%f",brightnessValue);

    if (self.delegate && [self.delegate respondsToSelector:@selector(QRCodeScanManager:brightnessValue:)]) {
        [self.delegate QRCodeScanManager:self brightnessValue:brightnessValue];
    }
}

- (void)startRunning {
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [_session startRunning];
  });
  
  
}

- (void)stopRunning {
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    if (_session.isRunning)
    {
     [_session stopRunning];
    }
  });
}

- (void)videoPreviewLayerRemoveFromSuperlayer {
    [_videoPreviewLayer removeFromSuperlayer];
}

- (void)resetSampleBufferDelegate {
    [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
}

- (void)cancelSampleBufferDelegate {
    [_videoDataOutput setSampleBufferDelegate:nil queue:dispatch_get_main_queue()];
}

- (void)playSoundNameWithAudioFilePath:(NSString *)audioFilePath {
 
  if (audioFilePath == nil) {
    NSLog(@"该音频文件路径有错误");
    return;
  }
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:audioFilePath])
  {
    NSLog(@"该音频文件路径不存在");
    return;
  }
  
   NSURL *fileUrl = [NSURL fileURLWithPath:audioFilePath];
    SystemSoundID soundID = 0;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    AudioServicesPlaySystemSound(soundID); // 播放音效
}
void soundCompleteCallback(SystemSoundID soundID, void *clientData){

}


/** 
该设备没有打开摄像头
 */
+(BOOL)checkMediaTypeVideo {
  
  AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  if (device==nil) {
    return NO;
  }
  return YES;
}
/*
 检查是否有相机权限/该设备没有打开摄像头
 */
+ (BOOL)checkAuthority
{
  NSString *mediaType = AVMediaTypeVideo;
  AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
  if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
    return NO;
  }
  return YES;
}
#pragma mark - 摄像机镜头
/**
 @brief 获取摄像机最大拉远镜头
 @return 放大系数
 */
- (CGFloat)getVideoMaxScale {
  
  [_deviceInput.device lockForConfiguration:nil];
  AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
  CGFloat maxScale = videoConnection.videoMaxScaleAndCropFactor;
  [_deviceInput.device unlockForConfiguration];
  
  return maxScale;
  
}

/**
 @brief 获取摄像机当前镜头系数
 @return 系数
 */
-(CGFloat)getVideoZoomFactor {
  
   return _deviceInput.device.videoZoomFactor;
}
/**
 @brief 拉近拉远镜头
 @param scale 系数
 */
- (void)setVideoScale:(CGFloat)scale {
  
  [_deviceInput.device lockForConfiguration:nil];
  
  AVCaptureConnection *videoConnection = [self connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
  CGFloat maxScaleAndCropFactor = ([[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor])/16;
  
  if (scale > maxScaleAndCropFactor)
    scale = maxScaleAndCropFactor;
  
  CGFloat zoom = scale / videoConnection.videoScaleAndCropFactor;
  
  videoConnection.videoScaleAndCropFactor = scale;
  
  [_deviceInput.device unlockForConfiguration];
  
  CGAffineTransform transform = _viewController.view.transform;
  [CATransaction begin];
  [CATransaction setAnimationDuration:.025];
  
  _viewController.view.transform = CGAffineTransformScale(transform, zoom, zoom);
  
  [CATransaction commit];
  
}
@end

