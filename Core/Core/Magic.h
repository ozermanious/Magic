//
//  Magic.h
//  oundation
//
//  Created by Vladimir Ozerov on 26/12/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Предварительное объявление корневого MAGIC-протокола.
 @note Реальное определение протокола см. Magic/Spellbook.h
 (это генерируемый скриптом файл).
 */
@protocol Spellbook;


#define MAGIC [Magic shared].spellbook


/**
 Магический роутинг.
 */
@interface Magic : NSObject

@property (nonatomic, readonly) id<Spellbook> spellbook; /**< Корневой магический прокси */

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 Метод доступа к синглтону.
 @return Инстанс Magic.
 */
+ (instancetype)shared;

@end
