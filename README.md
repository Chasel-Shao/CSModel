CSModel
==============

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/Chasel-Shao/CSModel/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/CSModel.svg?style=flat)](http://cocoapods.org/pods/CSModel)&nbsp;

介绍
==============
CSModel 是一个简洁高效的Model和JSON转换的框架<br/>


性能
==============
处理 GithubUser 数据 10000 次耗时统计 (iPhone 6s):

![Benchmark result](https://raw.githubusercontent.com/Chasel-Shao/CSModel/master/Benchmark/result.png
)



特性
==============

- **简洁轻量**: 方法简单，源码文件比较少
- **无侵入性**: 无需继承自其他基类
- **安全**: 检查每个对象类型，并且自动处理json中的null
- **高性能**: 解析速度快，并且支持解析model类继承其他model类

使用方法
==============

### Model、JSON 以及 String 相互转换
```objc
// JSON:
{
    "uid":8082,
    "name":"Amy",
    "age":23
}

// Model:
@interface Person : NSObject
@property (nonatomic,assign) UInt64 uid;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) NSInteger age;
@end
@implementation Person
@end
	
// 将 JSON (NSData,NSString,NSDictionary) 转换为 Model:
Person *p = [Person cs_modelWithJSONString:jsonStr];
	
// 将 Model 转换为 JSON 对象:
id *json = [p cs_JSONObject]

// 将 Model 转换为 JSON String:
NSString *jsonStr =  [p cs_JSONString];

// 将 JSON String 转换为 Model:
 Person *np = [Person cs_modelWithJSONString:jsonStr]
```
### Model 的拷贝与比较
```objc
// Model 
@interface Teacher : NSObject
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)NSInteger age;
@property(nonatomic,copy)NSString *books;
@end
@implementation Teacher
@end

// 拷贝对象，支持嵌套拷贝:
Person *p2 = [p cs_modelCopy];

// 比较两个对象的值，支持嵌套比较:
BOOL isSame = [p cs_isEqualToValue:p2];

// 不同对象之间的值拷贝：
Teacher *teacher1 = [Teacher cs_modelCopyFromModel:p];
```
### Model 的 description 的实现
```objc
// 在模型的.m文件中实现以下方法
-(NSString *)description{
    return [self cs_description];
}
```
### Model 的 Coding 的实现
```objc
// 在模型的.m文件中实现以下方法
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [self cs_encode:aCoder];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    return [self cs_decoder:aDecoder];
}
```
集成
==============

### CocoaPods

1. 在 Podfile 中添加 `pod 'CSModel'`
2. 执行 `pod install` 或 `pod update`
3. 导入 \<CSModel/CSModel.h\>


### 手动安装

1. 下载 CSModel 
2. 手动导入 CSModel.h 及其源码文件



系统要求
==============
该项目最低支持 `iOS 6.0` 和 `Xcode 8.0`。


许可证
==============
CSModel 使用 MIT 许可证，详情见 LICENSE 文件。


