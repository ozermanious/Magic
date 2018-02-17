//
//  Magic+NSError.h
//  oundation
//
//  Created by Vladimir Ozerov on 05/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const MagicErrorDomain; /**< Домен ошибок магического роутинга */


/**
 Список кодов ошибок магического роутинга.
 @discussion Описание ошибок см. в реализации.
 */
typedef NS_ENUM(NSUInteger, MagicErrorCode) {
	MagicErrorCodeUndefined = 0,
	MagicErrorCodeFrameworkModuleNotFound,
};


/**
 Категория NSError для Magic.
 */
@interface NSError (Magic)

/**
 Создать ошибку БД с определенным кодом.
 @param errorCode Код ошибки.
 @return Ошибка.
 */
+ (instancetype)errorWithMagicErrorCode:(MagicErrorCode)errorCode;

@end
