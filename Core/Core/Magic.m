//
//  Magic.m
//  oundation
//
//  Created by Vladimir Ozerov on 26/12/2017.
//  Copyright © 2017 SberTech. All rights reserved.
//

#import "Magic.h"
#import "Magic+Private.h"
#import "MagicTargetedProtocol.h"
#import "MagicProxyConfiguration.h"
#import "MagicProxy.h"


@interface Magic ()

@property (nonatomic, strong) MagicProxyConfiguration *spellbookProxyConfiguration;
@property (nonatomic, strong) MagicProxy *spellbookProxy;

@end


@implementation Magic

- (instancetype)initMagic
{
	self = [super init];
	if (self)
	{
		_spellbookProxyConfiguration = [MagicProxyConfiguration new];
		_spellbookProxyConfiguration.protocolList = @[[MagicTargetedProtocol magicProtocolWithName:@"Spellbook"]];
		_spellbookProxyConfiguration.isSpellbookProxy = YES;
		
		_spellbookProxy = [MagicProxy proxyWithConfiguration:_spellbookProxyConfiguration];
	}
	return self;
}

+ (instancetype)shared
{
	static Magic *SharedInvocation = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		SharedInvocation = [[Magic alloc] initMagic];
	});
	return SharedInvocation;
}


#pragma mark - Properties

- (id<Spellbook>)spellbook
{
	return (id)self.spellbookProxy;
}

- (void)setDataSource:(id<MagicDataSource>)dataSource
{
	_dataSource = dataSource;
	self.spellbookProxyConfiguration.dataSource = dataSource;
}

@end
