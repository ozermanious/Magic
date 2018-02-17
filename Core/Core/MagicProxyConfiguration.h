//
//  MagicProxyConfiguration.h
//  oundation
//
//  Created by Vladimir Ozerov on 02/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SuperModule;
@class MagicTargetedProtocol;
@protocol MagicDataSource;


/**
 Параметры магического прокси.
 */
@interface MagicProxyConfiguration : NSObject

@property (nonatomic, copy) NSArray<MagicTargetedProtocol *> *protocolList; /**< Список реализуемых протоколов */

@property (nonatomic, assign) BOOL isSpellbookProxy; /**< Флаг, это корневой прокси */
@property (nonatomic, assign) BOOL isModuleProxy; /**< Флаг, это прокси модуля */
@property (nonatomic, weak) SuperModule *module; /**< Модуль */
@property (nonatomic, weak) id<MagicDataSource> dataSource; /**< Источник данных для определения модуля */

/**
 Создать конфигурацию прокси для указанного свойства протокола.
 @param key Имя свойства.
 @param protocol Протокол, содержащий указанное свойство.
 @param parentConfiguration Конфигурация родительского прокси.
 @return Прокси.
 */
+ (instancetype)proxyConfigurationForProperty:(NSString *)key
								   inProtocol:(Protocol *)protocol
						  parentConfiguration:(MagicProxyConfiguration *)parentConfiguration;

/**
 Определить, к какому модулю относится прокси с данной конфигурацией.
 */
- (void)determineModuleIfNeeded;

/**
 Определить какой из протоколов содержит указанный селектор.
 @param selector Искомый селектор.
 @return Протокол.
 */
- (MagicTargetedProtocol *)protocolForSelector:(SEL)selector;

@end

