//
//  KYPhotoGestureHandle.h
//  KYPhotoBrowser
//
//  Created by Cuikeyi on 2017/8/4.
//  Copyright © 2017年 Cuikeyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KYPhotoZoomView, KYPhotoGestureHandle;

@protocol KYPhotoGestureHandleDelegate <NSObject>
// 获取当前展示的图片对象
- (KYPhotoZoomView *)currentDetailImageViewInPhotoPreview:(KYPhotoGestureHandle *)handle;
// 图片对象去移除的代理
- (void)detailImageViewGotoDismiss;
// 控制图片控制器中，照片墙，更多等小组件的隐藏/显示
- (void)photoPreviewComponmentHidden:(BOOL)hidden;

@end

@interface KYPhotoGestureHandle : NSObject

@property (nonatomic, weak) id <KYPhotoGestureHandleDelegate> delegate;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView coverView:(UIView *)coverView;

@end
