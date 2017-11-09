//
//  RedirectCenter.m
//  RedirectDemo
//
//  Created by wenyou on 2017/11/6.
//  Copyright © 2017年 wenyou. All rights reserved.
//

#import "RedirectCenter.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "RedirectProtocol.h"
#import <MJExtension/MJExtension.h>

@implementation RedirectCenter {
    NSMutableDictionary<NSString *, Class> *_pushRouteDictionary;
    NSMutableDictionary<NSString *, Class> *_scanRouteDictionary;
}

+ (instancetype)shareInstance {
    static RedirectCenter *redirectCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        redirectCenter = [[RedirectCenter alloc] init];
    });
    return redirectCenter;
}

- (void)pushFrom:(UINavigationController *)navigationController withName:(NSString *)name propertyDict:(NSDictionary<NSString *, NSObject *> *)properties animated:(BOOL)animated {
    Class cls = [self classWithName:name];
    if (!cls) {
        return;
    }

    UIViewController *controller = [[cls alloc] mj_setKeyValues:properties];
    [navigationController pushViewController:controller animated:animated];
}

- (UIViewController *)viewControllerWithName:(NSString *)name propertyDict:(NSDictionary<NSString *, NSObject *> *)properties {
    Class cls = [self classWithName:name];
    if (!cls) {
        return nil;
    }

    UIViewController *controller = [[cls alloc] mj_setKeyValues:properties];
    return controller;
}

- (BOOL)openURL:(NSURL *)url {
    Class cls = [self classWithName:url.host];
    if (!cls) {
        return NO;
    }

    __block NSMutableDictionary<NSString *, NSString *> *params = [[NSMutableDictionary alloc] init];
    [[url.query componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *array = [obj componentsSeparatedByString:@"="];
        if (array.count >= 2) {
            [params setValue:array[1] forKey:array[0]];
        }
    }];

    UIViewController *controller = [[cls alloc] init];
    [self setObject:controller parameters:params];
    [[self currentViewController].navigationController pushViewController:controller animated:YES];

    return YES;
}

#pragma makr - private
- (instancetype)init {
    if (self = [super init]) {
        _scanRouteDictionary = [[NSMutableDictionary alloc] init];
        UInt64 time = [[NSDate date] timeIntervalSince1970] * 1000;
        [self findClass];
        NSLog(@"%llums", ((UInt64)([[NSDate date] timeIntervalSince1970] * 1000) - time));

        [_scanRouteDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, Class  _Nonnull obj, BOOL * _Nonnull stop) {
            NSLog(@"%@ %s", key, object_getClassName(obj));
        }];
    }
    return self;
}

// 扫描本地类 获取 RedirectCenter 的实现
- (void)findClass {
    int numClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;

    if (numClasses > 0 ) {
        classes = (Class *)realloc(classes, sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);

        for (int i = 0; i < numClasses; i++) {
            Class cls = classes[i];

            if ([self class:cls conformsToProtocol:@protocol(RedirectProtocol)] && [self class:cls subToClass:UIViewController.class]) {
                NSString *name = [self nameFromRedirectProtocol:cls];
                [_scanRouteDictionary setValue:cls forKey:name];
            }
        }
        free(classes);
    }
}

// 是否实现protocol 只判断当前类 不递归
- (BOOL)class:(Class)cls conformsToProtocol:(Protocol *)protocol {
    unsigned int outCount;
    __unsafe_unretained Protocol **protocols = class_copyProtocolList(cls, &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        if (protocol_isEqual(protocol, protocols[i])) {
            return YES;
        }
    }
    return NO;
}

// 是否为子类 递归判断
- (BOOL)class:(Class)cls subToClass:(Class)parent {
    Class superClass = class_getSuperclass(cls);
    if (superClass) {
        if (superClass == parent) {
            return YES;
        }
        return [self class:superClass subToClass:parent];
    }
    return NO;
}

// 根据 url 获得 VC 的类名
- (Class)controllerClassForName:(NSString *)linkName {
    NSString *className = [NSString stringWithFormat:@"%@ViewController", [linkName capitalizedString]];
    return NSClassFromString(className);
}

// 反射获得该类配置的 url
- (NSString *)nameFromRedirectProtocol:(Class)cls {
    NSString *result;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[cls methodSignatureForSelector:@selector(redirectName)]];
    [invocation setTarget:cls];
    [invocation setSelector:@selector(redirectName)];
    [invocation invoke];
    [invocation getReturnValue:&result];
    return result;
}

// 根据名称获取 class
- (Class)classWithName:(NSString *)linkName {
    Class cls = _pushRouteDictionary[linkName];
    if (!cls) {
        cls = _scanRouteDictionary[linkName];
    }
    if (!cls) {
        cls = [self controllerClassForName:linkName];
    }
    return cls;
}

- (UIViewController *)currentViewController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *controller = window.rootViewController;
    for (;;) {
        if ([controller isKindOfClass:UINavigationController.class]) {
            controller = [(UINavigationController *)controller visibleViewController];
        } else if ([controller isKindOfClass:UITabBarController.class]) {
            controller = [(UITabBarController *)controller selectedViewController];
        }
        if (controller.presentedViewController) {
            controller = controller.presentedViewController;
        } else {
            break;
        }
    }
    return controller;
}

- (void)setValue:(NSString *)value withKey:(NSString *)key forObject:(id)object {
    if ([object isKindOfClass:UIViewController.class]) {
        UIViewController *controller = (UIViewController *)object;
        objc_property_t property = class_getProperty(controller.class, [key UTF8String]);
        if (property) {
            // example from MJRefresh
            // get attrs
            NSString *attrs = [NSString stringWithUTF8String:property_getAttributes(property)];
            NSUInteger dotLoc = [attrs rangeOfString:@","].location;
            NSString *code = nil;
            NSUInteger loc = 1;
            if (dotLoc == NSNotFound) { // 没有,
                code = [attrs substringFromIndex:loc];
            } else {
                code = [attrs substringWithRange:NSMakeRange(loc, dotLoc - loc)];
            }

            // find type
            NSArray *numberTypes = @[MJPropertyTypeInt, MJPropertyTypeShort, MJPropertyTypeFloat, MJPropertyTypeDouble, MJPropertyTypeLong, MJPropertyTypeLongLong, MJPropertyTypeChar];
            NSArray *boolTypes = @[MJPropertyTypeBOOL1, MJPropertyTypeBOOL2];
            Class typeClass = nil;
            BOOL isNumbertype = nil;
            BOOL isBoolType = nil;
            if (code.length > 3 && [code hasPrefix:@"@\""]) {
                code = [code substringWithRange:NSMakeRange(2, code.length - 3)];
                typeClass = NSClassFromString(code);
                isNumbertype = [typeClass isSubclassOfClass:NSNumber.class];
            } else if ([numberTypes containsObject:code.lowercaseString]) {
                isNumbertype = YES;
            } else if ([boolTypes containsObject:code.lowercaseString]) {
                isBoolType = YES;
            }

            // type adapter
            NSObject *obj = nil;
            if (typeClass == NSString.class) {
                obj = value;
            } else if (typeClass == NSMutableString.class) {
                obj = [NSMutableString stringWithString:value];
            } else if (isNumbertype) {
                if (typeClass == NSDecimalNumber.class) {
                    obj = [NSDecimalNumber decimalNumberWithString:value];
                } else {
                    obj = [[[NSNumberFormatter alloc] init] numberFromString:value];
                }
            } else if (isBoolType) {
                NSString *lower = value.lowercaseString;
                if ([lower isEqualToString:@"yes"] || [lower isEqualToString:@"true"]) {
                    obj = @YES;
                } else if ([lower isEqualToString:@"no"] || [lower isEqualToString:@"false"]) {
                    obj = @NO;
                }
            }

            // set value
            if (obj) {
                [object setValue:obj forKey:key];
            }

            NSLog(@"%s %s %@", property_getName(property), property_getAttributes(property), code);
        }
    }

}

- (void)setObject:(id)object parameters:(NSDictionary<NSString *, NSString *> *)params {
    [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [self setValue:obj withKey:key forObject:object];
    }];
//    for (Class cls = controller.class; cls != NSObject.class; cls = class_getSuperclass(cls)) {
//        unsigned int outCount;
//        objc_property_t *properties = class_copyPropertyList(controller.class, &outCount);
//        for (unsigned int i = 0; i < outCount; i++) {
//            NSLog(@"%s", property_getAttributes(properties[i]));
//
//            NSString *attrs = @(property_getAttributes(properties[i]));
//            NSUInteger dotLoc = [attrs rangeOfString:@","].location;
//            NSString *code = nil;
//            NSUInteger loc = 1;
//            if (dotLoc == NSNotFound) { // 没有,
//                code = [attrs substringFromIndex:loc];
//            } else {
//                code = [attrs substringWithRange:NSMakeRange(loc, dotLoc - loc)];
//            }
//            NSLog(@"%@", code);
//        }
//        free(properties);
//    }

    // 方法列表
//    unsigned int outCount;
//    Method *method = class_copyMethodList(controller.class, &outCount);
//    for (unsigned int i = 0; i < outCount; i++) {
//        NSLog(@"%s", sel_getName(method_getName(method[i])));
//    }
//    free(method)

    // 方法参数类型 不同于property
//    [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
//        NSString *methodName = [NSString stringWithFormat:@"set%@:", [key capitalizedString]];
//        Method method = class_getInstanceMethod(controller.class, NSSelectorFromString(methodName));
//        if (method) {
//            NSLog(@"%s", method_getDescription(method)->types);
//            NSLog(@"%s", method_copyArgumentType(method, 0));
//            char *types = malloc(strlen(method_getDescription(method)->types) + 1);
//            strcpy(types, method_getDescription(method)->types);
//            NSLog(@"%s", types);
//        }
//    }];

    //  类型不匹配!!!
//    [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
//        NSString *methodName = [NSString stringWithFormat:@"set%@:", [key capitalizedString]];
//        NSMethodSignature *signature = [controller methodSignatureForSelector:NSSelectorFromString(methodName)];
//        if (signature) {
//            NSLog(@"%s", [signature getArgumentTypeAtIndex:0]);
//            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
//            invocation.target = controller;
//            invocation.selector = NSSelectorFromString(methodName);
//            [invocation setArgument:&obj atIndex:2];
//            [invocation invoke];
//        }
//    }];
}
@end
