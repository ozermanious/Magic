//
//  MagicRuntimeHelper.m
//  oundation
//
//  Created by Vladimir Ozerov on 02/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import "MagicRuntimeHelper.h"
#import <objc/runtime.h>


@implementation MagicRuntimeHelper

+ (id)determineTargetForRootTarget:(id)rootTarget
						  protocol:(Protocol *)protocol
{
	if ([rootTarget conformsToProtocol:protocol])
	{
		return rootTarget;
	}
	
	NSString *protocolName = NSStringFromProtocol(protocol);
	id target = nil;
	
	// Определяю, какое property модуля отвечает за вызванный интерфейс
	unsigned int count = 0;
	objc_property_t *propertyList = class_copyPropertyList([rootTarget class], &count);
	for (unsigned int propertyIndex = 0; propertyIndex < count; propertyIndex++)
	{
		objc_property_t property = propertyList[propertyIndex];
		NSArray<NSString *> *protocolNameList = [MagicRuntimeHelper protocolNameListForProperty:property];
		if ([protocolNameList containsObject:protocolName])
		{
			NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
			target = [rootTarget valueForKey:propertyName];
			break;
		}
	}
	free(propertyList);

	return target;
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)selector inProtocol:(Protocol *)protocol
{
	unsigned int desciptionsCount = 0;
	struct objc_method_description *descriptions = protocol_copyMethodDescriptionList(
		protocol,
		YES,
		YES,
		&desciptionsCount
	);
	for (unsigned int index = 0; index < desciptionsCount; index++)
	{
		if (descriptions[index].name == selector)
		{
			NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:descriptions[index].types];
			free(descriptions);
			return signature;
		}
	}
	free(descriptions);
	return nil;
}

+ (NSArray<NSString *> *)protocolNameListForProperty:(objc_property_t)property
{
	NSString *propertyType = [NSString stringWithUTF8String:property_getAttributes(property)];
	if (![propertyType hasPrefix:@"T@"])
	{
		return nil;
	}
	
	NSMutableArray<NSString *> *protocolNameList = [NSMutableArray array];

	// Вычленяю имя класса и определяю поддерживаемые им протоколы.
	NSRegularExpression *classRegexp = [NSRegularExpression regularExpressionWithPattern:@"@\"[A-Za-z0-9_]+"
																			options:0
																			  error:nil];
	NSTextCheckingResult *result = [classRegexp firstMatchInString:propertyType
														   options:0
															 range:NSMakeRange(0, propertyType.length)];
	if (result && result.range.location != NSNotFound)
	{
		NSRange range = NSMakeRange(result.range.location + 2, result.range.length - 2);
		NSString *className = [propertyType substringWithRange:range];
		Class class = NSClassFromString(className);

		if (class)
		{
			unsigned int count = 0;
			Protocol *__unsafe_unretained *protocolList = class_copyProtocolList(class, &count);
			for (unsigned int protocolIndex = 0; protocolIndex < count; protocolIndex++)
			{
				Protocol *protocol = protocolList[protocolIndex];
				[protocolNameList addObject:NSStringFromProtocol(protocol)];
			}
			free(protocolList);
		}
	}
	
	// Вычленяю список поддерживаемых протоколов свойства.
	NSRegularExpression *protocolsRegexp = [NSRegularExpression regularExpressionWithPattern:@"<[A-Za-z0-9_]+>"
																			options:0
																			  error:nil];
	NSArray<NSTextCheckingResult *> *resultList = [protocolsRegexp matchesInString:propertyType
																		   options:0
																			 range:NSMakeRange(0, propertyType.length)];
	for (NSTextCheckingResult *result in resultList)
	{
		NSString *protocolName = [propertyType substringWithRange:NSMakeRange(result.range.location + 1, result.range.length - 2)];

		// Определяю подпротоколы
		Protocol *protocol = NSProtocolFromString(protocolName);
		NSArray *subProtocolNameList = [MagicRuntimeHelper protocolNameListInheritedByProtocol:protocol];
		[protocolNameList addObjectsFromArray:subProtocolNameList];
		
		if (![protocolNameList containsObject:protocolName])
		{
			[protocolNameList addObject:protocolName];
		}
	}
	return [protocolNameList copy];
}

+ (NSArray<NSString *> *)protocolNameListInheritedByProtocol:(Protocol *)protocol
{
	if (!protocol)
	{
		return nil;
	}
	
	NSMutableArray<NSString *> *protocolNameList = [NSMutableArray array];
	unsigned int count = 0;
	Protocol * __unsafe_unretained *protocolList = protocol_copyProtocolList(protocol, &count);
	for (unsigned int protocolIndex = 0; protocolIndex < count; protocolIndex++)
	{
		Protocol *subProtocol = protocolList[protocolIndex];
		[protocolNameList addObject:NSStringFromProtocol(subProtocol)];
	}
	free(protocolList);
	return [protocolNameList copy];
}

@end
