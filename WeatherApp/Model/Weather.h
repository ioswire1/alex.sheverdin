//
//  Weather.h
//  WeatherApp
//
//  Created by User on 18.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather : NSObject

@property (nonatomic, strong) NSNumber * dt;
@property (nonatomic, strong) NSNumber * temp;
@property (nonatomic, strong) NSNumber * temp_min;
@property (nonatomic, strong) NSNumber * temp_max;
@property (nonatomic, strong) NSNumber * pressure;
@property (nonatomic, strong) NSNumber * humidity;
@property (nonatomic, copy) NSString * weatherDescription;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, strong) NSNumber * windSpeed;
@property (nonatomic, strong) NSNumber * windDeg;

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)saveToFile:(NSURL *)filePath;
- (void)loadFromFile:(NSURL *)filePath;

@end
