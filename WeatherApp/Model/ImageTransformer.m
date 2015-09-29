//
//  ImageTransformer.m
//  WeatherApp
//
//  Created by User on 18.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "ImageTransformer.h"
#import <UIKit/UIKit.h>

@implementation ImageTransformer

+ (Class)transformedValueClass {
    return [NSData class];
}

+ (BOOL)allowsReverseTransformation {
    return YES;
}

- (id)transformedValue:(id)value {
    if (!value) {
        return nil;
    }
    if ([value isKindOfClass:[NSData class]]) {
        return value;
    }
    return UIImagePNGRepresentation(value);
}

- (id)reverseTransformedValue:(id)value {
    return [UIImage imageWithData:value];
}

@end
