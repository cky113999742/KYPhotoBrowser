//
//  HomeViewController.m
//  KYPhotoBrowser
//
//  Created by Cuikeyi on 2017/8/2.
//  Copyright © 2017年 Cuikeyi. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeCell.h"
#import "KYPhotoBrowserController.h"

@interface HomeViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, KYPhotoBrowserControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *imageArray;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

- (void)initView
{
    
    self.view.backgroundColor = [UIColor whiteColor];
    CGFloat scr_w = [UIScreen mainScreen].bounds.size.width;
    CGFloat scr_h = [UIScreen mainScreen].bounds.size.height;
    CGRect frame = CGRectMake(0, 0, scr_w, scr_h);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    [_collectionView registerClass:[HomeCell class] forCellWithReuseIdentifier:@"HomeCell"];\
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    HomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCell" forIndexPath:indexPath];
    NSObject *obj = _imageArray[indexPath.item];
    if ([obj isKindOfClass:[UIImage class]]) {
        [cell updateImage:(UIImage *)obj];
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        [cell updateImageURL:(NSString *)obj];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width/3-15;
    return CGSizeMake(width, width);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSArray *images = @[@"http://ohc6xoujj.bkt.clouddn.com/image_1.jpg", @"http://ohc6xoujj.bkt.clouddn.com/image_2.jpg", @"http://ohc6xoujj.bkt.clouddn.com/image_3.jpg", @"http://ohc6xoujj.bkt.clouddn.com/image_4.jpeg", @"http://ohc6xoujj.bkt.clouddn.com/image_5.jpeg", @"http://ohc6xoujj.bkt.clouddn.com/image_6.jpeg"];
    [KYPhotoBrowserController showPhotoBrowserWithImages:images currentImageIndex:indexPath.item delegate:self];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (UIImageView *)sourceImageViewForIndex:(NSInteger)index
{
    HomeCell *cell = (HomeCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    if (cell) {
        
        return cell.imageView;
    }
    return nil;
}

- (NSMutableArray *)imageArray
{
    if (!_imageArray) {
        NSArray *images = @[@"http://ohc6xoujj.bkt.clouddn.com/image_1.jpg", @"http://ohc6xoujj.bkt.clouddn.com/image_2.jpg", @"http://ohc6xoujj.bkt.clouddn.com/image_3.jpg", @"http://ohc6xoujj.bkt.clouddn.com/image_4.jpeg", @"http://ohc6xoujj.bkt.clouddn.com/image_5.jpeg", @"http://ohc6xoujj.bkt.clouddn.com/image_6.jpeg"];
//        UIImage *image1 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_1" ofType:@"jpg"]];
//        UIImage *image2 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_2" ofType:@"jpg"]];
//        UIImage *image3 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_3" ofType:@"jpg"]];
//        UIImage *image4 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_4" ofType:@"jpeg"]];
//        UIImage *image5 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_5" ofType:@"jpeg"]];
//        UIImage *image6 = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_6" ofType:@"jpeg"]];
//        NSArray *images = @[image1, image2, image3, image4, image5, image6];
        _imageArray = [NSMutableArray arrayWithArray:images];
    }
    return _imageArray;
}


@end
