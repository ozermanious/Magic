//
//  MagicCommonSpellProxy.h
//  oundation
//
//  Created by Vladimir Ozerov on 01/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Core/MagicCommonSpell.h>


/**
 Объект, реализующий общую магическую функциональность модулей, описанную протоколом MagicCommonSpell.
 */
@interface MagicCommonSpellProxy : NSObject <MagicCommonSpell>

@property (nonatomic, weak) SuperModule *sourceModule; /**< Модуль */

@end
