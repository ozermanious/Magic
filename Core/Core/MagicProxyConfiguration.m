//
//  MagicProxyConfiguration.m
//  oundation
//
//  Created by Vladimir Ozerov on 02/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import "MagicProxyConfiguration.h"
#import "MagicTargetedProtocol.h"
#import "MagicRuntimeHelper.h"
#import "MagicDataSource.h"
#import <objc/runtime.h>


@implementation MagicProxyConfiguration

+ (instancetype)proxyConfigurationForProperty:(NSString *)key
								   inProtocol:(Protocol *)protocol
						  parentConfiguration:(MagicProxyConfiguration *)parentConfiguration
{
	objc_property_t property = protocol_getProperty(protocol, key.UTF8String, YES, YES);
	NSArray<NSString *> *protocolNameList = [MagicRuntimeHelper protocolNameListForProperty:property];
	
	NSMutableArray<MagicTargetedProtocol *> *protocolList = [NSMutableArray array];
	for (NSInteger protocolIndex = 0; protocolIndex < protocolNameList.count; protocolIndex++)
	{
		NSString *protocolName = protocolNameList[protocolIndex];
		MagicTargetedProtocol *resultProtocolInfo = [MagicTargetedProtocol protocolWithRawName:protocolName];
		if (resultProtocolInfo)
		{
			[protocolList addObject:resultProtocolInfo];
		}
	}
	
	MagicProxyConfiguration *configuration = [MagicProxyConfiguration new];
	configuration.protocolList = [protocolList copy];
	if (parentConfiguration)
	{
		configuration.isModuleProxy = parentConfiguration.isSpellbookProxy;
		configuration.module = parentConfiguration.module;
		configuration.dataSource = parentConfiguration.dataSource;
	}

	return configuration;
}

- (void)determineModuleIfNeeded
{
	if (self.module || !self.isModuleProxy)
	{
		return;
	}
	
	NSString *frameworkName = nil;
	for (MagicTargetedProtocol *protocolInfo in self.protocolList)
	{
		NSString *protocolName = NSStringFromProtocol(protocolInfo.protocol);
		if ([protocolName hasPrefix:MagicProtocolPrefix] &&
			![protocolName hasPrefix:MagicMockedProtocolPrefix])
		{
			frameworkName = [protocolName substringFromIndex:MagicProtocolPrefix.length];
			break;
		}
	}
	
	if (frameworkName.length)
	{
		NSError *error = nil;
		self.module = [self.dataSource moduleForFrameworkName:frameworkName error:&error];
	}
	else
	{
		CLog(@"MAGIC: Модуль не определен. %@", self.protocolList);
	}
}

- (MagicTargetedProtocol *)protocolForSelector:(SEL)selector
{
	for (MagicTargetedProtocol *protocolInfo in self.protocolList)
	{
		if ([MagicRuntimeHelper methodSignatureForSelector:selector
												   inProtocol:protocolInfo.protocol])
		{
			return protocolInfo;
		}
	}
	return nil;
}

@end
