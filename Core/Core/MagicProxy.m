//
//  MagicProxy.m
//  oundation
//
//  Created by Vladimir Ozerov on 29/12/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "MagicProxy.h"
#import "MagicProxyConfiguration.h"
#import "MagicTargetedProtocol.h"
#import "MagicCommonSpellProxy.h"
#import "MagicRuntimeHelper.h"
#import <objc/runtime.h>


@interface MagicProxy ()
{
	/**
	 @note ivars использованы специально, чтобы не создавались методы-аксессоры у прокси-объекта.
	 Это может вызвать коллизии с методами протоколов при использовании прокси.
	 */
	MagicProxyConfiguration *_configuration;
	MagicCommonSpellProxy *_commonSpellProxy;
	NSMutableDictionary<NSString *, MagicProxy *> *_childProxyList;
}

@end


@implementation MagicProxy

- (instancetype)initMagicProxyWithConfiguration:(MagicProxyConfiguration *)configuration
{
	_configuration = configuration;
	_commonSpellProxy = nil;
	_childProxyList = [NSMutableDictionary dictionary];
	return self;
}

+ (instancetype)proxyWithConfiguration:(MagicProxyConfiguration *)configuration
{
	return [[MagicProxy alloc] initMagicProxyWithConfiguration:configuration];
}


#pragma mark - Proxy

- (void)forwardInvocation:(NSInvocation *)invocation
{
	[_configuration determineModuleIfNeeded];
	
	// Определяю, метод какого из поддерживаемых протоколов вызван
	MagicTargetedProtocol *matchedProtocolInfo = [_configuration protocolForSelector:invocation.selector];
	if (!matchedProtocolInfo)
	{
		CLog(@"MAGIC: Вызван метод, не реализованный Proxy. %@", NSStringFromSelector(invocation.selector));
		return;
	}
	
	// Специальная обработка для MagicCommonSpell
	if (matchedProtocolInfo.protocol == @protocol(MagicCommonSpell))
	{
		if (!_commonSpellProxy)
		{
			_commonSpellProxy = [MagicCommonSpellProxy new];
			_commonSpellProxy.sourceModule = _configuration.module;
		}
		matchedProtocolInfo.target = _commonSpellProxy;
	}
	// Если вызван метод внутреннего протокола, значит необходимо вернуть соответствующий Proxy
	else if (!matchedProtocolInfo.isMock)
	{
		NSString *proxyKey = NSStringFromSelector(invocation.selector);
		MagicProxy *proxy = _childProxyList[proxyKey];
		if (!proxy)
		{
			MagicProxyConfiguration *proxyConfiguration =
			[MagicProxyConfiguration proxyConfigurationForProperty:proxyKey
														   inProtocol:matchedProtocolInfo.protocol
												  parentConfiguration:_configuration];
			proxy = [MagicProxy proxyWithConfiguration:proxyConfiguration];
			_childProxyList[proxyKey] = proxy;
		}
		[invocation setReturnValue:&proxy];
		return;
	}
	// Перенаправляю NSInvocation реальному объекту
	else if (!matchedProtocolInfo.target)
	{
		matchedProtocolInfo.target = [MagicRuntimeHelper determineTargetForRootTarget:_configuration.module
																				protocol:matchedProtocolInfo.protocol];
		if (!matchedProtocolInfo.target)
		{
			CLog(@"MAGIC: Target в модуле не определен. %@ / %@", _configuration.module, NSStringFromProtocol(matchedProtocolInfo.protocol));
		}
	}

	[invocation invokeWithTarget:matchedProtocolInfo.target];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
	for (MagicTargetedProtocol *protocolInfo in _configuration.protocolList)
	{
		NSMethodSignature *signature = [MagicRuntimeHelper methodSignatureForSelector:selector
																			  inProtocol:protocolInfo.protocol];
		if (signature)
		{
			return signature;
		}
	}
	CLog(@"MAGIC: Не найдена сигнатура селектора. %@", NSStringFromSelector(selector));
	return nil;
}

@end
