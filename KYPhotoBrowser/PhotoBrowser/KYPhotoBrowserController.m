//
//  KYPhotoBrowserController.m
//  KYPhotoBrowser
//
//  Created by Cuikeyi on 2017/8/2.
//  Copyright © 2017年 Cuikeyi. All rights reserved.
//

#import "KYPhotoBrowserController.h"
#import "KYPhotoBrowserManager.h"
#import "KYPhotoBrowserMacro.h"
#import "KYPhotoZoomView.h"
#import "KYPhotoGestureHandle.h"

typedef NS_ENUM(NSInteger, ZoomViewScrollDirection) {
    ZoomViewScrollDirectionDefault,
    ZoomViewScrollDirectionLeft,
    ZoomViewScrollDirectionRight
};

@interface KYPhotoBrowserController () <UIScrollViewDelegate, KYPhotoZoomViewDelegate, KYPhotoGestureHandleDelegate>

@property (nonatomic, strong) UIScrollView              *scrollView;
@property (nonatomic, strong) UIView                    *coverView;
@property (nonatomic, strong) UILabel                   *pageLabel;
@property (nonatomic, assign) CGFloat                   lastScrollX;
@property (nonatomic, strong) NSMutableDictionary       *zoomViewCache;
@property (nonatomic, assign) ZoomViewScrollDirection   direction;
@property (nonatomic, strong) KYPhotoGestureHandle      *gestureHandle;

@end

@implementation KYPhotoBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupImages];
    [self initView];
    [self setupGestureHandle];
    [self setupScrollView];
    [self loadImageAtIndex:_currentImageIndex];
    [self loadFirstImage];
}

// 处理images内数据，把images中的数据统一成 KYPhotoModel
- (void)setupImages
{
    NSMutableArray *imagesArray = [NSMutableArray array];
    [_images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if ([obj isKindOfClass:[KYPhotoModel class]]) {
            [imagesArray addObject:obj];
        }
        else if ([obj isKindOfClass:[NSString class]]) {
            KYPhotoModel *model = [[KYPhotoModel alloc] init];
            model.thumbURLString = (NSString *)obj;
            model.originURLString = obj;
            model.originImageSize = 1020312;
            [imagesArray addObject:model];
        }
        else if ([obj isKindOfClass:[UIImage class]]) {
            KYPhotoModel *model = [[KYPhotoModel alloc] init];
            model.image = (UIImage *)obj;
            [imagesArray addObject:model];
        }
        else if ([obj isKindOfClass:[NSData class]]) {
            KYPhotoModel *model = [[KYPhotoModel alloc] init];
            model.image = [UIImage imageWithData:obj];
            [imagesArray addObject:model];
        }
    }];
    
    _images = [imagesArray copy];
}

- (void)initView
{
    _coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    _coverView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_coverView];
    _coverView.alpha = 0;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
    
    _pageLabel = [[UILabel alloc] init];
    _pageLabel.textColor = [UIColor grayColor];
    _pageLabel.backgroundColor = [UIColor clearColor];
    _pageLabel.alpha = 0.8;
    [self.view addSubview:_pageLabel];
}

- (void)setupGestureHandle
{
    _gestureHandle = [[KYPhotoGestureHandle alloc] initWithScrollView:_scrollView coverView:_coverView];
    _gestureHandle.delegate = self;
}

// 设置scrollView
- (void)setupScrollView
{
    if (_currentImageIndex < 0 || _currentImageIndex >= _imageCount) {
        return;
    }
    
    CGFloat scrollW = _scrollView.frame.size.width;
    _scrollView.contentSize = CGSizeMake(scrollW * _imageCount, _scrollView.frame.size.height);
    _scrollView.contentOffset = CGPointMake(scrollW * _currentImageIndex, 0);
    
}

// 加载图片
- (void)loadImageAtIndex:(NSInteger)index
{
    if (index == _currentImageIndex) {
        // 改变指示标记
        [self.pageLabel setText:[NSString stringWithFormat:@"%ld/%ld", (long)_currentImageIndex + 1, (long)_imageCount]];
        [self.pageLabel sizeToFit];
        CGRect frame = self.pageLabel.frame;
        frame.origin.y = [UIScreen mainScreen].bounds.size.height - 10 - frame.size.height;
        frame.origin.x = [UIScreen mainScreen].bounds.size.width - 10 - frame.size.width;
        self.pageLabel.frame = frame;
    }
    if (index > -1 && index < _imageCount && _imageCount-index <= _images.count) {
        CGFloat scrollW = _scrollView.frame.size.width;
        CGRect frame = CGRectMake(index * scrollW, 0, scrollW, _scrollView.frame.size.height);
        KYPhotoModel *photoModel = _images[index];
        KYPhotoZoomView *zoomView = [self.zoomViewCache objectForKey:[NSNumber numberWithInteger:index]];
        if (!zoomView) {
            zoomView = [[KYPhotoZoomView alloc] initWithFrame:frame];
            zoomView.zoomDelegate = self;
            zoomView.frame = frame;
            [_scrollView addSubview:zoomView];
            [self.zoomViewCache setObject:zoomView forKey:[NSNumber numberWithInteger:index]];
        }
        [zoomView resetScale];
        [zoomView showImageWithPhotoModel:photoModel];
    }
}

// 点击进入动画效果
- (void)loadFirstImage
{
    CGRect startRect;
    UIImageView *imageView = nil;
    if ([self.delegate respondsToSelector:@selector(sourceImageViewForIndex:)]) {
        imageView = [self.delegate sourceImageViewForIndex:_currentImageIndex];
    }
    else {
        [UIView animateWithDuration:KYPhotoBrowserShowImageAnimationDuration
                              delay:0
             usingSpringWithDamping:1.f
              initialSpringVelocity:1.f
                            options:0
                         animations:^{
                            _coverView.alpha = 1;
                         }
                         completion:^(BOOL finished) {
                            
                         }];
        
        return;
    }
    
    startRect = [imageView.superview convertRect:imageView.frame toView:self.view];
    UIImage *image = imageView.image;
    if (!image) {
        return;
    }
    UIImageView *tempImageView = [[UIImageView alloc] init];
    tempImageView.image = image;
    tempImageView.frame = startRect;
    [self.view addSubview:tempImageView];
    
    // 目标frame
    CGRect targetRect;
    CGFloat imageWidthHeightRatio = image.size.width / image.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat scrH = [UIScreen mainScreen].bounds.size.height;
    CGFloat height = width / imageWidthHeightRatio;
    CGFloat x = 0;
    CGFloat y;
    if (height > scrH) {
        y = 0;
    }
    else {
        y = (scrH - height ) * 0.5;
    }
    targetRect = CGRectMake(x, y, width, height);
    
    self.scrollView.hidden = YES;
    self.view.alpha = 1.f;
    
    [UIView animateKeyframesWithDuration:KYPhotoBrowserShowImageAnimationDuration delay:0.f options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        
        tempImageView.frame = targetRect;
        _coverView.alpha = 1;
    } completion:^(BOOL finished) {
        
        [tempImageView removeFromSuperview];
        self.scrollView.hidden = NO;
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[KYPhotoBrowserManager sharedManager] dismissWindow:YES];
}

+ (instancetype)showPhotoBrowserWithImages:(NSArray *)images currentImageIndex:(NSInteger)currentImageIndex;
{
    if (!images || ![images isKindOfClass:[NSArray class]] || images.count < 1) {
        return nil;
    }
    
    if (currentImageIndex < 0) {
        currentImageIndex = 0;
    }
    
    KYPhotoBrowserController *vc = [[KYPhotoBrowserController alloc] init];
    vc.images = images;
    vc.imageCount = images.count;
    vc.currentImageIndex = currentImageIndex;
    [[KYPhotoBrowserManager sharedManager] presentWindowWithController:vc];
    return vc;
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _lastScrollX = scrollView.contentOffset.x;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    if (_lastScrollX < scrollView.contentOffset.x) {
        _direction = ZoomViewScrollDirectionRight;
    } else {
        _direction = ZoomViewScrollDirectionLeft;
    }
    NSUInteger page = (NSUInteger) (floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1);
    if (_currentImageIndex != page) {
        _currentImageIndex = page;
        [self loadImageAtIndex:_currentImageIndex];
    }
}

#pragma mark - KYPhotoGestureHandleDelegate
- (KYPhotoZoomView *)currentDetailImageViewInPhotoPreview:(KYPhotoGestureHandle *)handle
{
    KYPhotoZoomView *zoomView = [_zoomViewCache objectForKey:[NSNumber numberWithInteger:_currentImageIndex]];
    return zoomView;
}

- (void)detailImageViewGotoDismiss
{
    KYPhotoZoomView *zoomView = [_zoomViewCache objectForKey:[NSNumber numberWithInteger:_currentImageIndex]];
    [zoomView dismissAnimation:YES];
}

- (void)photoPreviewComponmentHidden:(BOOL)hidden
{
    self.pageLabel.hidden = hidden;
}

#pragma mark - KYPhotoZoomViewDelegate
- (CGRect)dismissRect
{
    CGRect dismissRect;
    UIImageView *imageView = nil;
    if ([self.delegate respondsToSelector:@selector(sourceImageViewForIndex:)]) {
        imageView = [self.delegate sourceImageViewForIndex:_currentImageIndex];
        if (!imageView) {
            return CGRectZero;
        }
    }
    else {
        return CGRectZero;
    }
    
    dismissRect = [imageView.superview convertRect:imageView.frame toView:self.view];
    return dismissRect;
}

- (UIImage *)photoZoomViewPlaceholderImage
{
    if ([self.delegate respondsToSelector:@selector(photoBrowserPlaceholderImage)]) {
        UIImage *image = [self.delegate photoBrowserPlaceholderImage];
        return image;
    }
    return nil;
}

#pragma mark - setter/getter
- (NSMutableDictionary *)zoomViewCache
{
    if (!_zoomViewCache) {
        _zoomViewCache = [NSMutableDictionary dictionary];
    }
    return _zoomViewCache;
}

@end
