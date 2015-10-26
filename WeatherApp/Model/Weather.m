//
//  Weather.m
//  WeatherApp
//
//  Created by User on 18.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "Weather.h"
#import <objc/runtime.h>

@interface Weather ()

@end

@implementation Weather

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString * name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        id value = [self valueForKey:name];
        [encoder encodeObject:value forKey:name];
    }
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if((self = [super init]))
    {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for (i = 0; i < outCount; i++)
        {
            objc_property_t property = properties[i];
            NSString * name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            id value = [decoder decodeObjectForKey:name];
            [self setValue:value forKey:name];
        }
    }
    
    return self;
}
#pragma mark - Init

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary error:(NSError **)parseError {
    return [[Weather alloc] initWithDictionary:dictionary error:parseError];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)parseError {
    self = [super init];
    if (self) {
        self.dt = dictionary[@"dt"];
        self.name = dictionary[@"name"];
        NSDictionary *main = dictionary[@"main"];
        self.temp = main[@"temp"];
        self.temp_min = main[@"temp_min"];
        self.temp_max = main[@"temp_max"];
        self.humidity = main[@"humidity"];
        NSDictionary *weatherDic = [dictionary[@"weather"] firstObject];
        self.weather = weatherDic;
    }
    return self;
}

@end
