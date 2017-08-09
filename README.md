# KYPhotoBrowser
APP中图片浏览功能是比较常见的，为了使用方便，自己封装了一个，仅供大家参考。主要的功能有：

1、动画效果放大先看几张效果图吧。
![image](http://upload-images.jianshu.io/upload_images/4320310-a73c20bc2ce524bb.gif?imageMogr2/auto-orient/strip)
2、点击指定区域放大
![image](http://upload-images.jianshu.io/upload_images/4320310-e5130b78618ff258.gif?imageMogr2/auto-orient/strip)
3、下拉退出
![image](http://upload-images.jianshu.io/upload_images/4320310-38942bff76511462.gif?imageMogr2/auto-orient/strip)
### 一、集成方法
##### 1、pod集成
```
pod 'CKYPhotoBrowser'
```
如果提示`not found`之类的提示，先使用 `pod search CKYPhotoBrowser` 去查找一下，若提示
```
[!] Unable to find a pod with name, author, summary, or description matching `CKYPhotoBrowser`
```
此时需要更新本地的pod空间，终端执行指令 `pod repo update`，成功之后，在执行`pod search CKYBrowser`，若还是没有找到，需删除pod本地缓存，执行`rm ~/Library/Caches/CocoaPods/search_index.json`，之后在执行`pod search CKYBrowser`。如果还是没有成功，那就请留言吧，一般情况，到这里一定是成功的了。

##### 2、源码集成
github下载地址：https://github.com/cky113999742/KYPhotoBrowser
下载完成，直接拖进工程里，如果工程中没有YYWebImage，需要手动去添加这个库，如果使用SDWebImage，可以直接修改源码，替换掉YYWebImage，个人觉得YYWebImage性能更好一些，尤其是在iPhone 7上的表现。

### 二、简单使用 
使用时，只需要引用 KYPhotoBrowserController.h 即可。
```objc
    NSArray *images = @[@"http://ohc6xoujj.bkt.clouddn.com/image_1.jpg", @"http://ohc6xoujj.bkt.clouddn.com/image_2.jpg"];
    [KYPhotoBrowserController showPhotoBrowserWithImages:images currentImageIndex:indexPath.item delegate:self];
```
如果需要实现动画出现和消失回到原位的效果，需要实现代理方法：
```
// 动画消失的目标frame
- (UIImageView *)sourceImageViewForIndex:(NSInteger)index;
```
返回指定位置的 UIImageView，这个UIImageView就是当前正在显示的那张图片，只是用于获取他在试图中的坐标位置。使用就是这几行代码就可以了， KYPhotoBrowserController 类中暴露了两个只读属性`scrollView`和`pageLabel`，暴露的目的是如果使用者不需要页码指示器时候，可以通过实现 customUIBlock 进行相应的隐藏或者调整坐标， `scrollView`是方便用户对手势进行扩展，比如需要添加长按手势，手势可以添加在scrollView上，在外部实现自己的手势方法，达到扩展的需求。

### 三、 代码结构
##### 1、KYPhotoBrowserController
```
#import <UIKit/UIKit.h>
#import "KYPhotoModel.h"

@class KYPhotoBrowserController;
typedef void(^KYCustomUIBlock)(KYPhotoBrowserController *vc);

@protocol KYPhotoBrowserControllerDelegate <NSObject>

@optional
// 动画消失的目标frame
- (UIImageView *)sourceImageViewForIndex:(NSInteger)index;
// 获取图片展示占位图
- (UIImage *)photoBrowserPlaceholderImage;

@end

@interface KYPhotoBrowserController : UIViewController

@property (nonatomic, copy) KYCustomUIBlock customUIBlock;  /**< 在viewDidLoad的最后调用，方便用户自定义UI */
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
```
这个类是使用者直接调用的类，内部持有`scrollView`实现横滑效果，`scrollView`上添加的是`KYPhotoZoomView`,这个控件是继承自`UIScrollView`，内部持有一个`UIImageView`用于实现图片的展示和放大功能。`KYPhotoBrowserController`初始化时传递的图片数组，数据类型支持`KYPhotoModel`， `NSImage`， `NSString`， `NSData`。
##### 2、KYPhotoModel
```objc
@property (nonatomic, strong) NSData        *imageData;         /**< 图片数据 */
@property (nonatomic, strong) UIImage       *image;             /**< 图片数据 */
@property (nonatomic, strong) NSString      *thumbURLString;    /**< 普通图下载链接 */
@property (nonatomic, strong) NSString      *originURLString;   /**< 原图下载链接 */
@property (nonatomic, assign) CGFloat       originImageSize;    /**< 原图的大小，单位为 B */
```
存放图片数据的模型类，图片的加载顺序为：先检测原图，如果本地已经存在原图数据，直接加载原图数据，如果不存在原图数据，直接去检测普通图片，如果存在网址，加载普通图片，如果不存在，加载ImageData和Image的数据。原图的数据，只有在用户点击了加载原图的按钮，才会去加载。
##### 3、KYPhotoZoomView
```objc
#import <UIKit/UIKit.h>
#import "KYPhotoModel.h"
#if __has_include(<YYWebImage/YYWebImage.h>)
#import <YYWebImage/YYWebImage.h>
#else
#import "YYWebImage.h"
#endif

typedef NS_ENUM(NSInteger, ShowImageState) {
    ShowImageStateSmall,    // 初始化默认是小图
    ShowImageStateBig,   // 全屏的正常图片
    ShowImageStateOrigin    // 原图
};

@class KYPhotoZoomView;
@protocol KYPhotoZoomViewDelegate <NSObject>

- (CGRect)dismissRect;
- (UIImage *)photoZoomViewPlaceholderImage;

@end

@interface KYPhotoZoomView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, weak) id <KYPhotoZoomViewDelegate> zoomDelegate;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, assign, readonly) ShowImageState imageState;
@property (nonatomic, assign) CGFloat process;

- (void)resetScale;
- (void)showImageWithPhotoModel:(KYPhotoModel *)photoModel;
- (void)dismissAnimation:(BOOL)animation;

@end
```
这个类是图片展示类，内部持有一个ImageView，这个类的主要作用是实现图片的展示、放大缩小的效果。
##### 4、KYPhotoGestureHandle
```objc
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class KYPhotoZoomView, KYPhotoGestureHandle;

@protocol KYPhotoGestureHandleDelegate <NSObject>
// 获取当前展示的图片对象
- (KYPhotoZoomView *)currentDetailImageViewInPhotoPreview:(KYPhotoGestureHandle *)handle;
// 图片对象去移除的代理
- (void)detailImageViewGotoDismiss;
// 控制图片控制器中，照片墙，更多等小组件的隐藏/显示
- (void)photoPreviewComponmentHidden:(BOOL)hidden;

@end

@interface KYPhotoGestureHandle : NSObject

@property (nonatomic, weak) id <KYPhotoGestureHandleDelegate> delegate;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView coverView:(UIView *)coverView;

@end
```
这个类是下拉退出效果的手势处理类，下拉图片跟随移动缩小的功能的实现，是通过下拉开始时，改变图片的锚点，以达到图片跟手缩小移动的效果，在用户松手的时候，如果缩放比例大于0.80，或者下拉速度大于800，就会退出界面。手势结束的时候，修改锚点为默认的0.5，如果是退出，执行退出的动画，如果不是退出，还原图片。
##### 5、KYPhotoBrowserManager
```objc
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
```
这个类用于PhotoBrowser的展示和退出管理，PhotoBrowser是单独使用一个Window进行退出的，不需要使用者提供任何的控制器用于推出界面，方便使用者使用。
