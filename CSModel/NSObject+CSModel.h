//
// NSObjet+CSModel.h
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
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 CSModel is a consice and efficient model framework for iOS/OSX. 
 It Provides many data-model methods:
 
 * Converts json to any object, or convert any object to json.
 * Serializes a model to provide class info and object properties.
 * Implementations of `NSCoding` and `isEqual:`.
 
 */
@class CSModelProperty;
@interface NSObject (CSModel)

/**
 Creates the json object from `NSString`, `NSData`, `NSDictionary`, `NSArray`
 and also an object. If the there are inner object in `NSDictionary` or `NSArray`,
 inner object will be alsow converted to json object.

 @return A new object created from the json, or nil if an error occurs.
 */
- (nullable id)cs_JSONObject;

/**
 Creates a json string in `NSDictionary`, `NSArray`, `NSData`, model object.
 The CSModel assumes that NSString produces well-formed UTF8 Unicode and 
 does no additional validation of the conversion.

 @return A json string, or nil if an error occurs.
 */
- (nullable NSString *)cs_JSONString;

/**
 Creates a new object from a specific object. if the object's properities has
 other object, these properties' object will also be copyed.

 @return A object with different points.
 */
- (nullable id)cs_modelCopy;

/**
 Creates a new object from another object according to the same property name and encoding type. 
 if the object's properities has other object, these properties' object will also be copyed.

 @param model A object
 @return Another object
 */
+ (nullable id)cs_modelCopyFromModel:(id _Nonnull)model;

/**
 Create a dictionary or array from a model object. The inner nonfundamental object
 in the dictionary or array will be converted to fundamental object.

 @return A `NSDictionary` or `NSArray` with fundamental object.
 */
- (nullable id)cs_modelToKeyValues;

/**
 Creates a model object from a `NSDictionary`.

 @param dict A NSDictionary
 @return A model object
 */
+ (nullable id)cs_modelWithDictionary:(id _Nonnull)dict;

/**
 Create a model object from a json object

 @param jsonObject A json object in `NSArray`, `NSDictioanry`
 @return A new model object
 */
+ (nullable id)cs_modelWithJSONObject:(nullable id)jsonObject;

/**
 Creates and returns an array from a json-array.

 @param jsonObject A json array of `NSArray`
 @return An array.
 */
+ (nullable NSMutableArray*)cs_modelArrayWithJSONObject:(nullable id)jsonObject;

/**
 Creates and returns an array from a json string.

 @param jsonString A json string
 @return An new object
 */
+ (nullable id)cs_modelWithJSONString:(nullable NSString *)jsonString;

/**
 Compares a object to another, if the object have nonfundamental inner objects,
 those inner objects will be also be comapred.

 @param model The same class to the compared one
 @return whether be equal in all values
 */
- (BOOL)cs_isEqualToValue:(nullable id)model;

/**
 Iterates the model's properties with key and inner object.

 @param block Enumerate with a block
 */
- (void)cs_enumerateModelKeysAndObjectUsingBlock:(void (NS_NOESCAPE^ _Nonnull)(NSString *_Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop))block;

/**
 Decodes the model properties from a aDecoder.

 @param aDecoder An archiver object.
 @return model itself
 */
- (nonnull id)cs_decoder:(NSCoder * _Nonnull)aDecoder;

/**
 Encodes the model properties to a coder.

 @param encoder An archiver object.
 */
- (void)cs_encode:(NSCoder * _Nonnull)encoder;

/**
 Description method for debugging purposes based on properties.

 @return A NSString contains the keys and values of the model.
 */
- (nonnull NSString *)cs_description;

@end

@protocol CSModel <NSObject>
@optional
/**
 If a value of key in the json is an array,The json array will be conveted
 to model array by implementing this method.
 
 @return A class mapper
 */
+ (nonnull NSDictionary <NSString *,Class> *)CSModelArrayWithModelMapping;

/**
 If a value of key is a JSON object , implement this method to
 convert the JSON object to a model's properites.
 
 @return A class mapper for dictionary key
 */
+ (nonnull NSDictionary <NSString *,Class>  *)CSModelDictionaryKeyWithModelMapping;
/**
 The mapping of model property and json key
 
 @return A custom mapper
 */
+ (nonnull NSDictionary <NSString *,NSString *> *)CSModelKeyWithPropertyMapping;
@end


/// The class type for a object.
typedef NS_OPTIONS(NSUInteger, CSObjectType) {
    /// Object Type
    CSObjectTypeModel           = 0, /// Specific Object
    /// Objective-C Fundamental Type
    CSObjectTypeNSString        = 1, /// NSString
    CSObjectTypeNSDictionary    = 2, /// NSDictionary
    CSObjectTypeNSArray         = 3, /// NSArray
    CSObjectTypeNSNumber        = 4, /// NSNumber
    CSObjectTypeNSDate          = 5, /// NSDate
    CSObjectTypeNSData          = 6, /// NSData
    CSObjectTypeNSValue         = 7, /// NSValue
    CSObjectTypeNSSet           = 8, /// NSSet
    CSObjectTypeNSURL           = 9, /// NSURL
};

/// The encoding type for a property.
typedef NS_OPTIONS(NSUInteger, CSEncodingType) {
    CSEncodingTypeUnknown    = 0,  /// unknown type
    CSEncodingTypeVoid       = 1,  /// v - void
    CSEncodingTypeBool       = 2,  /// B - C++ bool or a C99 _Bool
    CSEncodingTypeInt8       = 3,  /// c - char
    CSEncodingTypeUInt8      = 4,  /// C -  unsigned char
    CSEncodingTypeInt16      = 5,  /// s - short
    CSEncodingTypeUInt16     = 6,  /// S - unsigned short
    CSEncodingTypeInt32      = 7,  /// i - int, l - l is treated as a 32-bit quantity on 64-bit programs.
    CSEncodingTypeUInt32     = 8,  /// I - unsigned int
    CSEncodingTypeInt64      = 9,  /// q - long long
    CSEncodingTypeUInt64     = 10, /// Q - unsigned long long
    CSEncodingTypeFloat      = 11, /// f - float
    CSEncodingTypeDouble     = 12, /// d - double
    CSEncodingTypeLongDouble = 13, /// D - long double
    CSEncodingTypeCString    = 14, /// * - character string (char *)
    CSEncodingTypeCArray     = 15, /// [ - array
    CSEncodingTypeUnion      = 16, /// ( - union
    CSEncodingTypePointer    = 17, /// ^ - pointer to type
    CSEncodingTypeSEL        = 18, /// : - method selector (SEL)
    CSEncodingTypeStruct     = 19, /// { - structure
    CSEncodingTypeBlock      = 20, /// @? - block
    CSEncodingTypeClass      = 21, /// A - class object (Class)
    CSEncodingTypeObject     = 22, /// @ - An object (whether statically typed or typed id)
};


/// The property type for a objc_property_t.
typedef NS_OPTIONS(NSUInteger, CSPropertyType) {
    CSPropertyTypeMask         = 0xFF,   /// used for mask
    CSPropertyTypeRetain       = 1 << 0, /// & - The property is a reference to the value last assigned (retain).
    CSPropertyTypeWeak         = 1 << 1, /// W - The property is a weak reference (__weak).
    CSPropertyTypeCopy         = 1 << 2, /// C - The property is a copy of the value last assigned (copy)
    CSPropertyTypeReadonly     = 1 << 3, /// R - The property is read-only (readonly).
    CSPropertyTypeNonatomic    = 1 << 4, /// N - The property is non-atomic (nonatomic)
    CSPropertyTypeCustomGetter = 1 << 5, /// G<name> - The property defines a custom getter selector name. The name follows the G (for example, GcustomGetter,).
    CSPropertyTypeCustomSetter = 1 << 6, /// S<name> - The property defines a custom setter selector name. The name follows the S (for example, ScustomSetter:,)
    CSPropertyTypeDynamic      = 1 << 7, /// D - The property is dynamic (@dynamic).
    /// P : The property is eligible for garbage collection.
    /// t<encoding> : Specifies the type using old-style encoding.
};


/**
 Descirbes the class info and its properites.
 */
@interface CSClassInfo : NSObject{
    @package
    Class _className;
    CSObjectType _objectType;
    BOOL _isFoundationClass;
    BOOL _isJSONMetaType;
    
    NSArray<NSString *> * _protocols;
    NSDictionary<NSString*,CSModelProperty*> *_propertyMapper;
}
@end


/**
 Describes the property info form a objc_property_t.
 */
@interface CSModelProperty : NSObject {
    @package
    NSString *_name;          /// Property Name
    CSEncodingType _eType;    /// Type Encoding
    CSPropertyType _pType;    /// Property Type
    CSObjectType _objectType; /// Objective-C Type
    SEL _getter;              /// Objective-C getter method
    SEL _setter;              /// Objective-C setter method
    Class _class;             /// Objective-C class
}
@end

/**
 Acquires the class info form a given class.

 @param cls A class
 @return A class info instance
 */
CSClassInfo * _Nullable getClassInfo(Class _Nonnull cls);

/**
 Acquires all the properties info from a class.

 @param cls A class
 @return An array contains the `CSModelProperty` instance
 */
NSDictionary * _Nullable getPropertyMapper(Class _Nonnull cls);

/**
 Acquires all the protocols the class conformed.

 @param cls A class
 @return An array with `Protocol` objects
 */
NSArray * _Nullable getProtocols(Class _Nonnull cls);

NS_ASSUME_NONNULL_END











