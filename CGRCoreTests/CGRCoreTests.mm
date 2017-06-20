//
//  CGRCoreTests.m
//  CGRCoreTests
//
//  Created by Alfredo Cruz on 10/15/13.
//  Copyright (c) 2013 Alfredo Cruz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CGRGeometricGraph.h"
#import "CGRGeometricGraphDrawing.h"
#import "CGRGraph.h"
#import "CGRCircularList.h"
#import <mach/mach.h>
#import <CGRCore/CGRCircularVector.h>
#import <CGRCore/CGRAVLTree.h>
#import <CGRCore/CGRLinearStack.h>
#import <CGRCore/CGRGeometricGraph_Constrains.h>
#import <math.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <vector>
//#include "vector.hpp"
//#include <boost/numeric/ublas/io.hpp>

@interface ConstrainTest : NSObject <CGRGeometricGraph_Constrains>

@end

@implementation ConstrainTest

/*-(BOOL)canAddVertex:(NSPoint)location
{
    return YES;
}*/

@end


@interface CGRCoreTests : XCTestCase

@end

@implementation CGRCoreTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)gridWithMemoryUsage
{
    CGRGraph *graph = [[CGRGraph alloc]init];
    /*
     for(uint32_t i=0; i != 3000; i++){
     for(uint32_t j=0; j != 3000; j++){
     [graph addVertex:NSMakePoint(i*0.1, j*0.1)];
     }
     }*/
    for(uint32_t row = 0; row != 3000; row++){
        for(uint32_t column = 0; column != 3000; column++){
            if(column != 2999){
                [graph addEdge:makeEdge(row*3000 + column, row*3000 + column+1)];
                NSLog(@"%u",[graph vertexSetSize]);
                [graph addEdge:makeEdge(row*3000 + column, (row+1)*3000+column+1)];
            }
            if(column != 0){
                [graph addEdge:makeEdge(row*3000+column, (row+1)*3000 + column-1)];
            }
            [graph addEdge:makeEdge(row*3000 + column, (row + 1)*3000 + column)];
            
        }
    }
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in bytes): %lu", info.resident_size);
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
}


struct testStats
{
    uint32_t numberOfQueries, numberOfAdds, numberOfInserts, numberOfDeletes;
    uint64_t elapsedTime;
    uint64_t usedMemory;
    
};


-(struct testStats) testStdVector:(unsigned int)seed
{
    uint32_t numberOfQueries, numberOfAdds, numberOfInserts, numberOfDeletes;
    
    numberOfQueries = 0; numberOfAdds = 0; numberOfInserts = 0; numberOfDeletes = 0;
    
    uint64_t startTime, endTime;
    
    
    printf("Test Start...\n\n");
    
    startTime = mach_absolute_time();
    
    
    std::vector<uint32_t> *vector = new std::vector<uint32_t>();
    for(unsigned int i=0; i != 50000000; i++){
        vector ->push_back(i);
    }
    srandom(seed);
    for(unsigned int i=0; i != 1000000; i++){
        uint32_t action = random() % 4;
        if(action == 0)
        {
            //query
            uint32_t index = (uint32_t)(random()%vector ->size());
            vector ->at(index);
            numberOfQueries++;
        }else if (action == 1){
            //insert at
            uint32_t index = (uint32_t)(random()%vector ->size());
            vector ->insert(vector ->begin() + index, i);
            numberOfInserts++;
        }else if(action == 2){
            //remove
            uint32_t index = (uint32_t)(random()%vector ->size());
            vector ->erase(vector ->begin() + index);
            numberOfDeletes++;
        }else if(action == 3)
        {
            //add
            vector ->push_back(i);
            numberOfAdds++;
        }
    }
    endTime = mach_absolute_time();
    
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    task_info(mach_task_self(),
              TASK_BASIC_INFO,
              (task_info_t)&info,
              &size);
    struct testStats stats;
    stats.numberOfAdds = numberOfAdds;
    stats.numberOfDeletes = numberOfDeletes;
    stats.numberOfInserts = numberOfInserts;
    stats.numberOfQueries = numberOfQueries;
    stats.elapsedTime = endTime - startTime;
    stats.usedMemory = info.resident_size;
    
    
    delete vector;
    
    printf("Test Finished:\n\tNumber of Inserts: %d\n\tNumber of Deletes: %d\n\tNumber Of Adds: %d\n\tNumber Of Queries: %d\n\tTime elapsed: %f\n\n",numberOfInserts,numberOfDeletes,numberOfAdds,numberOfQueries, (endTime-startTime)/1000000000.0);
    
    return stats;
    
}

inline int testIntsEq(uint32_t a, uint32_t b){
    if(a == b){
        return 0;
    }
    if(a < b)
        return -1;
    return 1;
}


-(struct testStats) testCircularVector:(unsigned int)seed
{
    uint32_t numberOfQueries, numberOfAdds, numberOfInserts, numberOfDeletes;
    
    numberOfQueries = 0; numberOfAdds = 0; numberOfInserts = 0; numberOfDeletes = 0;
    
    uint64_t startTime, endTime;
    
    
    //printf("Test Start...\n");
    
    startTime = mach_absolute_time();
    
    srandom(seed);
    
    CGRCircularVector<uint32_t> *vector = new CGRCircularVector<uint32_t>();
    vector ->setComparator(&testIntsEq);
    for(unsigned int i=0; i != 500000; i++){
        vector ->add((uint32_t)random());
        //vector ->add(500000-i);
    }
    
    
    for(uint32_t i=0; i != 1000; i++){
        vector ->insertAtIndex(0, 0);
    }
    
    /*
    //Remove the first chunk
    for(uint32_t i=0; i != 500; i++){
        vector ->removeAtIndex(0);
    }
    vector ->insertAtIndex(1, 10);
    */
    
    
    
    
    //vector ->sortVector();
    /*
    uint32_t vecSize = vector ->count();
    
    for(uint32_t i=1; i != vecSize; i++){
        if(vector ->elementAtIndex(i) < vector ->elementAtIndex(i-1)){
            NSLog(@"Oops");
        }
    }*/
    for(unsigned int i=0; i != 100000; i++){
        uint32_t action = random() % 4;
        if(action == 0)
        {
            //query
            uint32_t index = random()%vector ->count();
            vector ->elementAtIndex(index);
            numberOfQueries++;
        }else if (action == 1){
            //insert at
            uint32_t index = random()%vector ->count();
            uint32_t newElem = (uint32_t)random();
            vector ->insertAtIndex(newElem, index);
            
            numberOfInserts++;
        }else if(action == 2){
            //remove
            uint32_t index = random()%vector ->count();
            vector ->removeAtIndex(index);
            numberOfDeletes++;
        }else if(action == 3)
        {
            //add
            uint32_t newElem = (uint32_t)random();
            vector ->add(newElem);
            numberOfAdds++;
        }
    }
    /*uint32_t vecSize = vector ->count();
    
    for(uint32_t i=1; i != vecSize; i++){
        if(vector ->elementAtIndex(i) < vector ->elementAtIndex(i-1)){
            NSLog(@"Oops");
        }
    }*/
    
    vector ->sortVector();
    
    vector ->startIteratingFromIndex(vector ->count() - 1);
    vector ->curntItem();
    
    endTime = mach_absolute_time();
    
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    struct testStats stats;
    stats.numberOfAdds = numberOfAdds;
    stats.numberOfDeletes = numberOfDeletes;
    stats.numberOfInserts = numberOfInserts;
    stats.numberOfQueries = numberOfQueries;
    stats.elapsedTime = endTime - startTime;
    stats.usedMemory = info.resident_size;
    
    
    delete vector;
    
    printf("Test Finished:\n\tNumber of Inserts: %d\n\tNumber of Deletes: %d\n\tNumber Of Adds: %d\n\tNumber Of Queries: %d\n\tTime elapsed: %f\n\n",numberOfInserts,numberOfDeletes,numberOfAdds,numberOfQueries, (endTime-startTime)/1000000000.0);
    
    return stats;
    
}

int comp(uint32_t *a, uint32_t *b){
    if(*a < *b)
        return NSOrderedAscending;
    if(*a > *b)
        return NSOrderedDescending;
    return NSOrderedSame;
}

/*-(void)testAVLTree
{
    CGRAVLTree<uint32_t, uint32_t> *testTree;
    testTree = new CGRAVLTree<uint32_t, uint32_t>(comp);
    for(uint32_t i=0; i != 200; i++){
        
        for(uint32_t j=0; j != 88000; j++){
            testTree ->addWithStack(rand(), 0, NULL);
        }
        testTree ->removeAllNodes();
    }
    
}*/

NSComparisonResult comp(uint32_t a,uint32_t b)
{
    if(a < b)
        return NSOrderedAscending;
    if(b < a){
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

/*- (void)testExample
{
    
    
    CGRCircularList<uint32_t> *list = new CGRCircularList<uint32_t>();
    
    
    list ->add(0);
    list ->add(1);
    list ->add(2);
    list ->add(3);
    
    
    
    
    
    
    uint32_t seeds[40000];
    
    srand(32439543);
    
    for(int i=0; i != 40000; i++){
        seeds[i] = (uint32_t)random();
    }
    uint64_t avgElapsedCircTime;
    uint64_t avgElapsedStdTime;
    avgElapsedCircTime = [self testCircularVector:seeds[0]].elapsedTime;
    avgElapsedStdTime = [self testStdVector:seeds[0]].elapsedTime;
    for(int i=1; i != 40000; i++){
        struct testStats circRes = [self testCircularVector:seeds[i]];
        struct testStats stdRes = [self testStdVector:seeds[i]];
        avgElapsedCircTime += circRes.elapsedTime;
        avgElapsedStdTime += stdRes.elapsedTime;
        avgElapsedCircTime /= 2.0;
        avgElapsedStdTime /= 2.0;
    }
    printf("Avg Time for Circular %llu\n", avgElapsedCircTime);
    printf("Avg Time for Std %llu\n", avgElapsedStdTime);

    
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in GB): %f", (double)info.resident_size/pow(2,30));
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    
}*/

-(void)testConstrains
{
    uint64_t startTime, endTime;
    
    
    //printf("Test Start...\n");
    
    startTime = mach_absolute_time();
    
    CGRGeometricGraph *graph = [[CGRGeometricGraph alloc]init];
    ConstrainTest *constrain = [[ConstrainTest alloc]init];
    [graph addNewConstrain:constrain];
    for(uint32_t i=0; i != 10000000; i++){
        [graph addVertex:NSMakePoint(0, 0)];
    }

    endTime = mach_absolute_time();
    
    printf("Total time: %f\n",(endTime - startTime)/1000000000.0);
}
@end
