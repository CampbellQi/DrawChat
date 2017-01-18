//
//  WQLineGraphView.h
//  DataService
//
//  Created by UWINY on 14-6-11.
//  Copyright (c) 2014年 Test. All rights reserved.
//

#import <UIKit/UIKit.h>
enum AEnum
{
    sdf=0,
    sdf1
};
@interface WQLineGraphView : UIView

-(id)initWithFrame:(CGRect)frame ThemAttributs:(NSDictionary *)aDic ValuesDict:(NSDictionary *)adict;

UIKIT_EXTERN NSString *const wXAxisLabelFontKey;
UIKIT_EXTERN NSString *const wXAxisLabelColorKey;
UIKIT_EXTERN NSString *const wYAxisLabelFontKey;
UIKIT_EXTERN NSString *const wYAxisLabelColorKey;
//分割线颜色
UIKIT_EXTERN NSString *const wYAxisCatLineColorKey;
//折线颜色
UIKIT_EXTERN NSString *const wPloyLineColorArrayKey;
//Y轴后缀
UIKIT_EXTERN NSString *const wYAxisSuffix;
@end
