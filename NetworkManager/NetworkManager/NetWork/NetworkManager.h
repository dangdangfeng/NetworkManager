
#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

@property (nonatomic, strong) NSOperationQueue *operationQueue;

+(NetworkManager *)sharedNetworkManager;

- (void)requestWithTarget:(id)target completeHandler:(SEL)completeSelector errorHandler:(SEL)errorSelector;

@end
