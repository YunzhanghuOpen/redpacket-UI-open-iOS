//
//  RedpacketSendControl.m
//  RedpacketLib
//
//  Created by Mr.Yang on 2016/10/17.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPRedpacketSendControl.h"
#import "RPRedpacketModel.h"
#import "RPRedpacketTool.h"
#import "UIView+YZHPrompting.h"
#import "UIAlertView+YZHAlert.h"
#import "UIViewController+RP_Private.h"
#import "RPAliAuthPay.h"
#import "RPRedpacketManager.h"
#import "RPRedpacketSetting.h"

static RPRedpacketSendControl *__redpacketSendControl = nil;

@interface RPRedpacketSendControl()

@property (nonatomic, strong) RPAliAuthPay *authPay;
@property (nonatomic,   copy) NSString *redpacketID;
@property (nonatomic,   weak) RPBaseViewController *payController;
@property (nonatomic, strong) RPRedpacketModel *redpacketModel;
@property (nonatomic,   copy) RedpacketSendSccessBlock sendSuccessBlock;

@end


@implementation RPRedpacketSendControl

- (void)dealloc
{
    RPDebug(@"~~dealloc:%@", NSStringFromClass([self class]));
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)currentControl
{
    if (!__redpacketSendControl) {
        __redpacketSendControl = [[[self class] alloc] init];
    }

    return __redpacketSendControl;
}

+ (void)releaseSendControl
{
    __redpacketSendControl = nil;
}

#pragma mark  - SendRedpacekt
- (void)alertWithMessage:(NSString *)message
{
    [[[UIAlertView alloc] initWithTitle:@"提示"
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"我知道了"
                      otherButtonTitles:nil] show];
}

- (void)payMoney:(NSString *)money withMessageModel:(RPRedpacketModel *)model
                                       inController:(RPBaseViewController *)viewController
                                    andSuccessBlock:(RedpacketSendSccessBlock)successBlock
{
    _payController = viewController;
    _redpacketModel = model;
    _sendSuccessBlock = successBlock;
    
    rpWeakSelf;
    [RPRedpacketSender generateRedpacketID:^(NSError *error, NSString *string) {
        if (error) {
            [weakSelf alertWithMessage:error.localizedDescription];
            __redpacketSendControl = nil;
        } else {
            [weakSelf payMoneyInPayControl:money];
        }
    }];
}

- (void)payMoneyInPayControl:(NSString *)money
{
    _authPay = [RPAliAuthPay new];
    _payController.isVerifyAlipay = YES;//调起支付宝以后需要检查支付结果
    rpWeakSelf;
    [_authPay payMoney:money inController:weakSelf.payController andFinishBlock:^{
        [RPRedpacketSender sendRedpacket:weakSelf.redpacketModel andSendBlock:^(NSError *error, RPRedpacketModel *model) {
            [weakSelf.payController.view rp_removeHudInManaual];
            if (error) {
                [weakSelf alertWithMessage:error.localizedDescription];
                __redpacketSendControl = nil;
            } else {
                if (weakSelf.sendSuccessBlock){
                    weakSelf.sendSuccessBlock(weakSelf.redpacketModel);
                    __redpacketSendControl = nil;
                } else {
                    [weakSelf alertWithMessage:@"若红包未发送成功，扣除金额将于24小时后退回"];
                }
            }
        }];
    }];
}

- (void)fetchAlipayIsSuccess:(AlipayIsSuccessBlock)block
{
    [RPRedpacketSender fecchAlipayIsSuccess:^(NSError *error) {
        block(error);
    }];
}

@end

