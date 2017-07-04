CSModel
==============
![Language](https://img.shields.io/badge/language-Objective--C-orange.svg)
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/Chasel-Shao/CSModel/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/CSModel.svg?style=flat)](http://cocoapods.org/pods/CSModel)&nbsp;

[:book: English Documentation](README.md) | :book: 中文文档

基础介绍
==============
CSModel 是一个简洁高效的Model和JSON转换的框架，并且支持嵌套模型进行值拷贝和值比较等等。

特性
==============

- **简洁轻量**: 方法简单，源码文件比较少
- **无侵入性**: 无需继承自其他基类
- **类型安全**: 检查每个对象类型，并且自动处理json中的null
- **高性能**: 解析速度快，并且支持解析model类继承其他model类
- **比较**: 支持模型值比较，并且可以是多层嵌套的模型
- **拷贝**: 提供多层嵌套模型模型，进行值拷贝

性能
==============
处理 GithubUser 数据 10000 次耗时统计 (iPhone 6s):

![Benchmark result](https://raw.githubusercontent.com/Chasel-Shao/CSModel/master/Benchmark/result.png
)


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
	
// 1. 将 JSON 转换为 Model:
Person *p = [Person cs_modelWithJSONObject:json];

// 2. 将 JSON String 转换为 Model:
 Person *np = [Person cs_modelWithJSONString:jsonStr];
	
// 3. 将 Model 转换为 JSON 对象:
id json = [p cs_JSONObject];

// 4. 将 Model 转换为 JSON String:
NSString *jsonStr =  [p cs_JSONString];

// 5. 将 JSON 数组转换为 Model 数组:
NSArray *array = [Person cs_modelArrayWithJSONObject:jsonArray];
```
### 使用协议
```objc
// 1. JSON中的键值名称和模型中的键值进行映射
+ (NSDictionary<NSString *,NSString *> *)CSModelKeyWithPropertyMapping
    return @{@"user_id":@"userId"};
}

// 2. 如果JSON数组中嵌套另一个JSON数组，实现下列方法通过键值映射为模型数组
+ (NSDictionary<NSString *,Class> *)CSModelArrayWithModelMapping{
    return @{@"child":[Person class]};
}

// 3. 如果JSON数组中嵌套另一个JSON对象，实现下列方法通过键值映射为模型
+ (NSDictionary<NSString *,Class> *)CSModelDictionaryKeyWithModelMapping{
    return @{@"child":[Person class]};
}
```
### Model 的比较与拷贝
```objc
// Model 
@interface Teacher : NSObject
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)NSInteger age;
@property(nonatomic,copy)NSString *books;
@end
@implementation Teacher
@end

// 1. 比较两个对象的值，支持嵌套比较:
BOOL isSame = [p cs_isEqualToValue:p2];

// 2. 拷贝对象，支持嵌套拷贝:
Person *p2 = [p cs_modelCopy];

// 3. 不同对象之间的值拷贝：
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



作者
==============
- [Chasel-Shao](https://github.com/Chasel-Shao) 753080265@qq.com


许可证
==============
CSModel 使用 MIT 许可证，详情见 LICENSE 文件。


