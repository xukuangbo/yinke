//
//  MiaowLiveModel.m
//  yingke
//
//  Created by 夏明伟 on 2016/11/3.
//  Copyright © 2016年 夏明伟. All rights reserved.
//

#import "MiaowLiveModel.h"

@implementation MiaowLiveModel

//星级图标
- (UIImage *)starImage
{
    if (self.starlevel) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"girl_star%ld_40x19", self.starlevel]];
    }
    return nil;
}
@end
