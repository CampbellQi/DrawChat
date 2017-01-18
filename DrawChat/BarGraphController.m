//
//  BarGraphController.m
//  DrawChat
//
//  Created by 冯万琦 on 2017/1/18.
//  Copyright © 2017年 yidian. All rights reserved.
//

#import "BarGraphController.h"
#import "WQBarGraphView.h"

@interface BarGraphController ()

@end

@implementation BarGraphController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //NSLog(@"dictionary = %@",dictionary);
    NSDictionary *dictionary = [self resourcePlistWithSourceName:@"BarGraphData"];
    [self initWQBarGraphWithDataDict:[NSMutableDictionary dictionaryWithDictionary:dictionary]];
    
    
}

-(void)initWQBarGraphWithDataDict:(NSMutableDictionary *)dataDict
{
    NSString *suffix = [dataDict objectForKey:SUFFIX];
    [dataDict removeObjectForKey:SUFFIX];
    WQBarGraphView *view = [[WQBarGraphView alloc] initWithFrame:self.view.bounds ThemAttributs:
                            @{
                              bXAxisLabelFontKey: [UIFont systemFontOfSize:12.0f],
                              bXAxisLabelColorKey:[UIColor blackColor],
                              bYAxisCatLineColorKey:[UIColor blackColor],
                              bYAxisLabelColorKey:[UIColor blackColor],
                              bBarTitleLabelFontKey:[UIFont systemFontOfSize:10.0f],
                              bBarColorArrayKey:@[@{@"RED":@"155",@"GREEN":@"193",@"BLUE":@"68",@"ALPHA":@"1"},@{@"RED":@"165",@"GREEN":@"43",@"BLUE":@"19",@"ALPHA":@"1"}, @{@"RED":@"15",@"GREEN":@"103",@"BLUE":@"88",@"ALPHA":@"1"}],
                              bYAxisSuffix:suffix,
                              bYAxisLabelFontKey:[UIFont systemFontOfSize:12.0f]
                              } ValuesDict:dataDict];
    
    self.contentSV.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) + 50);
    [self.contentSV addSubview:view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
