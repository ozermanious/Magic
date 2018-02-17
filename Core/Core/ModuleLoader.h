//
//  ModuleLoader.h
//  Core
//
//  Created by Vladimir Ozerov on 17/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ModuleLoader : NSObject

/**
 Создать инстансы главных классов в модулях.
 */
- (void)initModules;

@end
