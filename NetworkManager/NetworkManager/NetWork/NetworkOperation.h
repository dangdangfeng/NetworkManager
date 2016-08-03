
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,NetworkRequestType) {
    NetworkRequestTypeOne = 0,
    NetworkRequestTypeTwo,
};

@interface NetworkOperation : NSOperation

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL errorSelector;
@property (nonatomic, assign) SEL completeSelector;

@property (nonatomic, strong) NSURL *urlOfRequest;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, assign) NetworkRequestType requestType;

- (instancetype)initWithURL:(NSURL *)url requestType:(NetworkRequestType)requestType;

@end
