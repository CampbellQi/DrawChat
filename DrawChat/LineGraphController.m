//
//  LineGraphController.m
//  DrawChat

//  Created by 冯万琦 on 2017/1/18.
//  Copyright © 2017年 yidian. All rights reserved.
//

#import "LineGraphController.h"
#import "WQLineGraphView.h"

@interface LineGraphController ()

@end

@implementation LineGraphController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary *dictionary = [self resourcePlistWithSourceName:@"WQLineGraphData"];
    [self initWQLineGraphWithDataDict:[NSMutableDictionary dictionaryWithDictionary:dictionary]];
}
-(void)initWQLineGraphWithDataDict:(NSMutableDictionary *)dataDict
{
    NSString *suffix = [dataDict objectForKey:SUFFIX];
    [dataDict removeObjectForKey:SUFFIX];
    
    WQLineGraphView *view = [[WQLineGraphView alloc] initWithFrame:self.view.bounds ThemAttributs:
                             @{
                               wXAxisLabelFontKey: [UIFont systemFontOfSize:12.0f],
                               wXAxisLabelColorKey:[UIColor blackColor],
                               wYAxisCatLineColorKey:[UIColor grayColor],
                               wYAxisLabelColorKey:[UIColor blackColor],
                               wPloyLineColorArrayKey:@[[UIColor redColor],[UIColor greenColor]],
                               wYAxisSuffix:suffix,
                               wYAxisLabelFontKey:[UIFont systemFontOfSize:12.0f]
                               } ValuesDict:dataDict ];
    [self.view addSubview:view];
    
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
