//
//  Weather.h
//  WeatherApp
//
//  Created by User on 18.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Weather : NSManagedObject

@property (nonatomic, retain) NSNumber * dt;
@property (nonatomic, retain) NSNumber * temp;
@property (nonatomic, retain) NSNumber * temp_min;
@property (nonatomic, retain) NSNumber * temp_max;
@property (nonatomic, retain) NSNumber * pressure;
@property (nonatomic, retain) NSNumber * humidity;
@property (nonatomic, retain) NSString * weatherDescription;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * windSpeed;
@property (nonatomic, retain) NSNumber * windDeg;
@property (nonatomic, retain) id weatherIcon;

@end
