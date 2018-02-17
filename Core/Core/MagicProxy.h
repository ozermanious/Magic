//
//  MagicProxy.h
//  oundation
//
//  Created by Vladimir Ozerov on 29/12/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MagicProxyConfiguration;


/**
 Прокси, передающий NSInvocation в модуль при вызове заклинания.
 */
@interface MagicProxy : NSProxy

/**
 Создать Proxy с параметрами.
 @param configuration Конфигурация прокси.
 @return Инстанс прокси.
 */
+ (instancetype)proxyWithConfiguration:(MagicProxyConfiguration *)configuration;

@end
