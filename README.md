# XTNetworking

基于AFNetworking的二次封装。使用了YYCache做为缓存。支持GET、POST、PUT、DELETE等常用的请求方式。可以设置不同的请求和接收数据格式。

### 如何使用

您在使用这个库的时候，最好是单独创建一个请求类，继承自项目中的`XTApiRequest`类。通过这个类去在去请求。类似于这样

```
// 创建一个请求类，继承XTApiRequest。
XTTestRequst *request = [[XTTestRequst alloc] init];
    
[request sendToGetLoginUserInfo:^(BOOL success, id responseObject, NSDictionary *status) {
        
    // 请求结果处理 
}];
    
```

详细的说明您可以查看这边说明文档或代码里面有注释[详细说明](https://blog.csdn.net/XuanTong520/article/details/81939336)。这篇文章里面详细说明了整个库的设计思路，以及详细的使用方法。


### 怎么添加到项目

这个框架目前不支持`cocoapods`和`carthage`。主要是最近没时间去做成这个。后面的话，看心情吧。所以你只能手动添加了

#### 手动添加

找到Demo文件中`XTNetworkKit`文件夹，然后复制到你的项目中就可以了。怎么样，简单方便吧。但有一点要注意，如果你的项目中如果已经存在了`AFNetworking`和`YYCache`文件，那么，你需要移除一个。


**如果您在使用过程中遇到什么问题，可以随时提Issue**

**或者发送问题到邮箱 1653584411@qq.com**

**如果您觉得还不错，麻烦您动动鼠标给我个Star，谢谢**

