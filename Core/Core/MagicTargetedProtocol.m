//
//  MagicTargetedProtocol.m
//  oundation
//
//  Created by Vladimir Ozerov on 02/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import "MagicTargetedProtocol.h"


NSString *const MagicMockedProtocolPrefix = @"MAGIC_MOCK_";
NSString *const MagicProtocolPrefix = @"MAGIC_";


@implementation MagicTargetedProtocol

+ (instancetype)magicProtocolWithName:(NSString *)protocolName
{
	MagicTargetedProtocol *protocolInfo = [self new];
	protocolInfo.protocol = NSProtocolFromString(protocolName);
	protocolInfo.mock = NO;
	return protocolInfo;
}

+ (instancetype)protocolWithRawName:(NSString *)rawProtocolName
{
	NSString *protocolName = nil;
	
	BOOL isMockProtocol = NO;
	if ([rawProtocolName hasPrefix:MagicMockedProtocolPrefix])
	{
		protocolName = [rawProtocolName substringFromIndex:MagicMockedProtocolPrefix.length];
		isMockProtocol = YES;
	}
	else
	{
		protocolName = rawProtocolName;
	}
	
	Protocol *protocol = NSProtocolFromString(protocolName);
	if (!protocol)
	{
		CLog(@"MAGIC: Ошибка определения протокола. %@ (%@)", protocolName, @(isMockProtocol));
		return nil;
	}
	
	MagicTargetedProtocol *protocolInfo = [MagicTargetedProtocol new];
	protocolInfo.protocol = protocol;
	protocolInfo.mock = isMockProtocol;
	return protocolInfo;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@(%@, %@, %@)",
			NSStringFromClass(self.class),
			NSStringFromProtocol(self.protocol),
			@(self.isMock),
			self.target];
}

@end
