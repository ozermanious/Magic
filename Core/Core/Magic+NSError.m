//
//  Magic+NSError.m
//  oundation
//
//  Created by Vladimir Ozerov on 05/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import "Magic+NSError.h"


NSString *const MagicErrorDomain = @"Magic";


@implementation NSError (Magic)

+ (NSString *)localizedDescriptionForMagicErrorCode:(MagicErrorCode)errorCode
{
	switch (errorCode)
	{
		case MagicErrorCodeUndefined:
			return nil;
		case MagicErrorCodeFrameworkModuleNotFound:
			return @"Не найден модуль для указанного Framework";
	}
}

+ (instancetype)errorWithMagicErrorCode:(MagicErrorCode)errorCode
{
	NSString *localizedDescription = [self localizedDescriptionForMagicErrorCode:errorCode];
	NSDictionary *userInfo = @{
		NSLocalizedDescriptionKey: localizedDescription
	};
	
	NSError *error = [NSError errorWithDomain:MagicErrorDomain
										 code:errorCode
									 userInfo:userInfo];
	return error;
}

@end
