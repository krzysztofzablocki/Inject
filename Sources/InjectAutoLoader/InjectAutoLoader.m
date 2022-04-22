//
//  InjectAutoLoader.m
//  
//
//  Created by Wojciech Kulik on 22/04/2022.
//

#import <Foundation/Foundation.h>

@import Inject;

@interface InjectAutoLoader: NSObject
+ (void)load;
@end

@implementation InjectAutoLoader
+ (void)load
{
#ifdef DEBUG
    // Automatically loads Inject when the library is linked.
    [SwiftInjectAutoLoader loadInject];
#endif
}
@end
