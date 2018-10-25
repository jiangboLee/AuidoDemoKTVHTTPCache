//
//  TableViewCell.h
//  AuidoDemo
//
//  Created by Lee on 2018/10/24.
//  Copyright © 2018 Lee. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface TableViewCell : UITableViewCell
typedef void(^ClickBlock)(TableViewCell *, NSString *);

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) ClickBlock clickBlock;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

NS_ASSUME_NONNULL_END
