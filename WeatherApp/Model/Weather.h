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

@interface OWMTempObject : OWMObject
@property (nonatomic, strong, readonly) NSNumber *day;
@property (nonatomic, strong, readonly) NSNumber *min;
@property (nonatomic, strong, readonly) NSNumber *max;
@property (nonatomic, strong, readonly) NSNumber *night;
@property (nonatomic, strong, readonly) NSNumber *eve;
@property (nonatomic, strong, readonly) NSNumber *morn;

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




@protocol OWMWeatherCore

@required

@property (nonatomic, strong, readonly) OWMArrayObject <OWMWeatherObject *> *weather;
@property (nonatomic, strong, readonly) NSNumber *dt;

@optional

@property (nonatomic, strong, readonly) OWMWindObject *wind;
@property (nonatomic, strong, readonly) OWMRainObject *rain;
@property (nonatomic, strong, readonly) OWMCloudsObject *clouds;
@property (nonatomic, strong, readonly) OWMSnowObject *snow;
@property (nonatomic, strong, readonly) NSString *dt_txt;

@end



@protocol OWMWeather <NSObject, OWMWeatherCore>

@property (nonatomic, strong, readonly) OWMMainObject *main;

@end

@protocol OWMWeatherDaily <NSObject, OWMWeatherCore>

@property (nonatomic, strong, readonly) OWMTempObject *temp;

@end


@protocol OWMSysObject <NSObject>

@end

typedef NS_ENUM(NSUInteger, DayTime) {
    DayTimeMorning,
    DayTimeDay,
    DayTimeEvening,
    DayTimeNigth
};

@interface OWMWeatherSysObject : OWMObject <OWMSysObject>

@property (nonatomic, readonly) DayTime dayTime;
@property (nonatomic, readonly) NSString *country;

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
@property (nonatomic, strong, readonly) OWMWeatherSysObject <OWMSysObject> *sys;


@end


@protocol OWMForecastObject <NSObject, OWMResponseObject>

@optional

@property (nonatomic, strong, readonly) OWMCityObject *city;
@property (nonatomic, copy, readonly) NSString *message;

@required

@property (nonatomic, strong, readonly) OWMArrayObject <OWMObject<OWMWeather> *> *list;

@end


@protocol OWMForecastDailyObject <NSObject, OWMResponseObject>

@optional

@property (nonatomic, strong, readonly) OWMCityObject *city;
@property (nonatomic, copy, readonly) NSString *message;

@required

@property (nonatomic, strong, readonly) OWMArrayObject <OWMObject<OWMWeatherDaily> *> *list;

@end
