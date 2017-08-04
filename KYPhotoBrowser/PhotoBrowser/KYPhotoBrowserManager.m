//
//  KYPhotoBrowserManager.m
//  KYPhotoBrowser
//
//  Created by Cuikeyi on 2017/8/2.
//  Copyright © 2017年 Cuikeyi. All rights reserved.
//

#import "KYPhotoBrowserManager.h"
#import "KYPhotoBrowserMacro.h"

static NSTimer *_userInteractionEnableTimer = nil;

@interface KYPhotoBrowserManager ()

@end

@implementation KYPhotoBrowserManager

+ (instancetype)sharedManager
{
    static KYPhotoBrowserManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KYPhotoBrowserManager alloc] init];
    });
    return manager;
}

- (void)presentWindowWithController:(UIViewController *)controller;
{
    [[self class] disableUserInteractionDuration:KYPhotoBrowserDismissAnimationDuration];
    UIWindow *photoWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _photoWindow = photoWindow;
    _photoWindow.windowLevel = UIWindowLevelStatusBar + 0.1;
    _photoWindow.rootViewController = controller;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.photoWindow setHidden:NO];
    });
}

- (void)dismissWindow:(BOOL)animation;
{
    if (!animation) {
        [self _dismissWindow];
        return;
    }
    
    [[self class] disableUserInteractionDuration:KYPhotoBrowserDismissAnimationDuration];
    [UIView animateWithDuration:KYPhotoBrowserDismissAnimationDuration delay:0 options:0 animations:^{
        _photoWindow.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self _dismissWindow];
    }];
}

- (void)_dismissWindow
{
    _photoWindow.hidden = YES;
    _photoWindow.rootViewController = nil;
    _photoWindow = nil;
}

#pragma mark - 禁止屏幕点击响应
+ (void)disableUserInteractionDuration:(NSTimeInterval)timeInterval
{
    if (_userInteractionEnableTimer != nil)
    {
        if ([_userInteractionEnableTimer isValid])
        {
            [_userInteractionEnableTimer invalidate];
            if ([UIApplication sharedApplication].isIgnoringInteractionEvents) {
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            }
        }
        _userInteractionEnableTimer = nil;
    }
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    _userInteractionEnableTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval] interval:0 target:self selector:@selector(userInteractionEnable) userInfo:nil repeats:false];
    [[NSRunLoop mainRunLoop] addTimer:_userInteractionEnableTimer forMode:NSRunLoopCommonModes];
}

+ (void)userInteractionEnable
{
    [_userInteractionEnableTimer invalidate];
    _userInteractionEnableTimer = nil;
    if ([UIApplication sharedApplication].isIgnoringInteractionEvents) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

@end
