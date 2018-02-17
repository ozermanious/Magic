//
//  MagicTargetedProtocol.h
//  oundation
//
//  Created by Vladimir Ozerov on 02/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const MagicMockedProtocolPrefix;
extern NSString *const MagicProtocolPrefix;


/**
 Вспомогательная структура, для списка протоколов магического Proxy
 @note Может быть два типа протоколов:
 - магические (mock == NO) - генерируемые протоколы, не имеющие реальных прототипов в проекте
 - моки (mock == YES) - протоколы - подмена реальных протоколов в файлах "*+Magic.h"
 */
@interface MagicTargetedProtocol : NSObject

@property (nonatomic, strong) Protocol *protocol; /**< Протокол */
@property (nonatomic, weak) id target; /**< Реальный объект, которому Proxy будет передавать NSInvocation */
@property (nonatomic, assign, getter=isMock) BOOL mock; /**< Флаг, мок-протокол */

/**
 Конструктор. Mock = NO.
 @param protocolName Имя протокола.
 @return Инстанс.
 */
+ (instancetype)magicProtocolWithName:(NSString *)protocolName;

/**
 Конструктор.
 @param rawProtocolName Необработанное имя протокола из Spellbook.
 @return Инстанс.
 */
+ (instancetype)protocolWithRawName:(NSString *)rawProtocolName;

@end
