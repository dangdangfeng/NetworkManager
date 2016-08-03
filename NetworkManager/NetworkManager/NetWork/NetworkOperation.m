
#import "NetworkOperation.h"

const CGFloat kNetworkTimeoutTimeInSeconds = 39.0f;
NSString *const kJsonKeyOne = @"One";

@interface NetworkOperation ()<NSURLConnectionDataDelegate>
{
    NSURLConnection *_urlConnection;
    NSURLSession *_urlSession;
}

@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, assign) BOOL wasSuccessful;

@end

@implementation NetworkOperation

/// 初始化
- (instancetype)initWithURL:(NSURL *)url requestType:(NetworkRequestType)requestType{
    if (self = [super init]) {
        _urlOfRequest = url;
        _requestType = requestType;
    }
    return self;
}

#pragma mark - NSOperation
- (void)start{
    if (self.isCancelled) return;
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    self.isExecuting = YES;
    
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = 9,.minorVersion = 0,.patchVersion = 0}]) {
        NSLog(@"> iOS 9.0");
        [self startUrlSession];
        
    }else{
        [self startUrlConnection];
    }
    
    
    [self startCheckingTimeout];
}

- (void)cancel{
    [_urlConnection cancel];
    self.responseData = nil;
    
    [self done];
    [super cancel];
}

#pragma mark - Privite SEL

- (void)startCheckingTimeout{
    [self performSelector:@selector(handleRequestTimeout) withObject:nil afterDelay:kNetworkTimeoutTimeInSeconds];
}

- (void)handleRequestTimeout{
    if (self.isFinished) return;
    if (self.target && self.errorSelector) [self.target performSelectorOnMainThread:self.errorSelector withObject:nil waitUntilDone:YES];
    
    [self cancel];
}

- (void)done{
    _urlConnection = nil;
    self.isExecuting = NO;
    self.isFinished = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleRequestTimeout) object:nil];
}

- (void)startUrlConnection{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.urlOfRequest cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kNetworkTimeoutTimeInSeconds];
    
    self.responseData = [NSMutableData data];
    
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [_urlConnection start];
}

- (void)startUrlSession{
    _urlSession = [NSURLSession sharedSession];
    NSURLSessionTask *task = [_urlSession dataTaskWithURL:self.urlOfRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
             if (self.target && self.errorSelector) {
                 [self.target performSelectorOnMainThread:self.errorSelector withObject:error waitUntilDone:YES];
                 [self done];
                 return;
             }
        }
        if (data) {
             NSError *jsonError = nil;
            self.responseData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
            if (jsonError) {
                if (self.target && self.errorSelector) {
                    [self.target performSelectorOnMainThread:self.errorSelector withObject:jsonError waitUntilDone:YES];
                }
                [self done];
            }else{
                if (self.target && self.completeSelector) {
                    [self.target performSelectorOnMainThread:self.completeSelector withObject:self.responseData waitUntilDone:YES];
                }
            }
        }
    }];
    
    [task resume];
}

- (void)handleJsonResult:(NSDictionary *)jsonResult{
    if (self.requestType == NetworkRequestTypeOne) {
        [self parseJsonOne:jsonResult];
    }else{
        [self parseJsonTwo:jsonResult];
    }
}

- (void)parseJsonOne:(id)jsonResult{
    //转对象(示例未转，直接送出)
    if (self.target && self.completeSelector) {
        [self.target performSelectorOnMainThread:self.completeSelector withObject:jsonResult waitUntilDone:YES];
    }
}

- (void)parseJsonTwo:(id)jsonResult{
    //转对象
    if (self.target && self.completeSelector) {
        [self.target performSelectorOnMainThread:self.completeSelector withObject:jsonResult waitUntilDone:YES];
    }
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    self.responseData = nil;
    
    self.wasSuccessful = NO;
    [self done];
    
    if (self.target && self.errorSelector) {
        [self.target performSelectorOnMainThread:self.errorSelector withObject:nil waitUntilDone:YES];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    self.wasSuccessful = YES;
    
    NSError *jsonError = nil;
    NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableLeaves error:&jsonError];
    
    if (jsonError) {
        if (self.target && self.errorSelector) {
            [self.target performSelectorOnMainThread:self.errorSelector withObject:jsonError waitUntilDone:YES];
        }
        [self done];
        return;
    }
    
//    NSLog(@"JSON Result:%@",jsonResult);
    
    [self handleJsonResult:jsonResult];
}

#pragma mark - KVO

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key{
    if ([key isEqualToString:@"isFinished"] || [key isEqualToString:@"isExecuting"]) return YES;
    else return [super automaticallyNotifiesObserversForKey:key];
}


@end
