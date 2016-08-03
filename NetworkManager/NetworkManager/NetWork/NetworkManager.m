
#import "NetworkManager.h"
#import "NetworkOperation.h"

static NetworkManager *_networkManager;

@implementation NetworkManager

+ (NetworkManager *)sharedNetworkManager{
    if (_networkManager == nil) {
        static dispatch_once_t once;
        dispatch_once(&once,^{
            _networkManager = [[NetworkManager alloc] init];
        });
    }
    return _networkManager;
}

- (instancetype)init{
    if (self = [super init]) {
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)requestWithTarget:(id)target completeHandler:(SEL)completeSelector errorHandler:(SEL)errorSelector{
    NetworkOperation *operation = [[NetworkOperation alloc] initWithURL:[NSURL URLWithString:@"http://comment.api.163.com/api/json/post/list/new/hot/ent2_bbs/PHOTHQMD000300AJ/0/10/10/2/2"] requestType:NetworkRequestTypeOne];
    operation.target = target;
    operation.completeSelector = completeSelector;
    operation.errorSelector = errorSelector;
    
    [_operationQueue addOperation:operation];
}

@end
