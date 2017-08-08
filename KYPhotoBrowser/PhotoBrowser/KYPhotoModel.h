//
//  KYPhotoModel.h
//  KYPhotoBrowser
//
//  Created by Cuikeyi on 2017/8/2.
//  Copyright © 2017年 Cuikeyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KYPhotoModel : NSObject

@property (nonatomic, strong) NSData        *imageData;         /**< 图片数据 */
@property (nonatomic, strong) UIImage       *image;             /**< 图片数据 */
@property (nonatomic, strong) NSString      *thumbURLString;    /**< 普通图下载链接 */
@property (nonatomic, strong) NSString      *originURLString;   /**< 原图下载链接 */
@property (nonatomic, assign) CGFloat       originImageSize;    /**< 原图的大小，单位为 B */

@end
