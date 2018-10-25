//
//  TableViewCell.m
//  AuidoDemo
//
//  Created by Lee on 2018/10/24.
//  Copyright © 2018 Lee. All rights reserved.
//

#import "TableViewCell.h"
#import <AVFoundation/AVFoundation.h>

@interface TableViewCell ()

@end

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setupUI];
}


- (void)setupUI {
    self.bgView.backgroundColor = [UIColor blueColor];
    
}

- (void)setUrl:(NSString *)url {
    _url = url;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.activityIndicator startAnimating];
    if (self.clickBlock) {
        self.clickBlock(self, _url);
    }
    
}
 

@end
