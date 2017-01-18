//
//  WQPieGraphView.m
//  DataService
//
//  Created by UWINY on 14-6-16.
//  Copyright (c) 2014年 Test. All rights reserved.
//

static float MARGIN_TOP = 40;
static float MARGIN_BOTTOM = 40;
static float MARGIN_LEFT = 60;
static float MARGIN_RIGHT = 260;

#define K_PI 3.1415
#define KDGREED(x) ((x)  * K_PI * 2)

#import "WQPieGraphView.h"

@interface WQPieGraphView()

@property (nonatomic,retain)NSArray *colorsArray;
@property (nonatomic,retain)NSDictionary *valuesDict;

@end

@implementation WQPieGraphView
{
    float _scaleY;
    float _spaceHeight;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame colorsArray:(NSArray *)colorsArray ValuesDict:(NSDictionary *)valuesDict
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        self.colorsArray = colorsArray;
        //NSLog(@"colorsArray0 = %@",_colorsArray);
        self.valuesDict = valuesDict;
        if (self.colorsArray.count != [self.valuesDict allKeys].count) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"ColorRatio" ofType:@"plist"];
            self.colorsArray = [NSArray arrayWithContentsOfFile:path];
            //NSLog(@"colorsArray1 = %@",_colorsArray);
        }
        _scaleY = 0.4;
        _spaceHeight = 40;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    
    NSArray *keysArray = [self.valuesDict allKeys];
    //NSLog(@"keysArray=%@",keysArray);
    float sum = 0;
    for (int i=0; i<keysArray.count; i++) {
        sum += [[self.valuesDict objectForKey:[keysArray objectAtIndex:i]] floatValue];
    }
    //NSLog(@"sum = %f",sum);
    //计算中心点,半径
    float xSpace = (self.frame.size.width-MARGIN_LEFT-MARGIN_RIGHT);
    float ySpace = (self.frame.size.height-MARGIN_TOP-MARGIN_BOTTOM);
    float pointX = MARGIN_LEFT+xSpace/2;
    float pointY =  MARGIN_TOP+ySpace/2;
    //NSLog(@"ySpace = %f",ySpace);
    float radius = xSpace>ySpace?ySpace/2:xSpace/2;
    _spaceHeight = radius*0.2;
    CGContextMoveToPoint(context, pointX, pointY);
    
    CGContextSaveGState(context);
    CGContextScaleCTM(context, 1.0, _scaleY);
    
    float currentAngle = 0.0f;
    //NSLog(@"keysArray.count = %d",keysArray.count);
    for (int i=0; i<keysArray.count; i++) {
        float startAngle = KDGREED(currentAngle);
        //NSLog(@"[keysArray objectAtIndex:i] = %@",[keysArray objectAtIndex:i]);
        //NSLog(@"%@",[self.valuesDict objectForKey:[keysArray objectAtIndex:i]]);
        currentAngle += ([[self.valuesDict objectForKey:[keysArray objectAtIndex:i]] floatValue]/sum);
        //NSLog(@"currentAngle = %f",currentAngle);
        float endAngle = KDGREED(currentAngle);
        
        //绘制上面的扇形
        CGContextMoveToPoint(context, pointX, pointY);
        
        NSDictionary *colorDic = [self.colorsArray objectAtIndex:i];
        //NSLog(@"colorDic = %@",colorDic);
        UIColor *fillColor = [UIColor colorWithRed:[[colorDic objectForKey:@"RED"] floatValue]/255.0f green:[[colorDic objectForKey:@"GREEN"] floatValue]/255.0f blue:[[colorDic objectForKey:@"BLUE"] floatValue]/255.0f alpha:[[colorDic objectForKey:@"ALPHA"] floatValue]];
        
        [fillColor setFill];
        [[UIColor colorWithWhite:1.0 alpha:0.8] setStroke];
        
        CGContextAddArc(context, pointX, pointY, radius, startAngle, endAngle, 0);
        CGContextClosePath(context);
        CGContextDrawPath(context, kCGPathFill);
        
        //        //绘制字体
        //        float origionx = self.frame.size.width-MARGIN_RIGHT;
        //		float origiony = i * 50 + MARGIN_TOP;
        //
        //		[fillColor setFill];
        //
        //		CGContextFillRect(context, CGRectMake(origionx, origiony, 20, 20));
        //		CGContextDrawPath(context, kCGPathFill);
        //
        //        NSString *title = [ keysArray objectAtIndex:i];
        //        [title drawAtPoint:CGPointMake(origionx + 50, origiony) withFont:[UIFont systemFontOfSize:16]];
        
        //绘制侧面
        float starx = cos(startAngle) * radius+pointX;
        float stary = sin(startAngle) * radius+pointY;
        
        float endx = cos(endAngle) * radius + pointX;
        float endy = sin(endAngle) * radius + pointY;
        
        //float starty1 = stary + spaceHeight;
        float endy1 = endy + _spaceHeight;
        
        //NSLog(@"startAngle = %f",startAngle);
        if(endAngle < K_PI)
        {
        }
        
        //只有弧度《 3.14 的才会画前面的厚度
        else if(startAngle < K_PI)
        {
            endAngle = K_PI;
            endx = pointX-radius;
            endy1 = pointY+_spaceHeight;
        }
        
        else
            continue;
        
        //绘制厚度
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, starx, stary);
        CGPathAddArc(path, nil, pointX, pointY, radius, startAngle, endAngle, 0);
        CGPathAddLineToPoint(path, nil, endx, endy1);
        
        CGPathAddArc(path, nil, pointX, pointY + _spaceHeight, radius, endAngle, startAngle, 1);
        CGContextAddPath(context, path);
        
        
        
        [fillColor setFill];
        [[UIColor colorWithWhite:0.9 alpha:1.0] setStroke];
        
        CGContextDrawPath(context, kCGPathFill);
        
        [[UIColor colorWithWhite:0.1 alpha:0.4] setFill];
        CGContextAddPath(context, path);
        CGContextDrawPath(context, kCGPathFill);
        
        
    }
    
    //整体渐变
    CGFloat componets [] = {0.0, 0.0, 0.0, 0.5,0.0,0.0,0.0,0.1};
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, componets, nil, 2);
    
    CGContextDrawRadialGradient(context, gradient, CGPointMake(pointX,pointY), 0, CGPointMake(pointX,pointY), radius, 0 );
    
    CFRelease(colorspace);
    CGGradientRelease(gradient);
    
    CGContextRestoreGState(context);
    //绘制文字
    
    for(int i = 0; i< [keysArray count]; i++)
    {
        float origionx = self.frame.size.width-MARGIN_RIGHT;
        float origiony = i * 30 + MARGIN_TOP;
        
        NSDictionary *colorDic = [self.colorsArray objectAtIndex:i];
        //NSLog(@"colorDic = %@",colorDic);
        UIColor *fillColor = [UIColor colorWithRed:[[colorDic objectForKey:@"RED"] floatValue]/255.0f green:[[colorDic objectForKey:@"GREEN"] floatValue]/255.0f blue:[[colorDic objectForKey:@"BLUE"] floatValue]/255.0f alpha:[[colorDic objectForKey:@"ALPHA"] floatValue]];
        [fillColor setFill];
        //[[colorArr objectAtIndex:i %  [valueArr count]] setFill];
        
        CGContextFillRect(context, CGRectMake(origionx, origiony, 20, 20));
        CGContextDrawPath(context, kCGPathFill);
        
        
        if(i< [keysArray count])
        {
            //NSLog(@"sum = %f",sum);
            //NSLog(@"[self.valuesDict objectForKey:[keysArray objectAtIndex:i]] = %@",[self.valuesDict objectForKey:[keysArray objectAtIndex:i]]);
            float rate = [[self.valuesDict objectForKey:[keysArray objectAtIndex:i]] floatValue]/sum;
            //            if ((int)ceil(rate*1000)%10<5) {
            //                NSLog(@"rate = %.2f",rate);
            //                rate = floor(rate*1000);
            //            }
            
            NSString *title = [NSString stringWithFormat:@"%@：%.1f%@",[keysArray objectAtIndex:i],rate*100,@"%"];
            
            [title drawAtPoint:CGPointMake(origionx + 50, origiony) withFont:[UIFont systemFontOfSize:16]];
            
        }
        
    }
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
