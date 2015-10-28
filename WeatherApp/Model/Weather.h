//
//  Weather.h
//  WeatherApp
//
//  Created by User on 18.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OWMObject: NSDictionary <NSCoding>

- (instancetype)initWithJsonDictionary:(NSDictionary *)jsonDictionary;

@end

@interface OWMArrayObject<__covariant ObjectType: OWMObject*>: NSArray <NSCoding>

- (instancetype)initWithJsonArray:(NSArray *)jsonArray;

@end


@import CoreLocation;

@interface OWMPrecipitationObject : OWMObject
@end

@interface OWMMainObject : OWMObject
@property (nonatomic, strong, readonly) NSNumber *temp;
@property (nonatomic, strong, readonly) NSNumber *pressure;
@property (nonatomic, strong, readonly) NSNumber *humidity;
@property (nonatomic, strong, readonly) NSNumber *temp_min;
@property (nonatomic, strong, readonly) NSNumber *temp_max;
@property (nonatomic, strong, readonly) NSNumber *sea_level;
@property (nonatomic, strong, readonly) NSNumber *grnd_level;

@end

@interface OWMWindObject : OWMObject
@property (nonatomic, strong, readonly) NSNumber *speed;
@property (nonatomic, strong, readonly) NSNumber *deg;
@end

@interface OWMRainObject : OWMPrecipitationObject

@end

@interface OWMWeatherObject : OWMObject

@end

@interface OWMCloudsObject : OWMObject
@property (nonatomic, strong, readonly) NSNumber *all;
@end

@interface OWMSnowObject : OWMPrecipitationObject

@end

@interface OWMCityObject : OWMObject
@property (nonatomic, assign, readonly) CLLocationCoordinate2D coord;
@property (nonatomic, assign, readonly) NSString *country;
@property (nonatomic, strong, readonly) NSNumber *id;
@property (nonatomic, copy,   readonly) NSString *name;
@property (nonatomic, strong, readonly) NSNumber *population;
@end


@protocol OWMWeather <NSObject>

@required

@property (nonatomic, strong, readonly) OWMMainObject *main;
@property (nonatomic, strong, readonly) OWMArrayObject <OWMWeatherObject *> *weather;
@property (nonatomic, strong, readonly) NSNumber *dt;

@optional

@property (nonatomic, strong, readonly) OWMWindObject *wind;
@property (nonatomic, strong, readonly) OWMRainObject *rain;
@property (nonatomic, strong, readonly) OWMCloudsObject *clouds;
@property (nonatomic, strong, readonly) OWMSnowObject *snow;
@property (nonatomic, strong, readonly) NSString *dt_txt;

@end



@protocol OWMSysObject <NSObject>

@end


@protocol OWMResponseObject <NSObject>

@required
@property (nonatomic, strong, readonly) NSNumber *cod;

@end


@protocol OWMCurrentWeatherObject <OWMWeather, OWMResponseObject>

@required

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coord;
@property (nonatomic, copy,   readonly) NSString *name; // "name"
@property (nonatomic, strong, readonly) NSNumber *id; // "id"

@optional

@property (nonatomic, copy, readonly) NSString *base;
@property (nonatomic, strong, readonly) id <OWMSysObject> sys;


@end


@protocol OWMForecastObject <NSObject, OWMResponseObject>

@optional

@property (nonatomic, strong, readonly) OWMCityObject *city;
@property (nonatomic, copy, readonly) NSString *message;

@required

@property (nonatomic, strong, readonly) OWMArrayObject <OWMObject<OWMWeather> *> *list;

@end
