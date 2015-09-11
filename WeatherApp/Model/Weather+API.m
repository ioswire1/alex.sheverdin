//
//  Weather+API.m
//  WeatherApp
//
//  Created by User on 18.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "Weather+API.h"
#import <UIKit/UIKit.h>


@implementation Weather (API)


+ (Weather *)lastWeatherInContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    
    //request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dt" ascending:YES]];
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error) {
        return nil;
    }
    for (Weather *weather in results) {
        NSLog(@"name = %@ %@", weather.name, weather.dt);
    }
    Weather *weather = results.lastObject;

    return weather;
}
    
    

+ (Weather *)weatherWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];

    NSNumber *dt = [dictionary valueForKey:@"dt"];
    NSString *name = [dictionary valueForKey:@"name"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dt == %@ AND name == %@"  , dt, name];
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

//    weather.name = [dictionary valueForKey:@"name"];
    weather.name = name;
    NSDictionary *main = [dictionary valueForKey:@"main"];
    
    weather.temp = [main valueForKey:@"temp"];
    
    NSDictionary *weatherDic = [[dictionary valueForKey:@"weather"] firstObject];
    weather.weatherDescription = [weatherDic valueForKey:@"description"];
    //weather.weatherIcon = [weatherDic valueForKey:@"icon"];
    
    NSString *urlOfImage = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png",[weatherDic valueForKey:@"icon"]];
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlOfImage]]];
   
    weather.weatherIcon = image;
    
    return weather;
    
}

@end
