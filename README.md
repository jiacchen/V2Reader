# V2Reader

## 简介

V2Reader 是一个用 SwiftUI 开发的，在 iOS、iPadOS 和 macOS 上的 V2EX 第三方客户端。因为所有的数据都是通过访问 [V2EX API 2.0 Beta](https://www.v2ex.com/help/api) 来获取的，而这份文档还在更新，有很多数据没有提供，所以 V2Reader 的功能还比较有限。之后随着 API 的更新，会有更多功能加入。

## 安装

[加入 Beta 版“V2Reader for V2EX” - TestFlight - Apple](https://testflight.apple.com/join/YNDbGSOD)

## 设备要求

iOS/iPadOS 15 以上，或者 macOS 12 Monterey 以上（使用了 Catalyst，所以 Intel Mac 也可以安装）。

## 功能

- 通过不同节点访问主题以及回复
  ![iOS 截屏](https://i.v2ex.co/T4dk2b9E.jpeg)

- 搜索节点并关注或者将节点添加到主页
  ![iOS 截屏](https://i.v2ex.co/ob17825n.jpeg)

- 点击发布者或回复者的用户名查看用户信息
  ![iOS 截屏](https://i.v2ex.co/5X2B8Pbb.png)

- 自动在 @用户 后添加楼层号，可以点击跳转到对应的楼层，然后点击蓝色箭头跳回原楼层
  ![iOS 截屏](https://i.v2ex.co/S67f1H6g.jpeg)

- iPad 版本以三列视图显示，支持分屏或小窗模式
  ![iPadOS 截屏](https://i.v2ex.co/CH83yN0C.png)

- Mac Catalyst 版本
  ![macOS 截屏](https://i.v2ex.co/OcWD1T9g.png)

## FAQ

### 为什么不支持更低的系统版本？

主要是因为我用了很多去年 WWDC 新加入的语法，比如 AsyncImage、MainActor、task、refreshable、searchable 之类的。

### 为什么 API 2.0 Beta 已经有了获取提醒的 API，但软件内还没有实现？

有两个原因：一、这个 API 获取的内容都是 HTML 格式的，我还没有考虑用什么方式去解析，不像帖子中的内容是 Markdown 格式的，可以用 iOS 15 新引入的 AttributedString。二、这个提醒 API 还获取不到帖子的 id，暂时也没办法实现点击跳转帖子的功能。

### 为什么有些 Markdown 格式的内容没有正常显示？

因为 AttributedString 还没有支持 Markdown 格式的全部语法，我猜测下次 WWDC 会支持更多。

### 为什么不支持 App 内发帖/回帖/收藏/感谢等功能？

我暂时打算只使用 API 2.0 Beta，而这些数据目前还无法通过这些接口获取。当然如果需要的人很多，我之后可能会用解析网页之类的方式来实现。目前点击发帖回帖的按钮会跳转到网页版。

### 为什么需要用 Token 来登录？可不可以使用账号密码或者免登录？

V2EX API 2.0 Beta 必须有 Token 才能够访问，用户需要在设置中自己创建 Token，然后复制粘贴到 App 中，App 会将 Token 放入系统的 Keychain 保存。用 Token 是否安全，可以参考站长 @Livid 在[这个帖子](https://www.v2ex.com/t/812163#reply13)中的回复。

### 为什么使用一段时间之后加载不出内容了，重新启动之后显示 Token 无效？

站长设置了每小时最多请求 API 600次，这种情况可能是达到了限制，可以等整点后再尝试。

### 为什么主页中最多只能添加5个节点？

主页每次刷新时，每个节点都需要单独访问一次 API，主页中包含的节点过多会导致很快达到 API 请求次数的上限，目前设置的是最多5个，如果觉得不够请在 TestFlight 里反馈，我会考虑在之后的版本里调整。
