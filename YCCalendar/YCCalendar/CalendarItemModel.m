//
//  CalendarItemModel.m
//  YCCalendar
//
//  Created by YiChe on 16/5/4.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "CalendarItemModel.h"

@implementation CalendarItemModel

- (instancetype)initWithDate:(NSDate *)date
                   textColor:(UIColor *)textcolor
                   backColor:(UIColor *)backcolor
             selectTextColor:(UIColor *)selectTextcolor
             selectBackColor:(UIColor *)selectBackcolor
                    haveData:(BOOL)haveData
                    selected:(BOOL)selected
{
    self = [super init];
    if (self) {
        self.date = date;
        self.textcolor = textcolor;
        self.backcolor = backcolor?backcolor:[UIColor whiteColor];
        self.selectTextcolor = selectTextcolor?selectTextcolor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        self.selectBackcolor = selectBackcolor?selectBackcolor:[UIColor colorWithRed:0.0381 green:0.4781 blue:0.9393 alpha:1.0];
        self.haveData = haveData;
        self.selected = selected;
    }
    return self;
}
@end
