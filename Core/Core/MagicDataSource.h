//
//  MagicDataSource.h
//  oundation
//
//  Created by Vladimir Ozerov on 02/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//


@class SuperModule;


@protocol MagicDataSource

- (SuperModule *)moduleForFrameworkName:(NSString *)frameworkName
									 error:(out NSError *__autoreleasing *)error;

@end
