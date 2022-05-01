#ifdef DEBUG
#import <Foundation/Foundation.h>

@import Inject;

@interface InjectAutoLoader: NSObject
+ (void)load;
@end

@implementation InjectAutoLoader
+ (void)load
{
    // Automatically loads Inject when the library is linked.
    [SwiftInjectAutoLoader loadInject];
}
@end

#endif
