//
//  WQGaugeGraphView.h
//  DataService
//
//  Created by UWINY on 14-6-17.
//  Copyright (c) 2014年 Test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WQGaugeGraphView : UIView

@property (nonatomic,retain) UIImage *gaugeView;
@property (nonatomic,retain) UIImageView *pointer;
-(id)initWithFrame:(CGRect)frame ThemAttributs:(NSDictionary *)themAttributs Value:(float)value;
//后缀
UIKIT_EXTERN NSString *const gSuffix;
//名称
UIKIT_EXTERN NSString *const gName;
//最大值
UIKIT_EXTERN  NSString *const gMaxValue;
//最小值
UIKIT_EXTERN NSString *const gMinValue;
//分割的数字标题数量
UIKIT_EXTERN NSString *const gLabelNum;

-(void)setGaugeValue:(CGFloat)aValue animation:(BOOL)isAnim;
@end
