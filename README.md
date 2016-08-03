# NetworkManager
Do something with the NetworkManager (use NSOperation)

Use:
[[NetworkManager sharedNetworkManager] requestWithTarget:self completeHandler:@selector(requestFinished:) errorHandler:@selector(requestError)];

Done:
- (void)requestFinished:(id)sender{
    NSLog(@"%@",sender);
}

- (void)requestError:(id)sender{
    NSLog(@"%@",sender);
}

How Do It?

use NSOperation ; NSOperationQueue ; NSURLConnection ; NSURLSession
