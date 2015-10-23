//
//  Weather.m
//  WeatherApp
//
//  Created by User on 18.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "Weather.h"

@interface Weather () <NSCoding>

@end

@implementation Weather

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
}

#pragma mark - Init

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary error:(NSError **)parseError {
    return [[Weather alloc] initWithDictionary:dictionary error:parseError];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary error:(NSError **)parseError {
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
