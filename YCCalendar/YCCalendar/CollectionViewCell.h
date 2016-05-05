//
//  CollectionViewCell.h
//  horizontalScrollView
//
//  Created by YiChe on 16/4/21.
//  Copyright © 2016年 YiChe. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TextLabelHeight(view) (view.frame.size.height-16)

@interface CollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
@end
