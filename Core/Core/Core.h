//
//  Core.h
//  Core
//
//  Created by Vladimir Ozerov on 17/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for Core.
FOUNDATION_EXPORT double CoreVersionNumber;

//! Project version string for Core.
FOUNDATION_EXPORT const unsigned char CoreVersionString[];


#define CLog(FORMAT, ...) fprintf(stderr, "%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);


#import <Core/SuperModule.h>
#import <Core/ModuleLoader.h>
#import <Core/Magic.h>
#import <Core/MagicCommonSpell.h>
