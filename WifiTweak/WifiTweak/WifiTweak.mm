#line 1 "/Users/superchao/JaiBreak/WifiTweak/WifiTweak/WifiTweak.xm"

#import "Reachability.h"
#import "RealReachability.h"

#define kAppleUrlToCheckNetStatus @"http://pv.sohu.com/cityjson?ie=utf-8/"


#import <UIKit/UIKit.h>
#import <SpringBoard/SpringBoard.h>

NSString * WIFIPath = @"/var/mobile/Library/Preferences/SpringBoardWiFi.plist";

@interface SpringBoard ()<UIAlertViewDelegate>
-(void)wifiAlertView;
@end




#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SpringBoard; 
static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SpringBoard$alertView$clickedButtonAtIndex$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, UIAlertView *, NSInteger); 

#line 19 "/Users/superchao/JaiBreak/WifiTweak/WifiTweak/WifiTweak.xm"


static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id application) {
_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);
NSFileManager * fileManager = [NSFileManager defaultManager];
NSError * nsError = nil;
[fileManager removeItemAtPath:WIFIPath error:&nsError];
dispatch_queue_t queue = dispatch_queue_create("yanhooQueue", DISPATCH_QUEUE_SERIAL);

dispatch_async(queue, ^{
while(1){
__block bool isAuth = 0;

[NSThread sleepForTimeInterval:60.0f];



NSString *urlString = kAppleUrlToCheckNetStatus;


[[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlString] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
if (data) {
NSFileManager * fileManager = [NSFileManager defaultManager];
NSError * nsError = nil;
[fileManager removeItemAtPath:WIFIPath error:&nsError];
}else {

dispatch_async(dispatch_get_main_queue(), ^{
NSMutableDictionary * countMessages = [NSMutableDictionary dictionaryWithContentsOfFile:WIFIPath];
if (countMessages == nil)
{
countMessages = [[NSMutableDictionary alloc] init];
}
NSString *fristcount = [countMessages objectForKey:@"count"];
int counts = [fristcount intValue];
if (counts == 4 )
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


NSString *lastcount = [NSString stringWithFormat:@"%d",counts];
[countMessages setObject:lastcount forKey:@"count"];
[countMessages writeToFile:WIFIPath atomically:NO];


});
 }
}]resume];




}
});
}





static void _logos_method$_ungrouped$SpringBoard$alertView$clickedButtonAtIndex$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIAlertView * av, NSInteger buttonIndex) {
if(av.tag ==10086)
{
NSFileManager * fileManager = [NSFileManager defaultManager];
NSError * nsError = nil;
[fileManager removeItemAtPath:WIFIPath error:&nsError];
return;
}

}

































static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);{ const char *_typeEncoding = "v@:@i"; class_addMethod(_logos_class$_ungrouped$SpringBoard, @selector(alertView:clickedButtonAtIndex:), (IMP)&_logos_method$_ungrouped$SpringBoard$alertView$clickedButtonAtIndex$, _typeEncoding); }} }
#line 130 "/Users/superchao/JaiBreak/WifiTweak/WifiTweak/WifiTweak.xm"
