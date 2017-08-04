//
//  KYPhotoBrowserManager.h
//  KYPhotoBrowser
//
//  Created by Cuikeyi on 2017/8/2.
//  Copyright © 2017年 Cuikeyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 图片浏览管理类
 */
@interface KYPhotoBrowserManager : NSObject

@property (nonatomic, strong) UIWindow *photoWindow;

+ (instancetype)sharedManager;
- (void)presentWindowWithController:(UIViewController *)controller;
- (void)dismissWindow:(BOOL)animation;

@end
