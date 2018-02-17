//
//  MagicRuntimeHelper.h
//  oundation
//
//  Created by Vladimir Ozerov on 02/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct objc_property *objc_property_t;
@class Protocol;


/**
 Инкапсуляция работы магического роутинга с Runtime.
 */
@interface MagicRuntimeHelper : NSObject

/**
 Вернуть объект, реализующий указанный интерфейс.
 @discussion Метод может вернуть либо корневой объект, либо одно из свойств корневого объекта.
 @param rootTarget Объект, в котором производить поиск.
 @param protocol Искомый интерфейс.
 @return Объект, реализующий указанный интерфейс.
 */
+ (id)determineTargetForRootTarget:(id)rootTarget
						  protocol:(Protocol *)protocol;

/**
 Вернуть сигнатуру метода протокола.
 @param selector Селектор искомого метода.
 @param protocol Протокол, содержащий искомый метод.
 @return Сигнатура метода.
 */
+ (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
									   inProtocol:(Protocol *)protocol;

/**
 Вернуть список имен протоколов, реализуемых свойством.
 @param property Описание свойства.
 @return Список имен протоколов.
 */
+ (NSArray<NSString *> *)protocolNameListForProperty:(objc_property_t)property;

@end
