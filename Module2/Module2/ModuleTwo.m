//
//  ModuleTwo.m
//  Module2
//
//  Created by Vladimir Ozerov on 17/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import "ModuleTwo.h"
#import "Module2+Magic.h"
#import "King.h"
#import "Spellbook.h"


@interface ModuleTwo () <ModuleTwoProtocol>

@property (nonatomic, strong) King *king;

@end


@implementation ModuleTwo

- (King *)king
{
	if (!_king)
	{
		_king = [King new];
	}
	return _king;
}

- (void)aboutKingdom:(NSString *)kingdomName
{
	CLog(@"[Module2] В тридевятом царстве, в тридевятом королевстве (под названием %@)", kingdomName);
}

@end
