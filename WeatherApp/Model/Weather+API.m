//
//  Weather+API.m
//  WeatherApp
//
//  Created by User on 18.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "Weather+API.h"

@implementation Weather (API)


+ (Weather *)lastWeatherInContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dt" ascending:YES]];
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error) {
        return nil;
    }
    
    return results.lastObject;
}
    
    

+ (Weather *)weatherWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];

    NSNumber *dt = [dictionary valueForKey:@"dt"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dt == %@", dt];
    request.predicate = predicate;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dt" ascending:YES]];
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error) {
        return nil;
    }
    
    Weather *weather = results.firstObject;
    if (!weather) {
        weather = [NSEntityDescription insertNewObjectForEntityForName:@"Weather"
                                                 inManagedObjectContext:context];
        weather.dt = dt;
    }

    weather.name = [dictionary valueForKey:@"name"];
    NSDictionary *main = [dictionary valueForKey:@"main"];
    
    weather.temp = [main valueForKey:@"temp"];
    
    NSDictionary *weatherDic = [[dictionary valueForKey:@"weather"] firstObject];
    weather.weatherDescription = [weatherDic valueForKey:@"description"];
    //weather.weatherIcon = [weatherDic valueForKey:@"icon"];

    return weather;
}

@end
