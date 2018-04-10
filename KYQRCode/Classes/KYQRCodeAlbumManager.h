//
//  如遇到问题或有更好方案，请通过以下方式进行联系
//      QQ群：429899752
//      Email：kingsic@126.com
//      GitHub：https://github.com/kingsic/KYQRCode
//
//  KYQRCodeAlbumManager.h
//  KYQRCodeExample
//
//  Created by kingsic on 2017/6/27.
//  Copyright © 2017年 kingsic. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KYQRCodeAlbumManager;

@protocol KYQRCodeAlbumManagerDelegate <NSObject>

@required
/** 图片选择控制器取消按钮的点击回调方法 */
- (void)QRCodeAlbumManagerDidCancelWithImagePickerController:(KYQRCodeAlbumManager *)albumManager;
/** 图片选择控制器读取图片二维码信息成功的回调方法 (result: 获取的二维码数据) */
- (void)QRCodeAlbumManager:(KYQRCodeAlbumManager *)albumManager didFinishPickingMediaWithResult:(NSString *)result;
/** 图片选择控制器读取图片二维码信息失败的回调函数 */
- (void)QRCodeAlbumManagerDidReadQRCodeFailure:(KYQRCodeAlbumManager *)albumManager;
@end

@interface KYQRCodeAlbumManager : NSObject
/** 快速创建单利方法 */
+ (instancetype)sharedManager;
/** KYQRCodeAlbumManagerDelegate */
@property (nonatomic, weak) id<KYQRCodeAlbumManagerDelegate> delegate;
/** 判断相册访问权限是否授权 */
@property (nonatomic, assign) BOOL isPHAuthorization;
/** 是否开启 log 打印，默认为 YES */
@property (nonatomic, assign) BOOL isOpenLog;

/** 从相册中读取二维码方法，必须实现的方法 */
- (void)readQRCodeFromAlbumWithCurrentController:(UIViewController *)currentController;

@end
