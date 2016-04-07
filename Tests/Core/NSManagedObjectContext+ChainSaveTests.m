//
//  NSManagedObjectContext+ChainSaveTests.m
//  MagicalRecord
//
//  Created by Lee on 12/1/14.
//  Copyright (c) 2014 Magical Panda Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MagicalRecordTestBase.h"
#import "NSManagedObjectContext+MagicalChainSave.h"
#import "SingleEntityWithNoRelationships.h"

@interface NSManagedObjectContext_ChainSaveTests : MagicalRecordTestBase

@end

@implementation NSManagedObjectContext_ChainSaveTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testChainSave {
    //Test if a new Object can save from child context to parent context
    __block NSManagedObjectID *childObjectID;
    
    NSManagedObjectContext *defaultContext = [NSManagedObjectContext MR_defaultContext];
    
    [defaultContext MR_saveWithBlock:^(NSManagedObjectContext *localContext) {
        SingleEntityWithNoRelationships *insertedObject = [SingleEntityWithNoRelationships MR_createEntityInContext:childContext];
        
        expect([insertedObject hasChanges]).to.beTruthy();
        
        NSError *obtainIDsError;
        BOOL obtainIDsResult = [childContext obtainPermanentIDsForObjects:@[insertedObject] error:&obtainIDsError];
        
        expect(obtainIDsResult).to.beTruthy();
        expect(obtainIDsError).to.beNil();
        
        childObjectID = insertedObject.objectID;
        
        expect(childObjectID).toNot.beNil();
        expect([childObjectID isTemporaryID]).to.beFalsy();
        
    } completion:^(BOOL success, NSError *error) {
        
        //test parent and root saving context
        SingleEntityWithNoRelationships *parentObject = [defaultContext objectWithID:childObjectID];
        
        expect(parentObject).toNot.beNil();
        
        SingleEntityWithNoRelationships *rootObject = [[NSManagedObjectContext MR_rootSavingContext] objectWithID:childObjectID];
        
        expect(rootObject).toNot.beNil();
        
    }];
}

@end
