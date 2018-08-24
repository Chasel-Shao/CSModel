//
// NSObjet+CSModel.m
// Copyright (c) 2017年 Chasel. All rights reserved.
// https://github.com/Chasel-Shao/CSModel.git
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "NSObject+CSModel.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

@implementation NSObject (CSModel)

- (id)cs_JSONObject{
    if ([self isKindOfClass:[NSString class]]) {
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        return jsonObject;
    }else if([self isKindOfClass:[NSData class]]){
        id json =  [NSJSONSerialization JSONObjectWithData:(NSData *)self options:0 error:nil];
        return json;
    }else{
        return praseJSONModel(self);
    }
}

- (NSString *)cs_JSONString{
    id jsonObject = [self cs_JSONObject];
    NSData *jsonData =  [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (id)cs_modelToKeyValues{
    if ([self isKindOfClass:[NSString class]]) {
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        return jsonObject;
    }else if([self isKindOfClass:[NSDictionary class]]){
        return praseObjectModel(self);
    }else if([self isKindOfClass:[NSArray class]]){
        return praseObjectModel(self);
    }else if([self isKindOfClass:[NSSet class]]){
        return praseObjectModel(self);
    }else{
        NSMutableDictionary *propertyDict = [NSMutableDictionary dictionary];
        CSClassInfo *selfClassInfo = getClassInfo(self.class);
        [selfClassInfo->_propertyMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key,CSModelProperty * _Nonnull obj, BOOL * _Nonnull stop) {
            id value = [obj valueForKey:key];
            if (value != nil) [propertyDict setObject:value forKey:obj->_name];
        }];
        return propertyDict;
    }
}

+ (id)cs_modelCopyFromModel:(id)model{
    id one = self.class.new;
    CSClassInfo *oneClassInfo = getClassInfo(self);
    CSClassInfo *twoClassInfo = getClassInfo([model class]);
    NSDictionary *twoPropertyDict = twoClassInfo->_propertyMapper;
    [oneClassInfo->_propertyMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, CSModelProperty *_Nonnull onePropertyInfo, BOOL * _Nonnull stop) {
        if (twoPropertyDict[onePropertyInfo->_name] != nil) {
            
            CSModelProperty *twoPropertyInfo = twoPropertyDict[onePropertyInfo->_name];
            if (onePropertyInfo->_eType == twoPropertyInfo->_eType ) {
                switch (onePropertyInfo->_eType) {
                    case CSEncodingTypeObject:{
                        id value = ((id (*)(id,SEL))(void *) objc_msgSend)(model,twoPropertyInfo->_getter);
                        if (value != nil){
                            CSClassInfo *valueClassInfo = getClassInfo([value class]);
                            if (valueClassInfo->_isJSONMetaType) {
                                // pass
                            }else{
                                value = [value cs_modelCopy];
                            }
                            ((void (*)(id,SEL,id))(void *)objc_msgSend)(one,onePropertyInfo->_setter,value);
                        }
                        break;
                    }
                    case CSEncodingTypeBlock:
                    case CSEncodingTypeClass:{
                        id value = ((id (*)(id,SEL))(void *) objc_msgSend)(model,twoPropertyInfo->_getter);
                        if (value != nil) ((void (*)(id,SEL,id))(void *)objc_msgSend)(one,onePropertyInfo->_setter,value);
                        break;
                    }
                    case CSEncodingTypeBool: {
                        bool num = ((bool (*)(id,SEL))(void *) objc_msgSend)(model,twoPropertyInfo->_getter);
                        ((void (*)(id, SEL, bool))(void *) objc_msgSend)(one, onePropertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeInt8:
                    case CSEncodingTypeUInt8: {
                        uint8_t num = ((uint8_t (*)(id, SEL))(void *) objc_msgSend)(model,twoPropertyInfo->_getter);
                        ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)(one, onePropertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeInt16:
                    case CSEncodingTypeUInt16: {
                        uint16_t num = ((uint16_t (*)(id, SEL))(void *) objc_msgSend)(model, twoPropertyInfo->_getter);
                        ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)(one, onePropertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeInt32:
                    case CSEncodingTypeUInt32: {
                        uint32_t num = ((uint32_t (*)(id, SEL))(void *) objc_msgSend)(model, twoPropertyInfo->_getter);
                        ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)(one, onePropertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeInt64:
                    case CSEncodingTypeUInt64: {
                        uint64_t num = ((uint64_t (*)(id, SEL))(void *) objc_msgSend)(model, twoPropertyInfo->_getter);
                        ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)(one, onePropertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeFloat: {
                        float num = ((float (*)(id, SEL))(void *) objc_msgSend)(model, twoPropertyInfo->_getter);
                        ((void (*)(id, SEL, float))(void *) objc_msgSend)(one, onePropertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeDouble: {
                        double num = ((double (*)(id, SEL))(void *) objc_msgSend)(model, twoPropertyInfo->_getter);
                        ((void (*)(id, SEL, double))(void *) objc_msgSend)(one, onePropertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeLongDouble: {
                        long double num = ((long double (*)(id, SEL))(void *) objc_msgSend)(model, twoPropertyInfo->_getter);
                        ((void (*)(id, SEL, long double))(void *) objc_msgSend)(one, onePropertyInfo->_setter, num);
                    }
                        break;
                    case CSEncodingTypeSEL:
                    case CSEncodingTypePointer:
                    case CSEncodingTypeCString: {
                        size_t value = ((size_t (*)(id, SEL))(void *) objc_msgSend)(model, twoPropertyInfo->_getter);
                        ((void (*)(id, SEL, size_t))(void *) objc_msgSend)(one, onePropertyInfo->_setter, value);
                    } break;
                    case CSEncodingTypeStruct:
                    case CSEncodingTypeUnion: {
                        @try {
                            NSValue *value = [model valueForKey:twoPropertyInfo->_name];
                            if (value) {
                                ((void (*)(id, SEL, id))(void *) objc_msgSend)(one, onePropertyInfo->_setter, value);
                            }
                        } @catch (NSException *exception) {}
                    }
                        break;
                    default:
                        break;
                }
            }
        }
    }];
    return one;
}

- (id)cs_modelCopy{
    id model = self.class.new;
    CSClassInfo *selfClassInfo = getClassInfo(self.class);
    if (selfClassInfo->_isJSONMetaType) return self;
    if (selfClassInfo->_objectType == CSObjectTypeNSArray) {
        NSMutableArray *array = [NSMutableArray array];
        [((NSArray *)self) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [array addObject:[obj cs_modelCopy]];
        }];
        return array;
    }else if(selfClassInfo->_objectType == CSObjectTypeNSDictionary){
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [((NSDictionary *)self) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [dict setObject:[obj cs_modelCopy] forKey:key];
        }];
        return dict;
    }else if(selfClassInfo->_objectType == CSObjectTypeNSSet){
        NSMutableSet *set = [NSMutableSet set];
        [((NSSet *)self).allObjects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [set addObject:[obj cs_modelCopy]];
        }];
        return set;
    }else{
        NSDictionary *modelProperties =  selfClassInfo->_propertyMapper;
        [selfClassInfo->_propertyMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key,CSModelProperty *  _Nonnull fromModelInfo, BOOL * _Nonnull stop) {
            if ([modelProperties objectForKey:key] != nil ) {
                CSModelProperty*  toModelInfo = [modelProperties objectForKey:key];
                if (toModelInfo->_eType == fromModelInfo->_eType) {
                    id value = [self valueForKey:key];
                    switch (toModelInfo->_eType) {
                        case CSEncodingTypeObject:{
                            if (value != nil){
                                CSClassInfo *valueClassInfo = getClassInfo([value class]);
                                if (valueClassInfo->_isJSONMetaType) {
                                    [model setValue:value forKey:toModelInfo->_name];
                                }else{
                                    id objectValue = [value cs_modelCopy];
                                    [model setValue:objectValue forKey:toModelInfo->_name];
                                }
                            }
                        }break;
                        case CSEncodingTypeBlock:
                        case CSEncodingTypeClass:{
                            if (value != nil) [model setValue:value forKey:toModelInfo->_name];
                        }break;
                        case CSEncodingTypeBool: {
                            bool num = ((bool (*)(id,SEL))(void *) objc_msgSend)(self,fromModelInfo->_getter);
                            ((void (*)(id, SEL, bool))(void *) objc_msgSend)(model, toModelInfo->_setter, num);
                        } break;
                        case CSEncodingTypeInt8:
                        case CSEncodingTypeUInt8: {
                            uint8_t num = ((uint8_t (*)(id, SEL))(void *) objc_msgSend)(self,fromModelInfo->_getter);
                            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)(model, toModelInfo->_setter, num);
                        } break;
                        case CSEncodingTypeInt16:
                        case CSEncodingTypeUInt16: {
                            uint16_t num = ((uint16_t (*)(id, SEL))(void *) objc_msgSend)(self, fromModelInfo->_getter);
                            ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)(model, toModelInfo->_setter, num);
                        } break;
                        case CSEncodingTypeInt32:
                        case CSEncodingTypeUInt32: {
                            uint32_t num = ((uint32_t (*)(id, SEL))(void *) objc_msgSend)(self, fromModelInfo->_getter);
                            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)(model, toModelInfo->_setter, num);
                        } break;
                        case CSEncodingTypeInt64:
                        case CSEncodingTypeUInt64: {
                            uint64_t num = ((uint64_t (*)(id, SEL))(void *) objc_msgSend)(self, fromModelInfo->_getter);
                            ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)(model, toModelInfo->_setter, num);
                        } break;
                        case CSEncodingTypeFloat: {
                            float num = ((float (*)(id, SEL))(void *) objc_msgSend)(self, fromModelInfo->_getter);
                            ((void (*)(id, SEL, float))(void *) objc_msgSend)(model, toModelInfo->_setter, num);
                        } break;
                        case CSEncodingTypeDouble: {
                            double num = ((double (*)(id, SEL))(void *) objc_msgSend)(self, fromModelInfo->_getter);
                            ((void (*)(id, SEL, double))(void *) objc_msgSend)(model, toModelInfo->_setter, num);
                        } break;
                        case CSEncodingTypeLongDouble: {
                            long double num = ((long double (*)(id, SEL))(void *) objc_msgSend)(self, fromModelInfo->_getter);
                            ((void (*)(id, SEL, long double))(void *) objc_msgSend)(model, toModelInfo->_setter, num);
                        }
                            break;
                        case CSEncodingTypeSEL:
                        case CSEncodingTypePointer:
                        case CSEncodingTypeCString: {
                            size_t value = ((size_t (*)(id, SEL))(void *) objc_msgSend)(self, fromModelInfo->_getter);
                            ((void (*)(id, SEL, size_t))(void *) objc_msgSend)(model, toModelInfo->_setter, value);
                        } break;
                        case CSEncodingTypeStruct:
                        case CSEncodingTypeUnion: {
                            @try {
                                NSValue *value = [self valueForKey:fromModelInfo->_name];
                                if (value != nil)  [model setValue:value forKey:toModelInfo->_name];
                            } @catch (NSException *exception) {}
                        }
                            break;
                        default:
                            break;
                    }
                }
            }
        }];
    }
    return model;
}


+ (id)cs_modelWithJSONObject:(id)jsonObject{
    Class cls = [self class];
    id model = [cls new];
    CSClassInfo *selfClassInfo = getClassInfo(cls);
    if (selfClassInfo->_isJSONMetaType) return jsonObject;
    NSDictionary *modelPropertyInfoDict = selfClassInfo->_propertyMapper;
    NSDictionary *keyPropertyMapping = nil;
    if([cls respondsToSelector:@selector(CSModelKeyWithPropertyMapping)]){
        keyPropertyMapping = [cls performSelector:@selector(CSModelKeyWithPropertyMapping)];
    }
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        [((NSDictionary *)jsonObject) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (keyPropertyMapping != nil && [keyPropertyMapping objectForKey:key] != nil) {
                key = [keyPropertyMapping objectForKey:key];
            }
            CSModelProperty * propertyInfo = [modelPropertyInfoDict objectForKey:key];
            if (propertyInfo != nil) {
                switch (propertyInfo->_eType) {
                    case CSEncodingTypeObject:
                        if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                            [model setValue:obj forKey:key];
                        }else if(obj == (id)kCFNull){
                            break;
                        }else if(propertyInfo->_objectType == CSObjectTypeNSDictionary && [obj isKindOfClass:[NSDictionary class]]){
                            if ([model respondsToSelector:@selector(CSModelDictionaryKeyWithModelMapping)]) {
                                NSDictionary *modelMappingDictionary = [model CSModelDictionaryKeyWithModelMapping] ;
                                if ([modelMappingDictionary objectForKey:key] != nil) {
                                    Class DictClassModel =  [modelMappingDictionary objectForKey:key];
                                    if(DictClassModel != nil){
                                        NSMutableDictionary *modelDict = [NSMutableDictionary dictionary];
                                        [(NSArray *)obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                            id dictObj =  [DictClassModel cs_modelWithJSONObject:obj];
                                            if(dictObj != nil) [modelDict setObject:dictObj forKey:key];
                                        }];
                                        [model setValue:modelDict forKey:key];
                                        break;
                                    }
                                }
                            }else{
                                    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
                                    [(NSDictionary *)obj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                                        newDict[key] = [obj cs_modelCopy];
                                    }];
                                    ((void (*)(id,SEL,id))(void *)objc_msgSend)(model,propertyInfo->_setter,newDict);
                                    break;
                            }
                        }else if (propertyInfo->_objectType == CSObjectTypeNSArray && [obj isKindOfClass:[NSArray class]]) {
                            if ([model respondsToSelector:@selector(CSModelArrayWithModelMapping)]) {
                                NSDictionary *modelMappingArray = [model performSelector:@selector(CSModelArrayWithModelMapping)] ;
                                if ([modelMappingArray objectForKey:key] != nil) {
                                    Class ArrayClassModel =  [modelMappingArray objectForKey:key];
                                    if (ArrayClassModel != nil) {
                                        NSMutableArray *modelArray = [NSMutableArray array];
                                        [(NSArray *)obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                            id arrayModel =  [ArrayClassModel cs_modelWithJSONObject:obj];
                                            [modelArray addObject:arrayModel];
                                        }];
                                        [model setValue:modelArray forKey:key];
                                        break;
                                    }
                                }
                            }else{
                                NSMutableArray *newArray = [NSMutableArray array];
                                [(NSArray *)obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    [newArray addObject:[obj cs_modelCopy]];
                                }];
                                [model setValue:newArray forKey:key];
                                break;
                            }
                        }else{
                            id newObject =  [propertyInfo->_class cs_modelWithJSONObject:obj];
                            [model setValue:newObject forKey:key];
                        }
                        break;
                    case CSEncodingTypeBlock:
                    case CSEncodingTypeClass:
                        [model setValue:obj forKey:key];
                        break;
                    case CSEncodingTypeBool: {
                        bool num = [obj boolValue];
                        ((void (*)(id, SEL, bool))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeInt8:
                    case CSEncodingTypeUInt8: {
                        uint8_t num = [obj intValue];
                        ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeInt16:
                    case CSEncodingTypeUInt16: {
                        uint16_t num = [obj intValue];
                        ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeInt32:
                    case CSEncodingTypeUInt32: {
                        uint32_t num = [obj intValue];
                        ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeInt64:
                    case CSEncodingTypeUInt64: {
                        uint64_t num = [obj integerValue];
                        ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeFloat: {
                        float num = [obj floatValue];
                        ((void (*)(id, SEL, float))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeDouble: {
                        double num = [obj doubleValue];
                        ((void (*)(id, SEL, double))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeLongDouble: {
                        long double num = [obj doubleValue];
                        ((void (*)(id, SEL, long double))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeStruct:
                    case CSEncodingTypeUnion: {
                        @try {
                            NSValue *value = [model valueForKey:propertyInfo->_name];
                            if (value != nil)  [model setValue:value forKey:propertyInfo->_name];
                        } @catch (NSException *exception) {}
                    }
                        break;
                    default:
                        break;
                }
            }else{
                // can't find property -- error
            }
        }];
    }else{
        // unsupported format
    }
    return model;
}

+ (nullable id)cs_modelArrayWithJSONObject:(nullable id)jsonObject{
    NSMutableArray *modelArray = [NSMutableArray array];
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        [((NSArray *)jsonObject) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [modelArray addObject:[self cs_modelWithJSONObject:obj]];
        }];
    }
    return modelArray;
}

+ (id)cs_modelWithDictionary:(id)dict{
    Class cls = [self class];
    id model = [cls new];
    CSClassInfo *selfClassInfo = getClassInfo(cls);
    NSDictionary *modelPropertyInfoDict = selfClassInfo->_propertyMapper;
    NSDictionary *keyPropertyMapping = nil;
    if([cls  respondsToSelector:@selector(CSModelKeyWithPropertyMapping)]){
        keyPropertyMapping = [cls performSelector:@selector(CSModelKeyWithPropertyMapping)];
    }
    
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [((NSDictionary *)dict) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (keyPropertyMapping != nil && [keyPropertyMapping objectForKey:key] != nil) {
                key = [keyPropertyMapping objectForKey:key];
            }
            CSModelProperty * propertyInfo = [modelPropertyInfoDict objectForKey:key];
            if (propertyInfo != nil) {
                switch (propertyInfo->_eType) {
                    case CSEncodingTypeObject:
                        if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                            ((void (*)(id,SEL,id))(void *)objc_msgSend)(model,propertyInfo->_setter,obj);
                        }else if(obj == (id)kCFNull){
                            break;
                        }else if(propertyInfo->_objectType == CSObjectTypeNSDictionary && [obj isKindOfClass:[NSDictionary class]]){
                            if ([model respondsToSelector:@selector(CSModelDictionaryKeyWithModelMapping)]) {
                                NSDictionary *modelMappingDictionary = [model CSModelDictionaryKeyWithModelMapping] ;
                                if ([modelMappingDictionary objectForKey:key] != nil) {
                                    Class DictClassModel =  [modelMappingDictionary objectForKey:key];
                                    if(DictClassModel != nil){
                                        NSMutableDictionary *modelDict = [NSMutableDictionary dictionary];
                                        [(NSArray *)obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                            id dictObj =  [DictClassModel cs_modelWithJSONObject:obj];
                                            if(dictObj != nil) [modelDict setObject:dictObj forKey:key];
                                        }];
                                        ((void (*)(id,SEL,id))(void *)objc_msgSend)(model,propertyInfo->_setter,modelDict);
                                        break;
                                    }
                                }
                            } else {
                                NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
                                [(NSDictionary *)obj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                                    newDict[key] = [obj cs_modelCopy];
                                }];
                                ((void (*)(id,SEL,id))(void *)objc_msgSend)(model,propertyInfo->_setter,newDict);
                                break;
                            }
                        }else if (propertyInfo->_objectType == CSObjectTypeNSArray && [obj isKindOfClass:[NSArray class]]) {
                            if ([model respondsToSelector:@selector(CSModelArrayWithModelMapping)]) {
                                NSDictionary *modelMappingArray = [model performSelector:@selector(CSModelArrayWithModelMapping)] ;
                                if ([modelMappingArray objectForKey:key] != nil) {
                                    Class ArrayClassModel =  [modelMappingArray objectForKey:key];
                                    if (ArrayClassModel != nil) {
                                        NSMutableArray *modelArray = [NSMutableArray array];
                                        [(NSArray *)obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                            id arrayModel =  [ArrayClassModel cs_modelWithJSONObject:obj];
                                            [modelArray addObject:arrayModel];
                                        }];
                                        ((void (*)(id,SEL,id))(void *)objc_msgSend)(model,propertyInfo->_setter,modelArray);
                                        break;
                                    }
                                }
                            }else {
                                NSMutableArray *newArray = [NSMutableArray array];
                                [(NSArray *)obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    [newArray addObject:[obj cs_modelCopy]];
                                }];
                                [model setValue:newArray forKey:key];
                                break;
                            }
                        }else{
                            id newObject =  [propertyInfo->_class cs_modelWithJSONObject:obj];
                            ((void (*)(id,SEL,id))(void *)objc_msgSend)(model,propertyInfo->_setter,newObject);
                        }
                        break;
                    case CSEncodingTypeBlock:
                    case CSEncodingTypeClass:
                        ((void (*)(id,SEL,id))(void *)objc_msgSend)(model,propertyInfo->_setter,obj);
                        break;
                    case CSEncodingTypeBool: {
                        bool num = [obj boolValue];
                        ((void (*)(id, SEL, bool))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeInt8:
                    case CSEncodingTypeUInt8: {
                        uint8_t num = [obj intValue];
                        ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeInt16:
                    case CSEncodingTypeUInt16: {
                        uint16_t num = [obj intValue];
                        ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeInt32:
                    case CSEncodingTypeUInt32: {
                        uint32_t num = [obj intValue];
                        ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeInt64:
                    case CSEncodingTypeUInt64: {
                        uint64_t num = [obj integerValue];
                        ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeFloat: {
                        float num = [obj floatValue];
                        ((void (*)(id, SEL, float))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeDouble: {
                        double num = [obj doubleValue];
                        ((void (*)(id, SEL, double))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeLongDouble: {
                        long double num = [obj doubleValue];
                        ((void (*)(id, SEL, long double))(void *) objc_msgSend)(model, propertyInfo->_setter, num);
                    } break;
                    case CSEncodingTypeStruct:
                    case CSEncodingTypeUnion: {
                        @try {
                            NSValue *value = [model valueForKey:propertyInfo->_name];
                            if (value != nil)  ((void (*)(id,SEL,id))(void *)objc_msgSend)(model,propertyInfo->_setter,value);
                        } @catch (NSException *exception) {}
                    }
                        break;
                    default:{
                        if ([obj isKindOfClass:[NSObject class]]) {
                            ((void (*)(id,SEL,id))(void *)objc_msgSend)(model,propertyInfo->_setter,obj);
                        }
                        break;
                    }
                }
            }
        }];
    }else{
        // the fromat is not dict
    }
    return model;
}

+ (id)cs_modelWithJSONString:(NSString *)jsonString{
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    return [self cs_modelWithJSONObject:jsonObject];
}

- (BOOL)cs_isEqualToValue:(id)model{
    // point
    if (self == model) return YES;
    // nil
    if (self == nil && model == nil) {
        return YES;
    }else{
        if (self == nil || model == nil) {
            return NO;
        }
    }
    if (![self isKindOfClass:[model class]]) return NO;
    // string and nsnumber
    if([model isKindOfClass:[NSString class]] || [model isKindOfClass:[NSNumber class]]) {
        return [model isEqual:self];
    };
    // struct
    if ([model isKindOfClass:NSValue.class]) {
        return [(NSValue *)model isEqualToValue:(NSValue *)self];
    }
    // dictionary
    if ([model isKindOfClass:NSDictionary.class]) {
        __block BOOL flag = YES;
        [(NSDictionary *)model enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull modelKey, id  _Nonnull modelObj, BOOL * _Nonnull modelStop) {
            [((NSDictionary *)self) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull selfKey, id  _Nonnull selfObj, BOOL * _Nonnull selfStop) {
                if ([modelKey isEqualToString:selfKey]) {
                    flag = [selfObj cs_isEqualToValue:modelObj];
                    *selfStop = YES;
                    if (flag == NO) {
                        *modelStop = YES;
                    }
                }
            }];
        }];
        return flag;
    }
    // array
    if ([model isKindOfClass:NSArray.class]) {
        __block BOOL flag = NO;
        [((NSArray *)model) enumerateObjectsUsingBlock:^(id  _Nonnull modelObj, NSUInteger idx, BOOL * _Nonnull modelStop) {
            flag = NO;
            [((NSArray *)self) enumerateObjectsUsingBlock:^(id  _Nonnull selfObj, NSUInteger idx, BOOL * _Nonnull selfStop) {
                flag =  [modelObj cs_isEqualToValue:selfObj];
                if (flag == YES) {
                    *selfStop = YES;
                }
            }];
            if (flag == NO) {
                *modelStop = YES;
            }
        }];
        return flag;
    }
    // object
    __block BOOL flag = YES;
    CSClassInfo *oneClassInfo = getClassInfo(self.class);
    CSClassInfo *twoClassInfo = getClassInfo([model class]);
    NSDictionary *modelProperties =  twoClassInfo->_propertyMapper;
    [oneClassInfo->_propertyMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, CSModelProperty *  _Nonnull selfModel, BOOL * _Nonnull stop) {
        if ([modelProperties objectForKey:key] != nil) {
            id selfValue = [self valueForKey:key];
            id objectValue = [model valueForKey:key];
            if (objectValue == nil && selfValue == nil) {
                // pass
            }else{
                if (objectValue == nil || selfValue == nil){
                    flag = NO;
                }else{
                    BOOL subResult = [objectValue cs_isEqualToValue:selfValue];
                    if(selfValue != 0x0 && objectValue != 0x0 && !subResult){
                        flag = NO;
                    }
                }
            }
            if (flag == NO) *stop = YES;
        }
    }];
    return flag;
}


static id praseObjectModel(__unsafe_unretained id model){
    if (model == nil || [model isEqual:[NSNull null]]) return model;
    CSClassInfo *modelClassInfo = getClassInfo([model class]);
    if (modelClassInfo->_isJSONMetaType) return model;
    if (modelClassInfo->_objectType == CSObjectTypeNSArray){
        NSMutableArray *modelArray = [NSMutableArray arrayWithCapacity:modelClassInfo->_propertyMapper.count];
        [((NSArray *)model) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = praseObjectModel(obj);
            if (value)  [modelArray addObject:value];
        }];
        return modelArray;
    }else if(modelClassInfo->_objectType == CSObjectTypeNSSet){
        NSArray *array = ((NSSet *)model).allObjects;
        return praseObjectModel(array);
    }else if(modelClassInfo->_objectType == CSObjectTypeNSDictionary){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [((NSDictionary *)model) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj != nil) {
                id v = praseObjectModel(obj);
                if (v != nil) [dic setObject:v forKey:key];
            }
        }];
        return dic;
    }else{
        NSMutableDictionary *propertyDict = [NSMutableDictionary dictionary];
        [modelClassInfo->_propertyMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key,CSModelProperty * _Nonnull obj, BOOL * _Nonnull stop) {
            switch (obj->_eType) {
                case CSEncodingTypeInt8:
                case CSEncodingTypeInt16:
                case CSEncodingTypeInt32:
                case CSEncodingTypeInt64:{
                    NSInteger value = ((NSInteger (*)(id,SEL))(void *) objc_msgSend)(model,obj->_getter);
                    if(value) [propertyDict setObject:@(value) forKey:obj->_name];
                    break;
                }
                case CSEncodingTypeUInt8:
                case CSEncodingTypeUInt16:
                case CSEncodingTypeUInt32:
                case CSEncodingTypeUInt64:{
                    NSUInteger value = ((NSUInteger (*)(id,SEL))(void *) objc_msgSend)(model,obj->_getter);
                    if(value) [propertyDict setObject:@(value) forKey:obj->_name];
                    break;
                }
                case CSEncodingTypeFloat:{
                    float value = ((float (*)(id,SEL))(void *) objc_msgSend)(model,obj->_getter);
                    if(value) [propertyDict setObject:@(value) forKey:obj->_name];
                    break;
                }
                case CSEncodingTypeDouble:
                case CSEncodingTypeLongDouble:{
                    double value = ((double (*)(id,SEL))(void *) objc_msgSend)(model,obj->_getter);
                    if(value) [propertyDict setObject:@(value) forKey:obj->_name];
                    break;
                }
                case CSEncodingTypeObject:
                case CSEncodingTypeClass:
                case CSEncodingTypeBlock:{
                    id value = ((id (*)(id,SEL))(void *) objc_msgSend)(model,obj->_getter);
                    value = praseObjectModel(value);
                    if(value) [propertyDict setObject:value forKey:obj->_name];
                    break;
                }
                case CSEncodingTypeStruct:
                case CSEncodingTypeUnion:
                    @try {
                        NSValue *value = [model valueForKey:obj->_name];
                        if(value) [propertyDict setObject:value forKey:obj->_name];
                    } @catch (NSException *exception) { }
                    break;
                case CSEncodingTypeSEL:
                case CSEncodingTypePointer:
                case CSEncodingTypeCString:{
                    size_t value = ((size_t (*)(id, SEL))(void *) objc_msgSend)((id)model, obj->_getter);
                    if(value) [propertyDict setObject:@(value) forKey:obj->_name];
                    break;
                }
                case CSEncodingTypeCArray:
                case CSEncodingTypeVoid:
                    break;
                default:
                    // error
                    break;
            }
        }];
        return propertyDict;
    }
    return model;
}

static id praseJSONModel(__unsafe_unretained id model){
    if (model == nil || [model isEqual:[NSNull null]]) return model;
    CSClassInfo *classInfo = getClassInfo([model class]);
    if (classInfo->_isJSONMetaType) {
        return model;
    }
    if (classInfo->_objectType == CSObjectTypeNSArray){
        NSMutableArray *modelArray = [NSMutableArray array];
        [((NSArray *)model) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = praseJSONModel(obj);
            if (value)  [modelArray addObject:value];
        }];
        return modelArray;
    }else if(classInfo->_objectType == CSObjectTypeNSSet){
        NSArray *array = ((NSSet *)model).allObjects;
        return praseJSONModel(array);
    }else if(classInfo->_objectType == CSObjectTypeNSDictionary){
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [((NSDictionary *)model) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj != nil) {
                id v = praseJSONModel(obj);
                if (v != nil) [dic setObject:v forKey:key];
            }
        }];
        return dic;
    }else{
        NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
        [classInfo->_propertyMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key,CSModelProperty * _Nonnull obj, BOOL * _Nonnull stop) {
            switch (obj->_eType) {
                case CSEncodingTypeInt8:
                case CSEncodingTypeInt16:
                case CSEncodingTypeInt32:
                case CSEncodingTypeInt64:{
                    NSInteger value = ((NSInteger (*)(id,SEL))(void *) objc_msgSend)(model,obj->_getter);
                    if(value) [jsonDict setObject:@(value) forKey:obj->_name];
                    break;
                }
                case CSEncodingTypeUInt8:
                case CSEncodingTypeUInt16:
                case CSEncodingTypeUInt32:
                case CSEncodingTypeUInt64:{
                    NSUInteger value = ((NSUInteger (*)(id,SEL))(void *) objc_msgSend)(model,obj->_getter);
                    if(value) [jsonDict setObject:@(value) forKey:obj->_name];
                    break;
                }
                case CSEncodingTypeFloat:{
                    float value = ((float (*)(id,SEL))(void *) objc_msgSend)(model,obj->_getter);
                    if(value) [jsonDict setObject:@(value) forKey:obj->_name];
                    break;
                }
                case CSEncodingTypeDouble:
                case CSEncodingTypeLongDouble:{
                    double value = ((double (*)(id,SEL))(void *) objc_msgSend)(model,obj->_getter);
                    if(value) [jsonDict setObject:@(value) forKey:obj->_name];
                    break;
                }
                case CSEncodingTypeObject:{
                    id value = ((id (*)(id,SEL))(void *) objc_msgSend)(model,obj->_getter);
                    value = praseJSONModel(value);
                    if(value) [jsonDict setObject:value forKey:obj->_name];
                    break;
                }
                case CSEncodingTypeCString:{
                    size_t value = ((size_t (*)(id, SEL))(void *) objc_msgSend)((id)model, obj->_getter);
                    if(value) [jsonDict setObject:@(value) forKey:obj->_name];
                    break;
                }
                default:
                    break;
            }
        }];
        return jsonDict;
    }
    return model;
}


#pragma mark NSCoding protocol
- (id)cs_decoder:(NSCoder *)aDecoder{
    BOOL secureAvailable = [aDecoder respondsToSelector:@selector(decodeObjectOfClass:forKey:)];
    BOOL secureSupported = NO;
    if ([[self class] resolveClassMethod:@selector(supportsSecureCoding)]) {
        secureSupported = [[self class] supportsSecureCoding];
    }
    CSClassInfo *selfClassInfo = getClassInfo(self.class);
    [selfClassInfo->_propertyMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, CSModelProperty *  _Nonnull obj, BOOL * _Nonnull stop) {
        id object = nil;
        if (secureAvailable){
            if (obj->_class != nil) object = [aDecoder decodeObjectOfClass:obj->_class forKey:key];
        } else{
            object = [aDecoder decodeObjectForKey:key];
        }
        if (object){
            if (secureSupported && ![object isKindOfClass:obj->_class]){
                // error
            }
            [self setValue:object forKey:key];
        }
    }];
    return self;
}

- (void)cs_encode:(NSCoder *)encoder{
    CSClassInfo *selfClassInfo = getClassInfo([self class]);
    [selfClassInfo->_propertyMapper enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, CSModelProperty *  _Nonnull propertyInfo, BOOL * _Nonnull stop) {
        id object = [self valueForKey:propertyInfo->_name];
        if (object != nil && object != [NSNull null]){
            [encoder encodeObject:object forKey:key];
        }
    }];
}

- (NSArray*)_backlist{
    return @[@"hash",@"superclass",@"description",@"debugDescription"];
}

- (NSString *)cs_description{
    CSClassInfo *selfClassInfo = getClassInfo([self class]);
    NSDictionary *objectProperyDict = selfClassInfo->_propertyMapper;
    NSMutableString *printStr = [NSMutableString string];
    [printStr appendFormat:@"(%@:%p){",[self class],self];
    [objectProperyDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, CSModelProperty *  _Nonnull p, BOOL * _Nonnull stop) {
        id value = [self valueForKey:key];
        if (value == nil)  value = @"<nil>";
        [printStr appendFormat:@" %@=%@;",p->_name,value];
    }];
    [printStr appendString:@" }"];
    return printStr;
}


- (void)cs_enumerateModelKeysAndObjectUsingBlock:(void (NS_NOESCAPE ^)(NSString *key, id obj, BOOL *stop))block {
    unsigned int count;
    Class class = self.class;
    objc_property_t *properties =  class_copyPropertyList(class, &count);
    BOOL flag = NO;
    for (int i = 0; i < count; i ++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        if ([[self _backlist] containsObject:propertyName])  continue;
        if (block && flag == NO) {
            block(propertyName,[self valueForKey:propertyName],&flag);
            if (flag == YES)  break;
        }
    }
    free(properties);
}

@end

@implementation CSClassInfo
@end

@implementation CSModelProperty
@end

static CSModelProperty * _getPropertyEncodingType(objc_property_t property);
static const char classProtocolKey = '\0';
NSArray *getProtocols(Class cls){
    NSArray *classProtocolCache = objc_getAssociatedObject(cls, &classProtocolKey);
    if (classProtocolCache != nil) {
        return classProtocolCache;
    }
    unsigned int count;
    __unsafe_unretained Protocol **protocols =  class_copyProtocolList(cls, &count);
    NSMutableArray *protocolArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0 ; i < count; i++) {
        Protocol *protocol = protocols[i];
        [protocolArray addObject:protocol];
    }
    free(protocols);
    objc_setAssociatedObject(cls, &classProtocolKey, classProtocolCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return protocolArray.copy;
}

static const char objectPropertyInfoKey = '\0';
NSDictionary * getPropertyMapper(Class cls){
    NSDictionary *objectPropertyInfoCache = objc_getAssociatedObject(cls, &objectPropertyInfoKey);
    if (objectPropertyInfoCache != nil) {
        return objectPropertyInfoCache;
    }
    unsigned int count;
    NSMutableDictionary *objectPropertyDict = [NSMutableDictionary dictionary];
    objc_property_t *properties =  class_copyPropertyList(cls, &count);
    for (int i = 0; i < count; i ++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        if ([@[@"hash",@"superclass",@"description",@"debugDescription"] containsObject:propertyName])  continue;
        CSModelProperty *p = _getPropertyEncodingType(property);
        [objectPropertyDict setObject:p forKey:propertyName];
    }
    free(properties);
    objc_setAssociatedObject(cls, &objectPropertyInfoKey, objectPropertyDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return objectPropertyDict;
}

CSClassInfo *getClassInfo(Class cls){
    static  CFMutableDictionaryRef __classInfoCacheDict;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __classInfoCacheDict = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    });
    CSClassInfo *classInfoCache = CFDictionaryGetValue(__classInfoCacheDict, (__bridge const void *)(cls));
    if (classInfoCache != nil) {
        return classInfoCache;
    }else{
        classInfoCache = CSClassInfo.new;
        classInfoCache->_className = cls;
        if([cls isSubclassOfClass:[NSString class]]){
            classInfoCache->_objectType = CSObjectTypeNSString;
            classInfoCache->_isJSONMetaType = YES;
        }else if([cls isSubclassOfClass:[NSNumber class]]){
            classInfoCache->_objectType = CSObjectTypeNSNumber;
            classInfoCache->_isJSONMetaType = YES;
        }else if([cls isSubclassOfClass:[NSArray class]]){
            classInfoCache->_objectType = CSObjectTypeNSArray;
        }else if([cls isSubclassOfClass:[NSDictionary class]]){
            classInfoCache->_objectType = CSObjectTypeNSDictionary;
        }else if([cls isSubclassOfClass:[NSData class]]){
            classInfoCache->_objectType = CSObjectTypeNSData;
        }else if([cls isSubclassOfClass:[NSDate class]]){
            classInfoCache->_objectType = CSObjectTypeNSDate;
        }else if([cls isSubclassOfClass:[NSValue class]]){
            classInfoCache->_objectType = CSObjectTypeNSValue;
        }else if([cls isSubclassOfClass:[NSSet class]]){
            classInfoCache->_objectType = CSObjectTypeNSSet;
        }else if([cls isSubclassOfClass:[NSURL class]]){
            classInfoCache->_objectType = CSObjectTypeNSURL;
        }else{
            classInfoCache->_objectType = CSObjectTypeModel;
        }
        if (classInfoCache->_objectType > 0) {
            classInfoCache->_isFoundationClass = YES;
            CFDictionarySetValue(__classInfoCacheDict, (__bridge const void *)(cls), (__bridge const void *)(classInfoCache));
            return classInfoCache;
        }else{
            classInfoCache->_isFoundationClass = NO;
        }
        classInfoCache->_protocols = getProtocols(cls);
        classInfoCache->_propertyMapper =  getPropertyMapper(cls);
    }
    CFDictionarySetValue(__classInfoCacheDict, (__bridge const void *)(cls), (__bridge const void *)(classInfoCache));
    return classInfoCache;
}

static CSModelProperty * _getPropertyEncodingType(objc_property_t property){
    CSModelProperty *propertyInfo = CSModelProperty.new;
    propertyInfo->_pType = 0;
    const char *name = property_getName(property);
    propertyInfo->_name = [NSString stringWithUTF8String:name];
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (int i = 0; i < attrCount; i++) {
        objc_property_attribute_t attr = attrs[i];
        if (attr.name[0] == 'T') {
            const char *attrValue = &attr.value[0];
            NSMutableString *className =  NSMutableString.string;
            char *type = (char *)attrValue;
            if(*type){
                switch (*type) {
                    case 'v':  propertyInfo->_eType  =  CSEncodingTypeVoid; break;
                    case 'B':  propertyInfo->_eType  =  CSEncodingTypeBool; break;
                    case 'c':  propertyInfo->_eType  =  CSEncodingTypeInt8; break;
                    case 'C':  propertyInfo->_eType  =  CSEncodingTypeUInt8; break;
                    case 's':  propertyInfo->_eType  =  CSEncodingTypeInt16; break;
                    case 'S':  propertyInfo->_eType  =  CSEncodingTypeUInt16; break;
                    case 'i':  propertyInfo->_eType  =  CSEncodingTypeInt32; break;
                    case 'I':  propertyInfo->_eType  =  CSEncodingTypeUInt32; break;
                    case 'l':  propertyInfo->_eType  =  CSEncodingTypeInt32; break;
                    case 'L':  propertyInfo->_eType  =  CSEncodingTypeUInt32; break;
                    case 'q':  propertyInfo->_eType  =  CSEncodingTypeInt64; break;
                    case 'Q':  propertyInfo->_eType  =  CSEncodingTypeUInt64; break;
                    case 'f':  propertyInfo->_eType  =  CSEncodingTypeFloat; break;
                    case 'd':  propertyInfo->_eType  =  CSEncodingTypeDouble; break;
                    case 'D':  propertyInfo->_eType  =  CSEncodingTypeLongDouble; break;
                    case '#':  propertyInfo->_eType  =  CSEncodingTypeClass; break;
                    case ':':  propertyInfo->_eType  =  CSEncodingTypeSEL; break;
                    case '*':  propertyInfo->_eType  =  CSEncodingTypeCString; break;
                    case '^':  propertyInfo->_eType  =  CSEncodingTypePointer; break;
                    case '[':  propertyInfo->_eType  =  CSEncodingTypeCArray; break;
                    case '(':  propertyInfo->_eType  =  CSEncodingTypeUnion; break;
                    case '{':
                        propertyInfo->_eType  =  CSEncodingTypeStruct;
                        break;
                    case '@': {
                        if (strlen(type) == 2 && *(type + 1) == '?'){
                            propertyInfo->_eType = CSEncodingTypeBlock;
                        }else{
                            if (className != NULL) {
                                char *subName = strchr(type,'"');
                                if (subName != NULL) {
                                    size_t length = strlen(subName);
                                    if (length > 2) {
                                        // class name
                                        propertyInfo->_class = NSClassFromString([[NSString stringWithUTF8String:type] substringWithRange:NSMakeRange(2, length - 2)]);
                                        if([propertyInfo->_class isSubclassOfClass:NSString.class]){
                                            propertyInfo->_objectType = CSObjectTypeNSString;
                                        }else if([propertyInfo->_class isSubclassOfClass:NSNumber.class]){
                                            propertyInfo->_objectType = CSObjectTypeNSNumber;
                                        }else if([propertyInfo->_class isSubclassOfClass:NSArray.class]){
                                            propertyInfo->_objectType = CSObjectTypeNSArray;
                                        }else if([propertyInfo->_class isSubclassOfClass:NSDictionary.class]){
                                            propertyInfo->_objectType = CSObjectTypeNSDictionary;
                                        }else if([propertyInfo->_class isSubclassOfClass:NSData.class]){
                                            propertyInfo->_objectType = CSObjectTypeNSData;
                                        }else if([propertyInfo->_class isSubclassOfClass:NSDate.class]){
                                            propertyInfo->_objectType = CSObjectTypeNSDate;
                                        }else if([propertyInfo->_class isSubclassOfClass:NSValue.class]){
                                            propertyInfo->_objectType = CSObjectTypeNSValue;
                                        }else if([propertyInfo->_class isSubclassOfClass:NSSet.class]){
                                            propertyInfo->_objectType = CSObjectTypeNSValue;
                                        }else if([propertyInfo->_class isSubclassOfClass:NSURL.class]){
                                            propertyInfo->_objectType = CSObjectTypeNSValue;
                                        }else{
                                            propertyInfo->_objectType = CSObjectTypeModel;
                                        }
                                    }
                                }
                            }
                            propertyInfo->_eType = CSEncodingTypeObject;
                        }
                    }
                        break;
                    default:  propertyInfo->_eType = CSEncodingTypeUnknown;
                }
            }else{
                propertyInfo->_eType = CSEncodingTypeUnknown;
            }
        }else if (attr.name[0] == 'C') {
            propertyInfo->_pType |= CSPropertyTypeCopy;
        }else if (attr.name[0] == '&') {
            propertyInfo->_pType |= CSPropertyTypeRetain;
        }else if (attr.name[0] == 'N') {
            propertyInfo->_pType |= CSPropertyTypeNonatomic;
        }else if (attr.name[0] == 'R') {
            propertyInfo->_pType |= CSPropertyTypeReadonly;
        }else if (attr.name[0] == 'W') {
            propertyInfo->_pType |= CSPropertyTypeWeak;
        }else if (attr.name[0] == 'V') {
            // value
        }else if (attr.name[0] == 'D'){
            propertyInfo->_pType |= CSPropertyTypeDynamic;
        } else if(attr.name[0] == 'G') {
            propertyInfo->_pType |= CSPropertyTypeCustomGetter;
            propertyInfo->_getter = sel_registerName(attr.value);
        }else if (attr.name[0] == 'S'){
            propertyInfo->_pType |= CSPropertyTypeCustomSetter;
            propertyInfo->_setter = sel_registerName(attr.value);
        }
    }
    if (!propertyInfo->_getter) {
        propertyInfo->_getter = sel_registerName(name);
    }
    if (!propertyInfo->_setter) {
        size_t propertyNameLength = strlen(name);
        size_t setterLength = propertyNameLength + 4;
        char setterName[setterLength + 1];
        strncpy(setterName, "set", 3);
        strncpy(setterName + 3, name, propertyNameLength);
        setterName[3] = (char)toupper(setterName[3]);
        setterName[setterLength - 1] = ':';
        setterName[setterLength] = '\0';
        propertyInfo->_setter = sel_registerName(setterName);
    }
    free(attrs);
    return propertyInfo;
}






