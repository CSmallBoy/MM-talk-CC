//
//  HCShowMoreImage.m
//  Project
//
//  Created by 陈福杰 on 16/2/25.
//  Copyright © 2016年 com.xxx. All rights reserved.
//

#import "HCShowMoreImage.h"
#import "UIButton+WebCache.h"

@implementation HCShowMoreImage

- (void)handleButton:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(hchomeMoreImgView:)])
    {
        [self.delegate hchomeMoreImgView:button.tag];
    }
}

//图片赋值  每一个图片都是一个button
- (void)setImageUrlArr:(NSArray *)imageUrlArr
{
    _imageUrlArr = imageUrlArr;
    
    [self removeAllSubviews];
    
    CGFloat buttonW = (SCREEN_WIDTH-20)*0.33;
    for (NSInteger i = 0; i < imageUrlArr.count; i++)
    {
        if (i < 9)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i;
            [button addTarget:self action:@selector(handleButton:) forControlEvents:UIControlEventTouchUpInside];
            CGFloat buttonX = 0;
            CGFloat buttonY = 0;
            if (imageUrlArr.count < 5)
            {
                NSInteger col = i%3;
                NSInteger row = i/3;
                if(imageUrlArr.count==3){
                    buttonY = 0 * buttonW + (row+1)*5;
                }else{
                    buttonY = row * buttonW + (row+1)*5;
                }
                buttonX = col * buttonW + (col+1)*5;
                
            }else
            {
                NSInteger col = i%3;
                NSInteger row = i/3;
                buttonX = col = col * buttonW + (col+1)*5;
                buttonY = row * buttonW + (row+1)*5;
            }
            button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonW);
            UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH-20)/3, (SCREEN_WIDTH-20)/3)];
            imageview.contentMode = UIViewContentModeScaleAspectFill;
            imageview.clipsToBounds  = YES;
            [imageview sd_setImageWithURL:[readUserInfo url:imageUrlArr[i] :kkTimes]];
            imageview.frame = button.bounds;
          //[button sd_setImageWithURL:[readUserInfo url:imageUrlArr[i] :kkTimes] forState:UIControlStateNormal placeholderImage:OrigIMG(@"publish_picture")];
            [button addSubview:imageview];
            //[button sd_setImageWithURL:[NSURL URLWithString:imageUrlArr[i]] forState:UIControlStateNormal placeholderImage:OrigIMG(@"publish_picture")];
            [self addSubview:button];
        }
    }
}

@end
