//
//  CollectionViewCell.m
//  horizontalScrollView
//
//  Created by YiChe on 16/4/21.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.textLabel.layer.masksToBounds = YES;
//    self.textLabel.layer.borderColor
//    self.textLabel.adjustsFontSizeToFitWidth = YES;
    
    self.pointLabel.layer.masksToBounds = YES;
    self.pointLabel.layer.cornerRadius = 6/2;
    self.pointLabel.hidden = YES;
}

@end
