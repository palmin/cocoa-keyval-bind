//
//  AB_KeyValueUpdater.m
//  WorkingCopy
//
//  Created by Anders Borum on 04/03/15.
//  Copyright (c) 2015 Applied Phasor. All rights reserved.
//

#import "AB_KeyValueUpdater.h"
#import <objc/message.h>

// contains information about a single object being observed
@interface AB_KeyValueObserved : NSObject
@property (nonatomic, weak) id observed;
@property (nonatomic, weak) id target;

// key is keyPath we are observing, value is NSMutableArray of keyPaths that should get this value when changed
@property (nonatomic, strong) NSMutableDictionary* mapping;

@end

@implementation AB_KeyValueObserved

// fast way to stop observing anything
-(void)unobserve {
    for (NSString* key in self.mapping) {
        [self.observed removeObserver:self forKeyPath:key];
    }
    [self.mapping removeAllObjects];
}

-(void)addMapping:(NSString*)sourceKey targetKey:(NSString*)targetKey {
    NSMutableArray* array = [self.mapping objectForKey:sourceKey];
    if(array == nil) {
        array = [NSMutableArray new];
        [self.mapping setObject:array forKey:sourceKey];

        [self.observed addObserver:self forKeyPath:sourceKey options:0 context:NULL];
    }
    [array addObject:targetKey];
}

-(void)removeMapping:(NSString*)sourceKey targetKey:(NSString*)targetKey {
    // we know there is nothing to do when no existing mappings, and quit early to avoid edge conditions
    NSMutableArray* array = [self.mapping objectForKey:sourceKey];
    if(array.count == 0) return;
    
    [array removeObjectIdenticalTo:targetKey];
    if(array.count == 0) {
        // we want to stop observing the given key if nobody are listening
        [self.observed removeObserver:self forKeyPath:sourceKey];
        [self.mapping removeObjectForKey:sourceKey];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                       change:(NSDictionary *)change context:(void *)context {
    // determine which key we map to
    NSArray* array = [self.mapping objectForKey:keyPath];
    if(array.count == 0) return;
    
    id value = [object valueForKeyPath:keyPath];
    for (NSString* targetKey in array) {
        [self.target setValue:value forKeyPath:targetKey];
    }
}

@end

// Helper object where at most one exists for each object used with the AB_KeyValueUpdater.
// Care is taken to only create this object when adding bindings, as unbind of something
// never bound should not create AB_KeyValueUpdater.
//
// AB_KeyValueUpdater holds a instance of AB_KeyValueObserved for each object we are binding from.
@interface AB_KeyValueUpdater : NSObject {
    // key is NSValue with pointer value, value is AB_KeyValueObserved element
    NSMutableDictionary* observedObject;
}

@end

@implementation AB_KeyValueUpdater

-(instancetype)init {
    self = [super init];
    if(self) {
        observedObject = [NSMutableDictionary new];
    }
    return self;
}

-(void)dealloc {
    for (AB_KeyValueObserved* observed in observedObject.allValues) {
        [observed unobserve];
    }
}

-(AB_KeyValueObserved*)observed:(id)object {
    NSNumber* key = [NSNumber numberWithInteger:(NSInteger)object];
    AB_KeyValueObserved* observed = [observedObject objectForKey:key];
    
    // there is the possibility that our weak reference to observed object
    // has been deallocated and then we cannot reuse the AB_KeyValueObserved
    if(observed.observed != object) return nil;
    
    return observed;
}

-(AB_KeyValueObserved*)ensureObserved:(id)object target:(id)target {
    AB_KeyValueObserved* observed = [self observed:object];
    if(observed == nil) {
        observed = [AB_KeyValueObserved new];
        observed.observed = object;
        observed.target = target;
        observed.mapping = [NSMutableDictionary new];
        
        NSNumber* key = [NSNumber numberWithInteger:(NSInteger)object];
        [observedObject setObject:observed forKey:key];
    }
    return observed;
}

-(void)bindKey:(NSString*)sourceKey fromObject:(NSObject*)sourceObject
         toKey:(NSString*)myKey target:(id)target {
    
    AB_KeyValueObserved* observed = [self ensureObserved:sourceObject target:target];
    [observed addMapping:sourceKey targetKey:myKey];
}

-(void)unbindKey:(NSString*)sourceKey fromObject:(NSObject*)sourceObject toKey:(NSString*)myKey {
    [[self observed:sourceObject] removeMapping:sourceKey targetKey:myKey];
}

@end

@implementation NSObject (AB_KeyValueUpdater)

static char associationObject;

-(AB_KeyValueUpdater*)AB_keyValueUpdater {
    return objc_getAssociatedObject(self, &associationObject);
}

-(AB_KeyValueUpdater*)AB_ensureKeyValueUpdater {
    AB_KeyValueUpdater* updater = [self AB_keyValueUpdater];
    if(updater == nil) {
        updater = [AB_KeyValueUpdater new];
        objc_setAssociatedObject (self, &associationObject, updater, OBJC_ASSOCIATION_RETAIN);
    }
    return updater;
}

-(void)bindKey:(NSString*)sourceKey fromObject:(NSObject*)sourceObject toKey:(NSString*)myKey {
    [[self AB_ensureKeyValueUpdater] bindKey:sourceKey fromObject:sourceObject
                                       toKey:myKey target:self];
}

-(void)unbindKey:(NSString*)sourceKey fromObject:(NSObject*)sourceObject toKey:(NSString*)myKey {
    [[self AB_keyValueUpdater] unbindKey:sourceKey fromObject:sourceObject toKey:myKey];
}

-(void)bindObject:(NSObject*)sourceObject mapping:(NSDictionary*)mapping {
    for (NSString* sourceKey in mapping) {
        NSString* myKey = [mapping objectForKey: sourceKey];
        [self bindKey:sourceKey fromObject:sourceObject toKey:myKey];
    }
}

-(void)unbindObject:(NSObject*)sourceObject mapping:(NSDictionary*)mapping {
    for (NSString* sourceKey in mapping) {
        NSString* myKey = [mapping objectForKey: sourceKey];
        [self unbindKey:sourceKey fromObject:sourceObject toKey:myKey];
    }
}

-(void)bindInitialObject:(NSObject*)sourceObject mapping:(NSDictionary*)mapping {
    [self bindObject:sourceObject mapping:mapping];
    
    for (NSString* sourceKey in mapping) {
        NSString* targetKey = [mapping objectForKey:sourceKey];
        id value = [sourceObject valueForKeyPath:sourceKey];
        [self setValue:value forKeyPath:targetKey];
    }
}

@end
