# HCUserBehaviour
## 统计页面
* 在 `- (void)viewWillAppear:(BOOL)animated` 和 `- (void)viewDidDisappear:(BOOL)animated` 中埋点统计。
* 使用 `UIViewController+HCUserBehaviour.h` 自动统计，可以使用 `setBlackPageNameList` 方法设置忽略的 `UIViewController`。
## 统计事件
因为事件的统计大部分都是和具体业务紧密相连的所以只使用埋点统计。
## 数据
统计的数据会组成 Json 文件存储到沙盒中。
```
/HCUserBehaviour
        /data
            /2017.4.6
                xxx.json
                xxx.json
            /2017.4.7
                xxx.json
```

## 数据保存时机
* 程序进入到后台 `UIApplicationDidEnterBackgroundNotification`。
* 程序接收到内存警告 `UIApplicationDidReceiveMemoryWarningNotification`。

## 数据上传策略
* 程序每次启动时，`HCReportPolicyBatch` 。
* 按照时间段上传，比如：每小时，每天固定上传，`HCReportPolicyBatchInterval` 。


**因为每个人的统计需求都不同，上传的接口都不一样，所以该demo只提供一些思路，需要根据自己的需求做修改。**
