//
//  HomeCell.h
//  KYPhotoBrowser
//
//  Created by Cuikeyi on 2017/8/2.
//  Copyright © 2017年 Cuikeyi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *imageView;
- (void)updateImage:(UIImage *)image;
- (void)updateImageURL:(NSString *)URLString;

@end
