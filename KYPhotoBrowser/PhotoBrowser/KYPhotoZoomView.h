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
#import <YYWebImage/YYWebImage.h>
#else
#import "YYWebImage.h"
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
