//
//  HomeCell.m
//  KYPhotoBrowser
//
//  Created by Cuikeyi on 2017/8/2.
//  Copyright © 2017年 Cuikeyi. All rights reserved.
//

#import "HomeCell.h"
#import <YYWebImage.h>

@interface HomeCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation HomeCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    return self;
}

- (void)initView
{
    _imageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_imageView];
}

- (void)updateImage:(UIImage *)image;
{
    _imageView.image = image;
}

- (void)updateImageURL:(NSString *)URLString
{
    [_imageView yy_setImageWithURL:[NSURL URLWithString:URLString] options:kNilOptions];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = self.contentView.bounds;
}

@end
