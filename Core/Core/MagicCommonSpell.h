//
//  MagicCommonSpell.h
//  oundation
//
//  Created by Vladimir Ozerov on 01/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//


@class SuperModule;


/**
 Протокол, реализуемый каждым корневым элементом Spellbook
 */
@protocol MagicCommonSpell

@property (nonatomic, readonly) SuperModule *module; /**< Возвращает инстанс модуля */

@end
