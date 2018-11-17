//
//  ViewController.m
//  L2TP
//
//  Created by liaogang on 2018/7/6.
//  Copyright © 2018年 liaogang. All rights reserved.
//

#import "ViewController.h"

#import "NetworkExtesionPrivate.h"
#import "KeyChainManager.h"

@import ObjectiveC.runtime;


NSData *persistentReferenceForSavedPassword(NSString *password, NSString *service, NSString *account);

@interface ViewController ()
@property (nonatomic,strong) NEVPNManager *vpnMgr;
@end




@implementation NEVPNManager(my)

-(BOOL)isProtocolTypeValid2:(long long)arg1
{
    return YES;
}

@end


@implementation NEVPNConnection (my)

-(int)statusEx
{
    return NEVPNStatusDisconnected;
}

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.vpnMgr = [NEVPNManager sharedManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VPNStatusDidChangeNotification:) name:NEVPNStatusDidChangeNotification object:nil];
    
    
    
    //If we want use L2TP , we must do some little trick
    
    
    {
        //when NEVPNManager saveToPreferencesWithCompletionHandler, is will check the protocol type,so
        Method ori_Method = class_getInstanceMethod([NEVPNManager class], @selector(isProtocolTypeValid:));
        
        Method my_Method = class_getInstanceMethod([NEVPNManager class], @selector(isProtocolTypeValid2:));
        
        method_exchangeImplementations(ori_Method, my_Method);
    }
    
    
    {
        //the metohd [NEVPNConnection startVPNTunnelAndReturnError] will check the status,so
        
        Method ori_Method = class_getInstanceMethod([NEVPNConnection class], @selector(status));
        
        Method my_Method = class_getInstanceMethod([NEVPNConnection class], @selector(statusEx));
        
        method_exchangeImplementations(ori_Method, my_Method);
    }
    

    
}



- (IBAction)actionCreate:(id)sender {
    
    
    [_vpnMgr loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
       
        if(error)
        {
            NSLog(@"loadFromPreferencesWithCompletionHandler error: %@", error);
        }
        else
        {
            NSLog(@"loadFromPreferencesWithCompletionHandler ok");
            
            [self setupVPNManager];
            
            
            [_vpnMgr saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                
                if (error) {
                    NSLog(@"saveToPreferencesWithCompletionHandler error: %@", error);
                }
                else{
                    NSLog(@"saveToPreferencesWithCompletionHandler ok");
                    
                }
                
            }];
            
        }
        
    }];
    
    
}

- (IBAction)actionRemove:(id)sender {
    
    [_vpnMgr loadFromPreferencesWithCompletionHandler:^(NSError *error){
        if (!error)
        {
            [_vpnMgr removeFromPreferencesWithCompletionHandler:^(NSError *error){
                if(error)
                {
                    NSLog(@"Remove error: %@", error);
                }
                else
                {
                    NSLog(@"removeFromPreferencesWithCompletionHandler ok");
                }
            }];
        }
    }];
    
}

- (IBAction)actionConnect:(id)sender {
    
    [_vpnMgr loadFromPreferencesWithCompletionHandler:^(NSError *error){
        if (!error)
        {
            [self setupIPSec];
            
            NSError *error;
            if([_vpnMgr.connection startVPNTunnelAndReturnError: &error ])
            {
                NSLog(@"startVPNTunnelAndReturnError success ");
            }
            else{
                NSLog(@"startVPNTunnelAndReturnError failed: %@",error);
            }
            
            
        }
    }];
    
}


- (IBAction)actionDisconnect:(id)sender {
    
    [_vpnMgr loadFromPreferencesWithCompletionHandler:^(NSError *error){
        if (!error)
        {
            [_vpnMgr.connection stopVPNTunnel];
        }
    }];
    
}


#pragma mark -

-(void)setupVPNManager{
    [self setupL2TP];
//    [self setupIPSec];

}

- (void)setupIPSec
{
    NEVPNProtocolIPSec *p = [[NEVPNProtocolIPSec alloc] init];
    p.serverAddress = kServerAddress;
    p.username = kVPNName;
    p.passwordReference = persistentReferenceForSavedPassword(kPasswordReference, @"com.abuyun.pvpn", @"liaogang");
    p.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;
    p.sharedSecretReference = persistentReferenceForSavedPassword(kSharedSecretReference, @"com.abuyun.pvpn", @"liaogang");
    p.disconnectOnSleep = NO;
    
    //需要扩展鉴定(群组)
    p.localIdentifier = kLocalIdentifier;
    p.remoteIdentifier = kRemoteIdentifier;
    p.useExtendedAuthentication = YES;
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        [_vpnMgr setProtocol:p];
    } else {
        [_vpnMgr setProtocolConfiguration:p];
    }
    
    
    [_vpnMgr setOnDemandEnabled:NO];
    [_vpnMgr setLocalizedDescription:@"VPN-NAME"];//VPN自定义名字
    [_vpnMgr setEnabled:YES];
}

- (void)setupL2TP
{
    NEVPNProtocolL2TP *p = [[NEVPNProtocolL2TP alloc] init];
    p.serverAddress =@"stomus01.3322.org";
    p.username = @"stomus01";
    [self createKeychainValue:@"tt11223" forIdentifier:@"VPN_PASSWORD"];
    p.passwordReference = [self searchKeychainCopyMatching:@"VPN_PASSWORD"];
    p.authenticationMethod = NEVPNIKEAuthenticationMethodCertificate;
    [self createKeychainValue:@"123" forIdentifier:@"VPN_shared_PASSWORD"];
    p.sharedSecretReference = [self searchKeychainCopyMatching:@"VPN_shared_PASSWORD"];
    p.disconnectOnSleep = NO;
    p.localIdentifier = kLocalIdentifier;
    
    
   
    
    
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
        [_vpnMgr setProtocol:p];
    } else {
        [_vpnMgr setProtocolConfiguration:p];
    }
    
    [_vpnMgr setOnDemandEnabled:NO];
    [_vpnMgr setLocalizedDescription:@"VPN_s"];//VPN自定义名字
    [_vpnMgr setEnabled:YES];
}



#pragma mark - keychain 相关

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [searchDictionary setObject:@YES forKey:(__bridge id)kSecReturnPersistentRef];
    CFTypeRef result = NULL;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &result);
    return (__bridge_transfer NSData *)result;
}

- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    // creat a new item
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    //OSStatus 就是一个返回状态的code 不同的类返回的结果不同
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)dictionary);
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(__bridge id)kSecValueData];
    status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

static NSString * const serviceName = @"serviceName";

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
    //   keychain item creat
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    //   extern CFTypeRef kSecClassGenericPassword  一般密码
    //   extern CFTypeRef kSecClassInternetPassword 网络密码
    //   extern CFTypeRef kSecClassCertificate 证书
    //   extern CFTypeRef kSecClassKey 秘钥
    //   extern CFTypeRef kSecClassIdentity 带秘钥的证书
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    //ksecClass 主键
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];
    return searchDictionary;
}

#pragma mark - Did Change

//since the L2TP is not support by NetworkExtesion,the connection status will always be Invalide.
- (void)VPNStatusDidChangeNotification:(NSNotification*)o
{
    NEVPNConnection *c = o.object;
    
    
    switch ( [c statusEx] )
    {
        case NEVPNStatusInvalid:
        {
            NSLog(@"NEVPNStatusInvalid");
            break;
        }
        case NEVPNStatusDisconnected:
        {
            NSLog(@"NEVPNStatusDisconnected");
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            break;
        }
        case NEVPNStatusConnecting:
        {
            NSLog(@"NEVPNStatusConnecting");
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            break;
        }
        case NEVPNStatusConnected:
        {
            NSLog(@"NEVPNStatusConnected");
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            break;
        }
        case NEVPNStatusReasserting:
        {
            NSLog(@"NEVPNStatusReasserting");
            break;
        }
        case NEVPNStatusDisconnecting:
        {
            NSLog(@"NEVPNStatusDisconnecting");
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            break;
        }
        default:
            break;
    }
}

@end



//If you can not save the password, make sure you have the Keychain sharing entitlements
NSData *persistentReferenceForSavedPassword(NSString *password, NSString *service, NSString *account)
{
    NSData *        result;
    NSData *        passwordData;
    OSStatus        err;
    CFTypeRef      secResult;
    
    
    result = nil;
    
    passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    
    err = SecItemCopyMatching( (__bridge CFDictionaryRef) @{
                                                            (__bridge id) kSecClass:                (__bridge id) kSecClassGenericPassword,
                                                            (__bridge id) kSecAttrService:          service,
                                                            (__bridge id) kSecAttrAccount:          account,
                                                            (__bridge id) kSecReturnPersistentRef:  @YES,
                                                            (__bridge id) kSecReturnData:          @YES
                                                            }, &secResult);
    if (err == errSecSuccess) {
        NSDictionary *  resultDict;
        NSData *        currentPasswordData;
        
        resultDict = CFBridgingRelease( secResult );
        assert([resultDict isKindOfClass:[NSDictionary class]]);
        
        result = resultDict[ (__bridge NSString *) kSecValuePersistentRef ];
        assert([result isKindOfClass:[NSData class]]);
        
        currentPasswordData = resultDict[ (__bridge NSString *) kSecValueData ];
        assert([currentPasswordData isKindOfClass:[NSData class]]);
        
        if ( ! [passwordData isEqual:currentPasswordData] ) {
            err = SecItemUpdate( (__bridge CFDictionaryRef) @{
                                                              (__bridge id) kSecClass:        (__bridge id) kSecClassGenericPassword,
                                                              (__bridge id) kSecAttrService:  service,
                                                              (__bridge id) kSecAttrAccount:  account,
                                                              }, (__bridge CFDictionaryRef) @{
                                                                                              (__bridge id) kSecValueData:    passwordData
                                                                                              } );
            if (err != errSecSuccess) {
                NSLog(@"Error %d saving password (SecItemUpdate)", (int) err);
                result = nil;
            }
        }
    } else if (err == errSecItemNotFound) {
        err = SecItemAdd( (__bridge CFDictionaryRef) @{
                                                       (__bridge id) kSecClass:                (__bridge id) kSecClassGenericPassword,
                                                       (__bridge id) kSecAttrService:          service,
                                                       (__bridge id) kSecAttrAccount:          account,
                                                       (__bridge id) kSecValueData:            passwordData,
                                                       (__bridge id) kSecReturnPersistentRef:  @YES
                                                       }, &secResult);
        if (err == errSecSuccess) {
            result = CFBridgingRelease( secResult );
            assert([result isKindOfClass:[NSData class]]);
        } else {
            NSLog(@"Error %d saving password (SecItemAdd)", (int) err);
        }
    } else {
        NSLog(@"Error %d saving password (SecItemCopyMatching)", (int) err);
    }
    return result;
}

