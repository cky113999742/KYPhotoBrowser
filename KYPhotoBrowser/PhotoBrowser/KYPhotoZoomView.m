//
//  KYPhotoZoomView.m
//  KYPhotoBrowser
//
//  Created by Cuikeyi on 2017/8/2.
//  Copyright © 2017年 Cuikeyi. All rights reserved.
//

#import "KYPhotoZoomView.h"
#import "KYPhotoBrowserManager.h"
#import "KYPhotoBrowserMacro.h"

@interface KYPhotoZoomView ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation KYPhotoZoomView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageState = ShowImageStateSmall;
        [self initView];
        [self addGestures];
    }
    return self;
}

- (void)initView
{
    self.directionalLockEnabled = YES;
    self.minimumZoomScale = 1.f;
    self.maximumZoomScale = 3.f;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    
    CGFloat imageViewW = [UIScreen mainScreen].bounds.size.width-2*60;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageViewW, imageViewW)];
    _imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.clipsToBounds = YES;
    _imageView.userInteractionEnabled = YES;
    [self addSubview:_imageView];
}

- (void)addGestures
{
    // 1 add double tap gesture
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleClick:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    // 2 add single tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [tap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:tap];
}

- (void)tapAction
{
    [self dismissAnimation:YES];
}

- (void)didDoubleClick:(UITapGestureRecognizer *)sender
{
    if (self.imageState > ShowImageStateSmall) {
        if (self.zoomScale != 1.0) {// 还原
            
            [self setZoomScale:1.f animated:YES];
        } else {// 放大
            CGPoint point = [sender locationInView:sender.view];
            CGFloat touchX = point.x;
            CGFloat touchY = point.y;
            touchX *= 1/self.zoomScale;
            touchY *= 1/self.zoomScale;
            touchX += self.contentOffset.x;
            touchY += self.contentOffset.y;
            CGRect zoomRect = [self zoomRectForScale:2.f withCenter:CGPointMake(touchX, touchY)];
            [self zoomToRect:zoomRect animated:YES];
            
        }
    }
}

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
    CGFloat height = self.frame.size.height / scale;
    CGFloat width  = self.frame.size.width / scale;
    CGFloat x = center.x - width * 0.5;
    CGFloat y = center.y - height * 0.5;
    return CGRectMake(x, y, width, height);
}

- (void)resetScale
{
    [self setZoomScale:1.f animated:NO];
}

- (void)showImageWithPhotoModel:(KYPhotoModel *)photoModel;
{
    UIImage *placeholderImage = nil;
    if ([self.zoomDelegate respondsToSelector:@selector(photoZoomViewPlaceholderImage)]) {
        placeholderImage = [self.zoomDelegate photoZoomViewPlaceholderImage];
    }
    
    if (!photoModel) {
        if ([self.zoomDelegate respondsToSelector:@selector(photoZoomViewPlaceholderImage)]) {
            _imageView.image = placeholderImage;
        }
        return;
    }
    if (_imageState == ShowImageStateSmall) {// 第一次加载，需要动画展示
        
    }
    // 1，检测大图
    if (photoModel.bigURLString) {
        
        [_imageView yy_setImageWithURL:[NSURL URLWithString:photoModel.bigURLString]
                           placeholder:placeholderImage
                               options:kNilOptions
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  _process = (CGFloat)receivedSize/(CGFloat)expectedSize;
                              }
                             transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                 if (image) {
                                     [self becomeBigStateImage:_imageView.image animation:YES];
                                     _imageState = ShowImageStateOrigin;
                                 }
                                 else {// 处理大图加载失效情况
                                     
                                 }
        }];
    }
    // 2，加载普通图片
    else if (photoModel.thumbURLString) {
        
        [_imageView yy_setImageWithURL:[NSURL URLWithString:photoModel.thumbURLString]
                           placeholder:placeholderImage
                               options:kNilOptions
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  
                              } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                  if (image) {
                                      [self becomeBigStateImage:_imageView.image animation:YES];
                                      _imageState = ShowImageStateBig;
                                  }
                                  else {// 处理普通图加载失败的情况
                                      
                                  }
                              }];
    }
    // 3，加载图片数据
    else if (photoModel.image || photoModel.imageData) {
        
        _imageView.image = photoModel.image ? photoModel.image : [UIImage imageWithData:photoModel.imageData];
        [self becomeBigStateImage:_imageView.image animation:YES];
        _imageState = ShowImageStateBig;
    }
    else {
        _imageView.image = placeholderImage;
        [self becomeBigStateImage:_imageView.image animation:YES];
        _imageState = ShowImageStateBig;
    }
    
}

- (void)becomeBigStateImage:(UIImage *)image animation:(BOOL)animation
{
    if (animation) {
        [UIView animateWithDuration:KYPhotoBrowserShowImageAnimationDuration
                              delay:0
             usingSpringWithDamping:1.f
              initialSpringVelocity:1.f
                            options:0
                         animations:^{
                             [self setupImageView:image];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
    else {
        [self setupImageView:image];
    }
}

- (void)setupImageView:(UIImage *)image
{
    if (!image) {
        return;
    }
    CGFloat scrW = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = scrW / image.size.width;
    CGSize size = CGSizeMake(scrW, image.size.height * scale);
    CGFloat y = MAX(0., (self.frame.size.height - size.height) / 2.f);
    CGFloat x = MAX(0., (self.frame.size.width - size.width) / 2.f);
    [self.imageView setFrame:CGRectMake(x, y, size.width, size.height)];
    [self.imageView setImage:image];
    self.contentSize = CGSizeMake(self.bounds.size.width, size.height);
}

- (void)dismissAnimation:(BOOL)animation
{
    __block CGRect toFrame;
    if ([self.zoomDelegate respondsToSelector:@selector(dismissRect)]) {
        toFrame = [self.zoomDelegate dismissRect];
        if (CGRectEqualToRect(toFrame, CGRectZero) || CGRectEqualToRect(toFrame, CGRectNull)) {
            animation = NO;
        }
    }
    
    if (animation) {
        if (_imageView.image) {
            _imageView.contentMode = UIViewContentModeScaleAspectFill;
            [UIView animateWithDuration:KYPhotoBrowserShowImageAnimationDuration
                                  delay:0
                 usingSpringWithDamping:1.f
                  initialSpringVelocity:1.f
                                options:0
                             animations:^{
                                 _imageView.frame = CGRectMake(toFrame.origin.x+self.contentOffset.x, toFrame.origin.y+self.contentOffset.y, toFrame.size.width, toFrame.size.height);
                             } completion:^(BOOL finished) {
                                 
                             }];
        }
    }
    
    [[KYPhotoBrowserManager sharedManager] dismissWindow:YES];
}

- (void)tapAction:(UIPanGestureRecognizer *)sender
{
    [self dismissAnimation:YES];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
}

// 缩放小于1的时候，始终让其在中心点位置进行缩放
- (void)centerScrollViewContents
{
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}


@end
