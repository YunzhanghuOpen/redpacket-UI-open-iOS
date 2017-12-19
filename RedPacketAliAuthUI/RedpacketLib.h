//
//  RedpacketLib.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/9/20.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//  UIViersion:2.0.8

#ifndef RedpacketLib_h
#define RedpacketLib_h

#import <Foundation/Foundation.h>

/// APP通过以下文件便可与SDK完成对接

#if TARGET_OS_IPHONE

#import "RPRedpacketBridge.h"
#import "RPRedpacketModel.h"
#import "RedpacketViewControl.h"
#import "RPUserInfo.h"
#import "RPAdvertInfo.h"

#else

#import <RedpacketLib/RPRedpacketBridge.h>
#import <RedpacketLib/RPRedpacketModel.h>
#import <RedpacketLib/RedpacketViewControl.h>
#import <RedpacketLib/RPUserInfo.h>
#import <RedpacketLib/RPAdvertInfo.h>

#endif

#endif
