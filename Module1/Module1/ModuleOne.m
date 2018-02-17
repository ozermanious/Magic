//
//  ModuleOne.m
//  Module1
//
//  Created by Vladimir Ozerov on 17/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import "ModuleOne.h"
#import "Module1+Magic.h"
#import "Spellbook.h"


@interface ModuleOne () <ModuleOneProtocol>

@end


@implementation ModuleOne

- (void)startStory
{
	CLog(@"[Module1] --=Начало истории=--");
	
	[MAGIC.Module2 aboutKingdom:@"Сбербанкия"];
	
	[MAGIC.Module2.King badKing];

	[MAGIC.Module3.Queen beautifulQueen];
	
	NSArray<NSString *> *people = [MAGIC.Module3 peopleListInKingdom];
	[MAGIC.Module1 tellWhoLiveInKingdom:people];

	CLog(@"[Module1] --=Конец=--");
}

- (void)tellWhoLiveInKingdom:(NSArray<NSString *> *)peopleList
{
	CLog(@"[Module1] И в этом государстве жили %@", [peopleList componentsJoinedByString:@", "]);
}

@end
