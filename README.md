CSModel
==============
![Language](https://img.shields.io/badge/language-Objective--C-orange.svg)
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/Chasel-Shao/CSModel/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/CSModel.svg?style=flat)](http://cocoapods.org/pods/CSModel)&nbsp;

:book: English Documentation | [:book: 中文文档](README-CN.md)

Introduce
==============
CSModel is a concise and efficient model framework for iOS/OSX, and provides nested Model to compare values and copy values.

Features
==============

- **Lightweight**: Easily and simpily to use，less source files
- **Noninvasive**: No need to inherit other class
- **Type Safe**: Checks every type of the object, and deal with the null in json
- **High Performance**: Parses the json very fast and supported the nested model
- **Compare** : Supported the value compare which can be multinest model
- **Copy** : Provides the nested model copy from another model

Performance
==============
The time cost of disposing 10000 times GithubUser objects (iPhone 6s).

![Benchmark result](https://raw.githubusercontent.com/Chasel-Shao/CSModel/master/Benchmark/result.png
)


Getting Started
==============

### The conversion between JSON, Model and String
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
	
// 1. Converting the JSON to an Model:
Person *p = [Person cs_modelWithJSONObject:json];

// 2. Converting the String to an Model:
 Person *np = [Person cs_modelWithJSONString:jsonStr];
	
// 3. Converting the Model to an JSON:
id json = [p cs_JSONObject];

// 4. Converting the Model to an NSString:
NSString *jsonStr =  [p cs_JSONString];

// 5. Converting the JSON Array to an Model Array:
NSArray *array = [Person cs_modelArrayWithJSONObject:jsonArray];
```

### How to use Protocol 
```objc
// 1. If a value of key in the json is an array,The json array will be
// conveted to model array by implementing this method.
+ (NSDictionary<NSString *,NSString *> *)CSModelKeyWithPropertyMapping
    return @{@"user_id":@"userId"};
}

// 2. If a value of key is a JSON object , implement this method to convert
// the JSON object to a model's properites.
+ (NSDictionary<NSString *,Class> *)CSModelArrayWithModelMapping{
    return @{@"child":[Person class]};
}

// 3. The mapping of model property and json key
+ (NSDictionary<NSString *,Class> *)CSModelDictionaryKeyWithModelMapping{
    return @{@"child":[Person class]};
}
```

### The comparing and copying method
```objc
// Model 
@interface Teacher : NSObject
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)NSInteger age;
@property(nonatomic,copy)NSString *books;
@end
@implementation Teacher
@end

// 1. Comparing the value of two models, supported the nested Model:
BOOL isSame = [p cs_isEqualToValue:p2];

// 2. Copying the value of an model, supported the nested Model:
Person *p2 = [p cs_modelCopy];

// 3. Copying from the different model:
Teacher *teacher1 = [Teacher cs_modelCopyFromModel:p];
```
### The description method
```objc
// Implementing the method in the `.m file` of the Model
-(NSString *)description{
    return [self cs_description];
}
```
### The coding method
```objc
// Implementing the following method in the `.m file` of the Model
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [self cs_encode:aCoder];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    return [self cs_decoder:aDecoder];
}
```
Installation
==============

### Installation with CocoaPods

1. Specify the `pod 'CSModel'` to the Podfile
2. Then, run `pod install` or `pod update`
3. Import the header files \<CSModel/CSModel.h\>


### Manual installation

1. Download the  CSModel source files
2. Import the CSModel.h and related source files



Author
==============
- [Chasel-Shao](https://github.com/Chasel-Shao) 753080265@qq.com


License
==============
CSModel is released under the MIT license. See LICENSE for details.


