//
//  WQLineGraphView.h
//  DataService
//
//  Created by UWINY on 14-6-11.
//  Copyright (c) 2014年 Test. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WQBarGraphView : UIView

-(id)initWithFrame:(CGRect)frame ThemAttributs:(NSDictionary *)tADict ValuesDict:(NSDictionary *)valueDict;

UIKIT_EXTERN NSString *const bXAxisLabelFontKey;
UIKIT_EXTERN NSString *const bXAxisLabelColorKey;
UIKIT_EXTERN NSString *const bYAxisLabelFontKey;
UIKIT_EXTERN NSString *const bYAxisLabelColorKey;
//分割线颜色
UIKIT_EXTERN NSString *const bYAxisCatLineColorKey;
//柱颜色
UIKIT_EXTERN NSString *const bBarColorArrayKey;
//Y轴后缀
UIKIT_EXTERN NSString *const bYAxisSuffix;
//柱标题
UIKIT_EXTERN NSString *const bBarTitleLabelFontKey;
@end
