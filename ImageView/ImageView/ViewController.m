//
//  ViewController.m
//  ImageView
//
//  Created by sogou-Yan on 17/5/22.
//  Copyright © 2017年 sogou. All rights reserved.
//

#import "ViewController.h"
#import <Accelerate/Accelerate.h>

@interface ViewController ()

@end
//#define image_name @"list_share_imageview_bg"
#define image_name          @"liudehua"
#define image_name_num      0.8
#define image_name_num_low      0.3

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initText];
    [self initImageViewRaw];
    [self initImageViewBoxblur];
    [self initImageViewBoxblurLow];
    [self initImageViewBlurEffect];
}

- (void)initImageViewRaw {
    UIImageView *imageViewBg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 300, 100)];
    imageViewBg.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *image = [UIImage imageNamed:image_name];
    imageViewBg.clipsToBounds = YES;
    imageViewBg.image = image;
    [self.view addSubview:imageViewBg];
}

- (void)initImageViewBoxblur {
    UIImageView *imageViewBg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 120, 300, 100)];
    imageViewBg.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *image = [UIImage imageNamed:image_name];
    image = [self boxblurImage:image withBlurNumber:image_name_num];
    imageViewBg.clipsToBounds = YES;
    imageViewBg.image = image;
    [self.view addSubview:imageViewBg];
}


- (void)initImageViewBoxblurLow {
    UIImageView *imageViewBg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 240, 300, 100)];
    imageViewBg.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *image = [UIImage imageNamed:image_name];
    image = [self boxblurImage:image withBlurNumber:image_name_num_low];
    imageViewBg.clipsToBounds = YES;
    imageViewBg.image = image;
    [self.view addSubview:imageViewBg];
}

- (void)initImageViewBlurEffect {
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = CGRectMake(10, 360, 300, 100);
    [self.view addSubview:effectView];
}


- (UIImage *)coreBlurImage:(UIImage *)image withBlurNumber:(CGFloat)blur {
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage= [CIImage imageWithCGImage:image.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:@(blur) forKey: @"inputRadius"];
    CIImage *result=[filter valueForKey:kCIOutputImageKey];
    CGImageRef outImage=[context createCGImage:result fromRect:[result extent]];
    UIImage *blurImage=[UIImage imageWithCGImage:outImage];
    CGImageRelease(outImage);
    return blurImage;
}
- (UIImage *)boxblurImage:(UIImage *)image withBlurNumber:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    
    void *pixelBuffer;
    //从CGImage中获取数据
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    //设置从CGImage获取对象的属性
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) *
                         CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}
- (void)initText {
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    label.text = @"从前在北平读书的时候，老在城圈儿里呆着。四年中虽也游过三五回西山，却从没来过清华；说起清华，只觉得很远很远而已。那时也不认识清华人，有一回北大和清华学生在青年会举行英语辩论，我也去听。清华的英语确是流利得多，他们胜了。那回的题目和内容，已忘记干净；只记得复辩时，清华那位领袖很神气，引着孔子的什么话。北大答辩时，开头就用了fｕｒｉｏｕｓｌｙ一个字叙述这位领袖的态度。这个字也许太过，但也道着一点儿。那天清华学生是坐大汽车进城的，车便停在青年会前头；那时大汽车还很少。那是冬末春初，天很冷。一位清华学生在屋里只穿单大褂，将出门却套上厚厚的皮大氅。这种“行”和“衣”的路数，在当时却透着一股标劲儿。初来清华，在十四年夏天。刚从南方来北平，住在朝阳门边一个朋友家。那时教务长是张仲述先生，我们没见面。我写信给他，约定第三天上午去看他。写信时也和那位朋友商量过，十点赶得到清华么，从朝阳门哪儿？他那时已经来过一次，但似乎只记得“长林碧草”从前在北平读书的时候，老在城圈儿里呆着。四年中虽也游过三五回西山，却从没来过清华；说起清华，只觉得很远很远而已。那时也不认识清华人，有一回北大和清华学生在青年会举行英语辩论，我也去听。清华的英语确是流利得多，他们胜了。那回的题目和内容，已忘记干净；只记得复辩时，清华那位领袖很神气，引着孔子的什么话。北大答辩时，开头就用了fｕｒｉｏｕｓｌｙ一个字叙述这位领袖的态度。这个字也许太过，但也道着一点儿。那天清华学生是坐大汽车进城的，车便停在青年会前头；那时大汽车还很少。那是冬末春初，天很冷。一位清华学生在屋里只穿单大褂，将出门却套上厚厚的皮大氅。这种“行”和“衣”的路数，在当时却透着一股标劲儿。初来清华，在十四年夏天。刚从南方来北平，住在朝阳门边一个朋友家。那时教务长是张仲述先生，我们没见面。我写信给他，约定第三天上午去看他。写信时也和那位朋友商量过，十点赶得到清华么，从朝阳门哪儿？他那时已经来过一次，但似乎只记得“长林碧草”从前在北平读书的时候，老在城圈儿里呆着。四年中虽也游过三五回西山，却从没来过清华；说起清华，只觉得很远很远而已。那时也不认识清华人，有一回北大和清华学生在青年会举行英语辩论，我也去听。清华的英语确是流利得多，他们胜了。那回的题目和内容，已忘记干净；只记得复辩时，清华那位领袖很神气，引着孔子的什么话。北大答辩时，开头就用了fｕｒｉｏｕｓｌｙ一个字叙述这位领袖的态度。这个字也许太过，但也道着一点儿。那天清华学生是坐大汽车进城的，车便停在青年会前头；那时大汽车还很少。那是冬末春初，天很冷。一位清华学生在屋里只穿单大褂，将出门却套上厚厚的皮大氅。这种“行”和“衣”的路数，在当时却透着一股标劲儿。初来清华，在十四年夏天。刚从南方来北平，住在朝阳门边一个朋友家。那时教务长是张仲述先生，我们没见面。我写信给他，约定第三天上午去看他。写信时也和那位朋友商量过，十点赶得到清华么，从朝阳门哪儿？他那时已经来过一次，但似乎只记得“长林碧草";
    label.numberOfLines = 0;
    [self.view addSubview:label];
}

@end
