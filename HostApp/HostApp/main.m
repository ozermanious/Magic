//
//  main.m
//  HostApp
//
//  Created by Vladimir Ozerov on 17/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Core/Core.h>
#import "Spellbook.h"



int main(int argc, const char * argv[])
{
	@autoreleasepool
	{
		ModuleLoader *moduleLoader = [ModuleLoader new];
		[moduleLoader initModules];
		
		NSArray *moduleList = @[
			MAGIC.Module1.module ?: [NSNull null],
			MAGIC.Module2.module ?: [NSNull null],
			MAGIC.Module3.module ?: [NSNull null],
		];
		CLog(@"[main] Модули загружены: %@", moduleList);
		CLog(@"\n\n");
		
		[MAGIC.Module1 startStory];

		CLog(@"\n\n");
	}
	return 0;
}
