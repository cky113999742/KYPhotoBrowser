//
//  KYPhotoModel.h
//  KYPhotoBrowser
//
//  Created by Cuikeyi on 2017/8/2.
//  Copyright © 2017年 Cuikeyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KYImageType)
{
    KYImageTypeNormal       = 0,    // 普通图片
    KYImageTypeOrigin       = 1,    // 原图
    KYImageTypeLongPic      = 2     // 长图
};

@interface KYPhotoModel : NSObject

@property (nonatomic, strong) NSData        *imageData;
@property (nonatomic, strong) UIImage       *image;
@property (nonatomic, strong) NSString      *thumbURLString;
@property (nonatomic, strong) NSString      *bigURLString;
@property (nonatomic, assign) KYImageType   imageType;

@end
