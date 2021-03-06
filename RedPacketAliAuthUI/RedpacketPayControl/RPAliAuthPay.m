//
//  RPAliAuthPay.m
//  RedpacketLib
//
//  Created by Mr.Yang on 2016/12/19.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import "RPAliAuthPay.h"
#import "RPRedpacketErrorCode.h"
#import "AlipaySDK.h"
#import "RPRedpacketBridge.h"
#import "UIView+YZHPrompting.h"
#import "RPAlipayAuth.h"
#import "RPRedpacketTool.h"
#import "UIAlertView+YZHAlert.h"
#import "RPBaseViewController.h"
/*
 返回码	含义
 9000	订单支付成功
 8000	正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
 4000	订单支付失败
 5000	重复请求
 6001	用户中途取消
 6002	网络连接出错
 6004	支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态
 其它	其它支付错误
 */


#define AlipayPaySuccess    9000
#define AlipayPayUserCancel 6001
#define AlipayPayResultUnKnow 8000

@interface RPAliAuthPay ()
{
    //支付的父控制器
    __weak RPBaseViewController *_payController;
}

@property (nonatomic, copy) PaySuccessBlock paySuccessBlock;
@property (nonatomic, copy) NSString *payMoney;
@property (nonatomic, assign) BOOL isShowAlert;

@end


@implementation RPAliAuthPay

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipayCallBack:) name:@"redpacketAlipayNotifaction" object:nil];
    }
    
    return self;
}

- (void)payMoney:(NSString *)payMoney inController:(UIViewController *)currentController
                                    andFinishBlock:(PaySuccessBlock)paySuccessBlock
{
    _payController = (RPBaseViewController *)currentController;
    self.payMoney = payMoney;
    self.paySuccessBlock = paySuccessBlock;
    
    [self requestAlipayWithMoney:payMoney
                    inController:currentController];
}

//  下单
- (void)requestAlipayWithMoney:(NSString *)money
                  inController:(UIViewController *)viewController
{
    RPBaseViewController *senderVC = (RPBaseViewController *)viewController;
    rpWeakSelf;
    [RPRedpacketSender generateRedpacketPayOrder:money generateBlock:^(NSError *error, NSString *string) {
        if (error) {
            [viewController.view rp_removeHudInManaual];
            if (error.code == RedpacketUnAliAuthed) {
                //  没有授权
                senderVC.isVerifyAlipay = NO;//没有授权不检查订单支付结果
                [weakSelf showAuthAlert];
            }else {
                senderVC.isVerifyAlipay = NO;//付款不检查订单支付结果
                [weakSelf alertCancelPayMessage:@"付款失败，该红包不会被发出" withTitle:@"付款失败"];
            }
        } else {
            [weakSelf requestAlipayView:string withController:viewController];
        }
    }];
}

- (void)requestAlipayView:(NSString *)orderString withController:(UIViewController *)viewController
{
    RPBaseViewController *senderVC = (RPBaseViewController *)viewController;
    NSString *urlScheme = [[NSBundle mainBundle] bundleIdentifier];
    if (urlScheme.length == 0) {
        [senderVC.view rp_removeHudInManaual];
        [self alertWithMessage:@"urlScheme为空，无法调用支付宝"];
        return;
    }
    
    NSURL * myURL_APP_A = [NSURL URLWithString:@"alipay:"];
    if (![[UIApplication sharedApplication] canOpenURL:myURL_APP_A]) {
        //如果没有安装支付宝客户端那么需要去掉菊花
        [senderVC.view rp_removeHudInManaual];
    }
    rpWeakSelf;
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:urlScheme callback:^(NSDictionary *resultDic) {
        RPDebug(@"支付宝支付回调Param:%@", resultDic);
        [senderVC.view rp_removeHudInManaual];
        NSInteger code = [[resultDic objectForKey:@"resultStatus"] integerValue];
        if (code == AlipayPaySuccess) {
            if (weakSelf.paySuccessBlock) {
                weakSelf.paySuccessBlock();
            }
        }else if (code == AlipayPayUserCancel) {
            senderVC.isVerifyAlipay = NO;//取消支付不检查订单支付结果
            if (!_isShowAlert) {
                [self alertCancelPayMessage:@"您已取消支付，该红包不会被发出"
                                  withTitle:@"取消支付"];
            }
        }else {
            senderVC.isVerifyAlipay = NO;//支付失败不检查订单支付结果
            [weakSelf alertCancelPayMessage:@"付款失败, 该红包不会被发出"
                              withTitle:@"付款失败"];
        }
    }];
}

// 支付宝App支付的回调
- (void)alipayCallBack:(NSNotification *)notifaction
{
    RPDebug(@"红包SDK通知：\n收到支付宝支付回调：%@\n 当前的控制器：%@", notifaction, self);
    
    if ([notifaction.object isKindOfClass:[NSDictionary class]]) {
        NSInteger code = [[notifaction.object valueForKey:@"resultStatus"] integerValue];
        if (code == 9000) {
            //  支付成功
            if (self.paySuccessBlock) {
                self.paySuccessBlock();
            }
            
        }else if (code == AlipayPayUserCancel) {
            _payController.isVerifyAlipay = NO;//取消支付不检查订单支付结果
            if (!_isShowAlert) {
                [self alertCancelPayMessage:@"您已取消支付，该红包不会被发出"
                                  withTitle:@"取消支付"];
            }
        }else {
            _payController.isVerifyAlipay = NO;//支付失败不检查订单支付结果
            [self alertCancelPayMessage:@"付款失败, 该红包不会被发出"
                              withTitle:@"付款失败"];
        }
        
    }else {
        
        [_payController.view rp_removeHudInManaual];
    }
}

- (void)showAuthAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"需授权绑定支付宝账户"
                                                    message:@"发红包使用绑定的支付宝账号支付。"
                                                   delegate:nil
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确认授权", nil];
    
    rpWeakSelf;
    [alert setRp_completionBlock:^(UIAlertView * alertView, NSInteger buttonIndex) {
        
        if (buttonIndex == 1) {
            [weakSelf doAlipayAuth];
        }
    
    }];
    
    [alert show];
}

//  没有授权， 去授权
- (void)doAlipayAuth
{
    static RPAlipayAuth *staticAuth = nil;
    staticAuth = [RPAlipayAuth new];
    _payController.isVerifyAlipay = NO;//授权页不检查订单支付结果
    [staticAuth doAlipayAuth:^(BOOL isSuccess, NSString *error) {
        staticAuth = nil;
        [_payController.view rp_removeHudInManaual];
        if (isSuccess) {
            [self alertWithMessage:@"已成功绑定支付宝账号，以后红包收到的钱会自动入账到此支付宝账号。"];
        } else {
            [_payController.view rp_showHudErrorView:error];
        }
    }];
}

- (void)alertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    
    [alert show];
    [_payController.view rp_removeHudInManaual];
}

- (void)alertCancelPayMessage:(NSString *)message
                    withTitle:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"取消支付"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"我知道了"
                                          otherButtonTitles:nil];
    
    [alert show];
    _isShowAlert = YES;
    [_payController.view rp_removeHudInManaual];
}

@end
