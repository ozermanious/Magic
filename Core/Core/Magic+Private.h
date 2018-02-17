//
//  Magic+Private.h
//  oundation
//
//  Created by Vladimir Ozerov on 02/02/2018.
//  Copyright © 2018 SberTech. All rights reserved.
//

#import <Core/Magic.h>


@protocol MagicDataSource;


@interface Magic ()

@property (nonatomic, weak) id<MagicDataSource> dataSource; /**< Источник данных для магического роутинга */

@end
