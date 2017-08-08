//
//  KYPhotoBrowserController.h
//  KYPhotoBrowser
//
//  Created by Cuikeyi on 2017/8/2.
//  Copyright © 2017年 Cuikeyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KYPhotoModel.h"

@protocol KYPhotoBrowserControllerDelegate <NSObject>

@optional
// 动画消失的目标frame
- (UIImageView *)sourceImageViewForIndex:(NSInteger)index;
// 获取图片展示占位图
- (UIImage *)photoBrowserPlaceholderImage;

@end

@interface KYPhotoBrowserController : UIViewController

@property (nonatomic, weak) id <KYPhotoBrowserControllerDelegate> delegate;
@property (nonatomic, strong, readonly) UIScrollView              *scrollView;
@property (nonatomic, strong, readonly) UILabel                   *pageLabel;
/**
 *  当前显示的图片位置索引 , 默认是0
 */
@property (nonatomic, assign) NSInteger currentImageIndex;
/**
 *  浏览的图片数量,大于0
 */
@property (nonatomic, assign) NSInteger imageCount;

/**
 图片数据 数组内可以是 KYPhotoModel， NSImage， NSString， NSData
 */
@property (nonatomic, strong) NSArray *images;

/**
 初始化的方法

 @param images 图片数据 数组内可以是 KYPhotoModel， NSImage， NSString， NSData
 @param currentImageIndex 当前显示的位置
 */
+ (instancetype)showPhotoBrowserWithImages:(NSArray *)images currentImageIndex:(NSInteger)currentImageIndex;

/**
 初始化的方法 如需实现动画 必须实现代理方法
 
 @param images 图片数据 数组内可以是 KYPhotoModel， NSImage， NSString， NSData
 @param currentImageIndex 当前显示的位置
 @param delegate 代理
 */
+ (instancetype)showPhotoBrowserWithImages:(NSArray *)images currentImageIndex:(NSInteger)currentImageIndex delegate:( id <KYPhotoBrowserControllerDelegate>)delegate;

/**
 移除方法

 @param animation 动画
 */
- (void)dismissAnimation:(BOOL)animation;

@end
