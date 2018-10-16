
#import "Reachability.h"
#import "RealReachability.h"

#define kAppleUrlToCheckNetStatus @"http://pv.sohu.com/cityjson?ie=utf-8/"


#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>

NSString * WIFIPath = @"/var/mobile/Library/Preferences/SpringBoardWiFi.plist";

@interface SpringBoard ()<UIAlertViewDelegate>
-(void)wifiAlertView;
@end



%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application
{
%orig;
NSFileManager * fileManager = [NSFileManager defaultManager];
NSError * nsError = nil;
[fileManager removeItemAtPath:WIFIPath error:&nsError];
dispatch_queue_t queue = dispatch_queue_create("yanhooQueue", DISPATCH_QUEUE_SERIAL);

dispatch_async(queue, ^{
while(1){
__block bool isAuth = 0;

[NSThread sleepForTimeInterval:60.0f];
//NSLog(@" ----------Start Hook ------------");


NSString *urlString = kAppleUrlToCheckNetStatus;


[[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
if (data) {
NSFileManager * fileManager = [NSFileManager defaultManager];
NSError * nsError = nil;
[fileManager removeItemAtPath:WIFIPath error:&nsError];
}else {
//NSLog(@"手机所连接的网络?");
dispatch_async(dispatch_get_main_queue(), ^{
NSMutableDictionary * countMessages = [NSMutableDictionary dictionaryWithContentsOfFile:WIFIPath];
if (countMessages == nil)
{
countMessages = [[NSMutableDictionary alloc] init];
}
NSString *fristcount = [countMessages objectForKey:@"count"];
int counts = [fristcount intValue];
if (counts%4)
{
UIAlertView *alert = [[UIAlertView alloc]
initWithTitle:@"网络不稳定！403"
message:nil
delegate:self cancelButtonTitle:@"OK"
otherButtonTitles:nil];
alert.tag = 10086;
[alert show];
}
counts +=1;
//NSLog(@"手机所连接的网络次数 = %d",counts);

NSString *lastcount = [NSString stringWithFormat:@"%d",counts];
[countMessages setObject:lastcount forKey:@"count"];
[countMessages writeToFile:WIFIPath atomically:NO];


});
 }
}]resume];

//NSLog(@"手机所连接的网络?%d",isAuth);


}
});
}


%new(v@:@i)

- (void)alertView:(UIAlertView *)av clickedButtonAtIndex:(NSInteger)buttonIndex
{
if(av.tag ==10086)
{
NSFileManager * fileManager = [NSFileManager defaultManager];
NSError * nsError = nil;
[fileManager removeItemAtPath:WIFIPath error:&nsError];
return;
}

}


/*

%ctor
{


for (int i = 1; i <10 ; i ++) {

[NSThread sleepForTimeInterval:30.0f];

NSLog(@" ----------Start Hook ------------");

NSString *urlString = kAppleUrlToCheckNetStatus;


[[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

NSString* result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];

if (data) {
NSLog(@"手机所连接的网络是可以访问互联网的");

}else {
NSLog(@"手机无法访问互联网");
}
}] resume];

}


}
