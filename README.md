# redpacket-ui-open-ios
支付宝授权版UI开源代码

### 开源代码下载地址
[开源地址](https://github.com/YunzhanghuOpen/redpacket-ui-open-ios)

### 红包SDK介绍和集成文档
https://docs.yunzhanghu.com/integration/ios.html

### 针对各个SaaS的集成文档
https://docs.yunzhanghu.com/integration/saas.html

### RedpacketAliAuthAPILib
* 为UI库所用到的数据层SDK，可以使用远程依赖` pod 'RedpacketAliAuthAPILib'`
* [下载地址](https://github.com/YunzhanghuOpen/cocoapods-redpacket-api)

### redpacket-ui依赖
* 如需在工程中直接使用redpacket-ui源码，则需要在工程中引入依赖的pod
    * 红包SDKAPI层依赖 `pod 'RedpacketAliAuthAPILib'`
    * 支付宝SDK依赖 `pod 'RPAlipayLib'`

* [UI开源代码下载地址](https://github.com/YunzhanghuOpen/redpacket-ui-open-ios)


### 注意：
这段代码，加到自己的info.plist文件里。

```
<key>LSApplicationQueriesSchemes</key>
<array>
<string>alipay</string>
</array>

<key>CFBundleURLTypes</key>
<array>
<dict>
<key>CFBundleURLName</key>
<string>alipay</string>
</dict>
</array>

```
