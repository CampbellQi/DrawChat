//
//  BaseViewController.h
//  DrawChat
//
//  Created by 冯万琦 on 2017/1/18.
//  Copyright © 2017年 yidian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WQChatHeader.h"

@interface BaseViewController : UIViewController
//获取数据plist文件
- (NSDictionary *) resourcePlistWithSourceName:(NSString *)name;
@end
