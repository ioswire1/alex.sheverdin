//
//  Forecast.h
//  WeatherApp
//
//  Created by User on 17.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Forecast : NSManagedObject

@property (nonatomic, retain) NSString * dt_txt;
@property (nonatomic, retain) NSNumber * temp;
@property (nonatomic, retain) NSString * wDescription;
@property (nonatomic, retain) id icon;

@end
