//
//  KYPhotoZoomView.h
//  KYPhotoBrowser
//
//  Created by Cuikeyi on 2017/8/2.
//  Copyright © 2017年 Cuikeyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KYPhotoModel.h"
#if __has_include(<YYWebImage/YYWebImage.h>)
#import <YYWebImage/YYImageCache.h>
#import <YYWebImage/YYWebImageOperation.h>
#import <YYWebImage/YYWebImageManager.h>
#import <YYWebImage/UIImage+YYWebImage.h>
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYWebImage/UIButton+YYWebImage.h>
#import <YYWebImage/CALayer+YYWebImage.h>
#import <YYWebImage/MKAnnotationView+YYWebImage.h>
#else
#import "YYImageCache.h"
#import "YYWebImageOperation.h"
#import "YYWebImageManager.h"
#import "UIImage+YYWebImage.h"
#import "UIImageView+YYWebImage.h"
#import "UIButton+YYWebImage.h"
#import "CALayer+YYWebImage.h"
#import "MKAnnotationView+YYWebImage.h"
#endif

typedef NS_ENUM(NSInteger, ShowImageState) {
    ShowImageStateSmall,    // 初始化默认是小图
    ShowImageStateBig,   // 全屏的正常图片
    ShowImageStateOrigin    // 原图
};

@class KYPhotoZoomView;
@protocol KYPhotoZoomViewDelegate <NSObject>

- (CGRect)dismissRect;
- (UIImage *)photoZoomViewPlaceholderImage;

@end

@interface KYPhotoZoomView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, weak) id <KYPhotoZoomViewDelegate> zoomDelegate;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, assign, readonly) ShowImageState imageState;
@property (nonatomic, assign) CGFloat process;

- (void)resetScale;
- (void)showImageWithPhotoModel:(KYPhotoModel *)photoModel;
- (void)dismissAnimation:(BOOL)animation;

@end
