//
//  CDVMixpanel.m
//
//  Copyright (c) 2014 Poetic Systems. All rights reserved.
//

#import "CDVMixpanel.h"
#import <Foundation/NSException.h>

@implementation CDVMixpanel

@synthesize notificationMessage;
@synthesize isInline;

@synthesize callbackId;
@synthesize notificationCallbackId;
@synthesize callback;

-(void)init:(CDVInvokedUrlCommand *)command;
{
    NSString *token = [command.arguments objectAtIndex:0];
    
    [Mixpanel sharedInstanceWithToken:token];
    
    [self successWithCallbackId:command.callbackId];
}

-(void)track:(CDVInvokedUrlCommand *)command;
{
    NSString* eventName = [command.arguments objectAtIndex:0];
    NSDictionary* properties = [command.arguments objectAtIndex:1];
    
    [[Mixpanel sharedInstance] track:eventName properties:properties];
    
    [self successWithCallbackId:command.callbackId];
}

-(void)identify:(CDVInvokedUrlCommand *)command;
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    NSString *distinctId = nil;
    if([command.arguments objectAtIndex:0]) {
        distinctId = [command.arguments objectAtIndex:0];
    } else {
        distinctId = mixpanel.distinctId;
    }
    
    [mixpanel identify:distinctId];
    
    [self successWithCallbackId:command.callbackId];
}

-(void)createAlias:(CDVInvokedUrlCommand *)command;
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    NSString *alias = [command.arguments objectAtIndex:0];
    
    [mixpanel createAlias:alias forDistinctID:mixpanel.distinctId];
    [mixpanel identify:mixpanel.distinctId];
    
    [self successWithCallbackId:command.callbackId];
}

-(void)peopleSet:(CDVInvokedUrlCommand *)command;
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    NSDictionary *properties = [command.arguments objectAtIndex:0];
    
    [mixpanel identify:mixpanel.distinctId];
    [mixpanel.people set:properties];
    
    [self successWithCallbackId:command.callbackId];
}

-(void)trackCharge:(CDVInvokedUrlCommand *)command;
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    NSNumber *amount = [command.arguments objectAtIndex:0];
    
    [mixpanel identify:mixpanel.distinctId];
    [mixpanel.people trackCharge:amount];
    
    [self successWithCallbackId:command.callbackId];
}

-(void)trackChargeWithProperties:(CDVInvokedUrlCommand *)command;
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    NSNumber *amount = [command.arguments objectAtIndex:0];
    NSDictionary *properties = [command.arguments objectAtIndex:1];
    
    [mixpanel identify:mixpanel.distinctId];
    [mixpanel.people trackCharge:amount withProperties:properties];
    
    [self successWithCallbackId:command.callbackId];
}

-(void)setShowNotificationOnActive:(CDVInvokedUrlCommand *)command;
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    BOOL showNotificationOnActive = [[command.arguments objectAtIndex:0] boolValue];
    
    mixpanel.showNotificationOnActive = showNotificationOnActive;
    
    [self successWithCallbackId:command.callbackId];
}

-(void)showNotification:(CDVInvokedUrlCommand *)command;
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel showNotification];
    
    [self successWithCallbackId:command.callbackId];
}

-(void)showNotificationWithID:(CDVInvokedUrlCommand *)command;
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSUInteger ID = (NSUInteger)[command.arguments objectAtIndex:0];
    
    [mixpanel showNotificationWithID:ID];
    
    [self successWithCallbackId:command.callbackId];
}

-(void)setShowSurveyOnActive:(CDVInvokedUrlCommand *)command;
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    BOOL showSurveyOnActive = [[command.arguments objectAtIndex:0] boolValue];
    
    mixpanel.showNotificationOnActive = showSurveyOnActive;
    
    [self successWithCallbackId:command.callbackId];
}

-(void)showSurvey:(CDVInvokedUrlCommand *)command;
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel showSurvey];
    
    [self successWithCallbackId:command.callbackId];
}

-(void)showSurveyWithID:(CDVInvokedUrlCommand *)command;
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSUInteger ID = (NSUInteger)[command.arguments objectAtIndex:0];
    
    [mixpanel showSurveyWithID:ID];
    
    [self successWithCallbackId:command.callbackId];
}

// Private
-(void)successWithCallbackId:(NSString *)callbackId;
{
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
}


- (void)unregister:(CDVInvokedUrlCommand*)command;
{
  self.callbackId = command.callbackId;

    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    [self successWithMessage:@"unregistered"];
}

- (void)register:(CDVInvokedUrlCommand*)command;
{
    self.callbackId = command.callbackId;

    NSMutableDictionary* options = [command.arguments objectAtIndex:0];

    UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeNone;
    id badgeArg = [options objectForKey:@"badge"];
    id soundArg = [options objectForKey:@"sound"];
    id alertArg = [options objectForKey:@"alert"];
    
    if ([badgeArg isKindOfClass:[NSString class]])
    {
        if ([badgeArg isEqualToString:@"true"])
            notificationTypes |= UIRemoteNotificationTypeBadge;
    }
    else if ([badgeArg boolValue])
        notificationTypes |= UIRemoteNotificationTypeBadge;
    
    if ([soundArg isKindOfClass:[NSString class]])
    {
        if ([soundArg isEqualToString:@"true"])
            notificationTypes |= UIRemoteNotificationTypeSound;
    }
    else if ([soundArg boolValue])
        notificationTypes |= UIRemoteNotificationTypeSound;
    
    if ([alertArg isKindOfClass:[NSString class]])
    {
        if ([alertArg isEqualToString:@"true"])
            notificationTypes |= UIRemoteNotificationTypeAlert;
    }
    else if ([alertArg boolValue])
        notificationTypes |= UIRemoteNotificationTypeAlert;
    
    self.callback = [options objectForKey:@"ecb"];

    if (notificationTypes == UIRemoteNotificationTypeNone)
        NSLog(@"PushPlugin.register: Push notification type is set to none");

    isInline = NO;

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];

  if (notificationMessage)      // if there is a pending startup notification
    [self notificationReceived];  // go ahead and process it
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    [results setValue:token forKey:@"deviceToken"];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people addPushDeviceToken:deviceToken];
    
    #if !TARGET_IPHONE_SIMULATOR
        // Get Bundle Info for Remote Registration (handy if you have more than one app)
        [results setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] forKey:@"appName"];
        [results setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"appVersion"];
        
        // Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
        NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];

        // Set the defaults to disabled unless we find otherwise...
        NSString *pushBadge = @"disabled";
        NSString *pushAlert = @"disabled";
        NSString *pushSound = @"disabled";

        // Check what Registered Types are turned on. This is a bit tricky since if two are enabled, and one is off, it will return a number 2... not telling you which
        // one is actually disabled. So we are literally checking to see if rnTypes matches what is turned on, instead of by number. The "tricky" part is that the
        // single notification types will only match if they are the ONLY one enabled.  Likewise, when we are checking for a pair of notifications, it will only be
        // true if those two notifications are on.  This is why the code is written this way
        if(rntypes & UIRemoteNotificationTypeBadge){
            pushBadge = @"enabled";
        }
        if(rntypes & UIRemoteNotificationTypeAlert) {
            pushAlert = @"enabled";
        }
        if(rntypes & UIRemoteNotificationTypeSound) {
            pushSound = @"enabled";
        }

        [results setValue:pushBadge forKey:@"pushBadge"];
        [results setValue:pushAlert forKey:@"pushAlert"];
        [results setValue:pushSound forKey:@"pushSound"];

        // Get the users Device Model, Display Name, Token & Version Number
        UIDevice *dev = [UIDevice currentDevice];
        [results setValue:dev.name forKey:@"deviceName"];
        [results setValue:dev.model forKey:@"deviceModel"];
        [results setValue:dev.systemVersion forKey:@"deviceSystemVersion"];

    [self successWithMessage:[NSString stringWithFormat:@"%@", token]];
    #endif
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
  [self failWithMessage:@"" withError:error];
}

- (void)notificationReceived {
    if (notificationMessage && self.callback)
    {
        NSMutableString *jsonStr = [NSMutableString stringWithString:@"{"];

        [self parseDictionary:notificationMessage intoJSON:jsonStr];

        if (isInline)
        {
            [jsonStr appendFormat:@"foreground:\"%d\"", 1];
            isInline = NO;
        }
    else
            [jsonStr appendFormat:@"foreground:\"%d\"", 0];
        
        [jsonStr appendString:@"}"];

        NSLog(@"Msg: %@", jsonStr);

        NSString * jsCallBack = [NSString stringWithFormat:@"%@(%@);", self.callback, jsonStr];
        [self.webView stringByEvaluatingJavaScriptFromString:jsCallBack];
        
        self.notificationMessage = nil;
    }
}

// reentrant method to drill down and surface all sub-dictionaries' key/value pairs into the top level json
-(void)parseDictionary:(NSDictionary *)inDictionary intoJSON:(NSMutableString *)jsonString
{
    NSArray         *keys = [inDictionary allKeys];
    NSString        *key;
    
    for (key in keys)
    {
        id thisObject = [inDictionary objectForKey:key];
    
        if ([thisObject isKindOfClass:[NSDictionary class]])
            [self parseDictionary:thisObject intoJSON:jsonString];
        else if ([thisObject isKindOfClass:[NSString class]])
             [jsonString appendFormat:@"\"%@\":\"%@\",",
              key,
              [[[[inDictionary objectForKey:key]
                stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
                 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]
                 stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]];
        else {
            [jsonString appendFormat:@"\"%@\":\"%@\",", key, [inDictionary objectForKey:key]];
        }
    }
}

- (void)setApplicationIconBadgeNumber:(CDVInvokedUrlCommand *)command {

    self.callbackId = command.callbackId;

    NSMutableDictionary* options = [command.arguments objectAtIndex:0];
    int badge = [[options objectForKey:@"badge"] intValue] ?: 0;

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badge];

    [self successWithMessage:[NSString stringWithFormat:@"app badge count set to %d", badge]];
}
-(void)successWithMessage:(NSString *)message
{
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    
    [self.commandDelegate sendPluginResult:commandResult callbackId:self.callbackId];
}

-(void)failWithMessage:(NSString *)message withError:(NSError *)error
{
    NSString        *errorMessage = (error) ? [NSString stringWithFormat:@"%@ - %@", message, [error localizedDescription]] : message;
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorMessage];
    
    [self.commandDelegate sendPluginResult:commandResult callbackId:self.callbackId];
}

@end
