//
//  Forecast+API.m
//  WeatherApp
//
//  Created by User on 17.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "Forecast+API.h"

@implementation Forecast (API)

+ (Forecast *)forecastWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
//    NSRange range = NSMakeRange(0, 16);
//    NSString *dt_txt = [[dictionary valueForKey:@"dt_txt"] substringWithRange: range];
    NSString *dt_txt = [dictionary valueForKey:@"dt_txt"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dt_txt == %@", dt_txt];
    request.predicate = predicate;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dt_txt" ascending:YES]];
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error) {
        return nil;
    }
    
    Forecast *forecast = results.firstObject;
    if (!forecast) {
        forecast = [NSEntityDescription insertNewObjectForEntityForName:@"Forecast"
                                                inManagedObjectContext:context];
        forecast.dt_txt = dt_txt;
    }
    
    NSDictionary *main = [dictionary valueForKey:@"main"];
   
    forecast.temp = [main valueForKey:@"temp"];
    NSDictionary *weather = [[dictionary valueForKey:@"weather"] firstObject];
    forecast.wDescription = [weather valueForKey:@"description"];
    forecast.icon = [weather valueForKey:@"icon"];
 
    return forecast;
}

@end
