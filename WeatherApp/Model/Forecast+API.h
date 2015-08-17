//
//  Forecast+API.h
//  WeatherApp
//
//  Created by User on 17.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "Forecast.h"

@interface Forecast (API)

+ (Forecast *)forecastWithDictionary:(NSDictionary *)dictionary
                         inContext:(NSManagedObjectContext *)context;

@end
