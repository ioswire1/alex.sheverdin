//
//  Weather+API.h
//  WeatherApp
//
//  Created by User on 18.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "Weather.h"

@interface Weather (API)

+ (Weather *)weatherWithDictionary:(NSDictionary *)dictionary
                         inContext:(NSManagedObjectContext *)context;
+ (Weather *)lastWeatherInContext:(NSManagedObjectContext *)context;


@end
