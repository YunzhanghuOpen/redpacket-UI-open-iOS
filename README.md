# redpacket-ui-open-ios
支付宝授权版UI开源代码

### 

### 红包SDK接入指南
https://docs.yunzhanghu.com/integration/ios.html

### SDK接入方式推荐有2种方式，如果无需修改UI可以直接选择pod远程依赖
1. 直接将开源文件导入到工程, 请注意添加依赖（见下面说明）
2. pod远程依赖`pod 'RedpacketAliAuthLib'`,此方式不可修改UI文件

### RedpacketAliAuthAPILib
* 为UI库所用到到数据层，可以使用远程依赖` pod 'RedpacketAliAuthAPILib'`

### redpacket-ui依赖
如需在工程中直接使用redpacket-ui源码，则需要在工程中引入依赖的pod

* 红包SDKAPI层依赖 `pod 'RedpacketAliAuthAPILib'`
* 支付宝SDK依赖 `pod 'RPAlipayLib'`

