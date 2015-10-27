//
//  Weather.m
//  WeatherApp
//
//  Created by User on 18.08.15.
//  Copyright (c) 2015 Alex Sheverdin. All rights reserved.
//

#import "Weather.h"
#import <objc/runtime.h>

// used internally by the category impl
typedef NS_ENUM(NSUInteger, SelectorInferredImplType) { // TODO: rename
    SelectorInferredImplTypeNone  = 0,
    SelectorInferredImplTypeGet = 1,
    SelectorInferredImplTypeSet = 2
};

@implementation OWMObject
{
    NSMutableDictionary *_content;
}

#pragma mark - NSCoding

static NSString *const kOWMObjectContentKey = @"content";

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_content forKey:kOWMObjectContentKey];
}

- (Class)classForCoder {
    return [self class];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        _content = [decoder decodeObjectForKey:kOWMObjectContentKey];
    }
    
    return self;
}

- (instancetype)initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    self = [super init];
    if (self) {
        _content = [NSMutableDictionary dictionaryWithDictionary:jsonDictionary];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    return [self initWithJsonDictionary:otherDictionary];
}

+ (instancetype)dictionaryWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithJsonDictionary:dict];
}

+ (instancetype)graphObjectWrappingObject:(id)originalObject {
    // non-array and non-dictionary case, returns original object
    id result = originalObject;
    
    // array and dictionary wrap
    if ([originalObject isKindOfClass:[NSDictionary class]]) {
        result = [[OWMObject alloc] initWithJsonDictionary: originalObject];
    }
    
    // return our object
    return result;
}

- (id)graphObjectifyAtKey:(id)key {
    id object = [_content objectForKey:key];
    // make certain it is FBObjectGraph-ified
    id possibleReplacement = [OWMObject graphObjectWrappingObject:object];
    if (object != possibleReplacement) {
        // and if not-yet, replace the original with the wrapped object
        [_content setObject:possibleReplacement forKey:key];
        object = possibleReplacement;
    }
    return object;
}

- (void)graphObjectifyAll {
    NSArray *keys = [_content allKeys];
    for (NSString *key in keys) {
        [self graphObjectifyAtKey:key];
    }
}

#pragma mark NSDictionary and NSMutableDictionary overrides

- (NSUInteger)count {
    return _content.count;
}

- (id)objectForKey:(id)key {
    return [self graphObjectifyAtKey:key];
}

- (NSEnumerator *)keyEnumerator {
    [self graphObjectifyAll];
    return _content.keyEnumerator;
}

- (void)setObject:(id)object forKey:(id)key {
    return [_content setObject:object forKey:key];
}

- (void)removeObjectForKey:(id)key {
    return [_content removeObjectForKey:key];
}

#pragma mark -
#pragma mark NSObject overrides


- (BOOL)respondsToSelector:(SEL)sel
{
    return  [super respondsToSelector:sel] ||
    ([OWMObject inferredImplTypeForSelector:sel] != SelectorInferredImplTypeNone);
}

- (BOOL)conformsToProtocol:(Protocol *)protocol {
    return  [super conformsToProtocol:protocol] ||
    ([self isProtocolImplementationInferable:protocol]);
    //TODO:
    // 1. send self not class
    // 2. get required methods of the protocol
    // 3. compare required methods from _jsonObject
}

// returns the signature for the method that we will actually invoke
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    SEL alternateSelector = sel;
    
    // if we should forward, to where?
    switch ([OWMObject inferredImplTypeForSelector:sel]) {
        case SelectorInferredImplTypeGet:
            alternateSelector = @selector(objectForKey:);
            break;
        case SelectorInferredImplTypeSet:
            alternateSelector = @selector(setObject:forKey:);
            break;
        case SelectorInferredImplTypeNone:
        default:
            break;
    }
    
    return [super methodSignatureForSelector:alternateSelector];
}

// forwards otherwise missing selectors that match the FBGraphObject convention
- (void)forwardInvocation:(NSInvocation *)invocation {
    // if we should forward, to where?
    switch ([OWMObject inferredImplTypeForSelector:[invocation selector]]) {
        case SelectorInferredImplTypeGet: {
            // property getter impl uses the selector name as an argument...
            NSString *propertyName = NSStringFromSelector([invocation selector]);
            [invocation setArgument:&propertyName atIndex:2];
            //... to the replacement method objectForKey:
            invocation.selector = @selector(objectForKey:);
            [invocation invokeWithTarget:self];
            break;
        }
        case SelectorInferredImplTypeSet: {
            // property setter impl uses the selector name as an argument...
            NSMutableString *propertyName = [NSMutableString stringWithString:NSStringFromSelector([invocation selector])];
            // remove 'set' and trailing ':', and lowercase the new first character
            [propertyName deleteCharactersInRange:NSMakeRange(0, 3)];                       // "set"
            [propertyName deleteCharactersInRange:NSMakeRange(propertyName.length - 1, 1)]; // ":"
            
            NSString *firstChar = [[propertyName substringWithRange:NSMakeRange(0,1)] lowercaseString];
            [propertyName replaceCharactersInRange:NSMakeRange(0, 1) withString:firstChar];
            // the object argument is already in the right place (2), but we need to set the key argument
            [invocation setArgument:&propertyName atIndex:3];
            // and replace the missing method with setObject:forKey:
            invocation.selector = @selector(setObject:forKey:);
            [invocation invokeWithTarget:self];
            break;
        }
        case SelectorInferredImplTypeNone:
        default:
            [super forwardInvocation:invocation];
            return;
    }
}

- (BOOL)isProtocolImplementationInferable:(Protocol *)protocol {
    // first handle base protocol questions
    
    unsigned int count = 0;
    struct objc_method_description *methods = nil;
    
    @try {
        // fetch methods of the protocol and confirm that each can be implemented automatically
        methods = protocol_copyMethodDescriptionList(protocol,
                                                     YES,   // required
                                                     YES,   // instance
                                                     &count);
        for (int index = 0; index < count; index++) {
            
            SEL selector = methods[index].name;
            if ([OWMObject inferredImplTypeForSelector:selector] == SelectorInferredImplTypeGet) {
                NSString *key = NSStringFromSelector(selector);
                if (![_content objectForKey:key]) {
                    return NO;
                }
            }
            
//            id object = objc_msgSend(self, selector);
//
//            if ([self performSelector:selector]) {
//
//            }
            
//            if (![self respondsToSelector:selector]) {
//                return NO;
//            }
                     }
    } @finally {
        if (methods) {
            free(methods);
        }
    }
    
    // protocol ran the gauntlet
    return YES;
}

// helper method used by the catgory implementation to determine whether a selector should be handled
+ (SelectorInferredImplType)inferredImplTypeForSelector:(SEL)sel {
    // the overhead in this impl is high relative to the cost of a normal property
    // accessor; if needed we will optimize by caching results of the following
    // processing, indexed by selector
    
    NSString *selectorName = NSStringFromSelector(sel);
    NSUInteger parameterCount = [[selectorName componentsSeparatedByString:@":"] count]-1;
    // we will process a selector as a getter if paramCount == 0
    if (parameterCount == 0) {
        return SelectorInferredImplTypeGet;
        // otherwise we consider a setter if...
    } else if (parameterCount == 1 &&                   // ... we have the correct arity
               [selectorName hasPrefix:@"set"] &&       // ... we have the proper prefix
               selectorName.length > 4) {               // ... there are characters other than "set" & ":"
        return SelectorInferredImplTypeSet;
    }
    
    return SelectorInferredImplTypeNone;
}

@end