//
//  RPUserInfo.h
//  Description
//
//  Created by Mr.Yang on 2017/4/21.
//  Copyright © 2017年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RPUserInfo : NSObject

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *avatar;

+ (RPUserInfo *)userInfoWithUserID:(NSString *)userID
                          UserName:(NSString *)userName
                         andAvatar:(NSString *)avatar;

@end

