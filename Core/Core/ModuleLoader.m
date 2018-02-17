//
//  ModuleLoader.m
//  Core
//
//  Created by Vladimir Ozerov on 17/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import "ModuleLoader.h"
#import "Magic+Private.h"
#import "MagicDataSource.h"
#import "Magic+NSError.h"
#import <objc/runtime.h>


@interface ModuleLoader () <MagicDataSource>

@property (nonatomic, strong) NSArray<SuperModule *> *moduleList;

@end


@implementation ModuleLoader

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		[Magic shared].dataSource = self;
	}
	return self;
}

- (void)initModules
{
	/**
	 Этап 1.
	 Через runtime определяем, какие классы реализуют протокол SBFModuleProtocol
	 */
	int classListCount = objc_getClassList(NULL, 0);
	Class *classListPointer = NULL;
	
	classListPointer = (__unsafe_unretained Class *)malloc(sizeof(Class) * classListCount);
	classListCount = objc_getClassList(classListPointer, classListCount);
	
	Class superModuleClass = [SuperModule class];
	
	NSMutableArray<Class> *classList = [NSMutableArray array];
	for (NSInteger classIndex = 0; classIndex < classListCount; classIndex += 1)
	{
		Class clazz = classListPointer[classIndex];
		if (class_getSuperclass(clazz) == superModuleClass)
		{
			[classList addObject:(id)clazz];
		}
	}
	free(classListPointer);
	
	/**
	 Этап 2.
	 Создаем модули
	 */
	NSMutableArray *moduleList = [NSMutableArray array];
	for (Class moduleClass in classList)
	{
		id module = [(Class)moduleClass new];
#ifdef DEBUG_MODE
		LogSystem(@"Creating module [%@]", NSStringFromClass([module class]));
#endif
		[moduleList addObject:module];
	}
	self.moduleList = [moduleList copy];
}


#pragma mark - MagicDataSource

- (SuperModule *)moduleForFrameworkName:(NSString *)frameworkName error:(out NSError *__autoreleasing *)error
{
	/**
	 В дальнейшем здесь можно будет реализовать логику Lazy-подгрузки
	 необходимых модулей при первом обращении к ним через MAGIC.
	 */
	
	for (SuperModule *module in self.moduleList)
	{
		NSBundle *moduleBundle = [NSBundle bundleForClass:module.class];
		NSString *moduleXcodeprojName = moduleBundle.executablePath.lastPathComponent;
		if ([moduleXcodeprojName isEqualToString:frameworkName])
		{
			return module;
		}
	}
	
	if (error)
	{
		*error = [NSError errorWithMagicErrorCode:MagicErrorCodeFrameworkModuleNotFound];
	}
	return nil;
}

@end
