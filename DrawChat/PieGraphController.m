//
//  PieGraphController.m
//  DrawChat
//  
//  Created by 冯万琦 on 2017/1/18.
//  Copyright © 2017年 yidian. All rights reserved.
//

#import "PieGraphController.h"
#import "WQPieGraphView.h"

@interface PieGraphController ()

@end

@implementation PieGraphController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *dictionary = [self resourcePlistWithSourceName:@"WQLineGraphData"];
    [self initWQPieGraphWithDataDict:[NSMutableDictionary dictionaryWithDictionary:dictionary]];
}
//初始化饼状图
-(void)initWQPieGraphWithDataDict:(NSMutableDictionary*)dataDict
{
    WQPieGraphView *pie = [[WQPieGraphView alloc] initWithFrame:self.view.bounds colorsArray:@[@{@"RED":@"155",@"GREEN":@"193",@"BLUE":@"68",@"ALPHA":@"1"},@{@"RED":@"165",@"GREEN":@"43",@"BLUE":@"19",@"ALPHA":@"1"}] ValuesDict:@{@"iphone":@20,@"sybian":@50,@"windowbile":@60,@"mego":@80,@"android":@90}];
    [self.view addSubview:pie];
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
