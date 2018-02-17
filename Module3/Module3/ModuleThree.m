//
//  ModuleThree.m
//  Module3
//
//  Created by Vladimir Ozerov on 17/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import "ModuleThree.h"
#import "Module3+Magic.h"
#import "Module3.Queen+Magic.h"
#import "Spellbook.h"


@interface ModuleThree () <ModuleThreeProtocol, ModuleThreeQueenProtocol>

@end


@implementation ModuleThree

- (NSArray<NSString *> *)peopleListInKingdom
{
	return @[
		@"Разработчик",
		@"Продукт-овнер",
		@"Тестировщик",
	];
}

- (void)beautifulQueen
{
	CLog(@"[Module3.Queen] А королева была прекрасна");
}

@end
