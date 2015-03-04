//
//  AB_KeyValueUpdater.h
//  WorkingCopy
//
//  Created by Anders Borum on 04/03/15.
//  Copyright (c) 2015 Applied Phasor. All rights reserved.
//
// Helps making simple updates where KVO observable changes on one object is automatically
// transferred to listening object, in such a way that listener does not need to explicitly
// stop listening when deallocated.

#import <Foundation/Foundation.h>

@interface NSObject (AB_KeyValueUpdater)

// Setup KVO notifications such that object itself has transferred any changes to sourceKey in sourceObject.
// You can remove this data-binding by calling unbindKey:fromObject:toKey: but this is not required on dealloc,
// as this case is handled by AB_KeyValueUpdater.
//
// Note that binding from sourceObject does not cause it to retained.
-(void)bindKey:(NSString*)sourceKey fromObject:(NSObject*)sourceObject toKey:(NSString*)myKeyPath;
-(void)bindKey:(NSString*)sourceKey fromObject:(NSObject*)sourceObject callback:(void (^)(id value))block;

// Remove any KVO notifications installed with call to bindKey:fromObject:toKey: but this is done
// in a way such that is safe to unbind unnecesarily.
-(void)unbindKey:(NSString*)sourceKey fromObject:(NSObject*)sourceObject toKey:(NSString*)myKeyPath;

// Shorthand that calls bindKey:fromObject:toKey: or bindKey:fromObject:callback: multiple times,
// where mapping keys are used as sourceKey and the value as myKey or callback block depending on type.
-(void)bindObject:(NSObject*)sourceObject mapping:(NSDictionary*)mapping;
-(void)unbindObject:(NSObject*)sourceObject mapping:(NSDictionary*)mapping;

// like bindKey:fromObject:toKey but will write inital values from sourceObject into self
-(void)bindInitialObject:(NSObject*)sourceObject mapping:(NSDictionary*)mapping;

// unbind all previous bindings
-(void)unbindObject:(NSObject*)sourceObject;
-(void)unbindAll;

@end
