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
    if([command.arguments objectAtIndex:0])
    {
        distinctId = [command.arguments objectAtIndex:0];
    } else
    {
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
        {
            notificationTypes |= UIRemoteNotificationTypeBadge;
        }
    }
    else if ([badgeArg boolValue])
    {
        notificationTypes |= UIRemoteNotificationTypeBadge;
    }
    
    if ([soundArg isKindOfClass:[NSString class]])
    {
        if ([soundArg isEqualToString:@"true"])
        {
            notificationTypes |= UIRemoteNotificationTypeSound;
        }
    }
    else if ([soundArg boolValue])
    {
        notificationTypes |= UIRemoteNotificationTypeSound;
    }
    
    if ([alertArg isKindOfClass:[NSString class]])
    {
        if ([alertArg isEqualToString:@"true"])
        {
            notificationTypes |= UIRemoteNotificationTypeAlert;
        }
    }
    else if ([alertArg boolValue])
    {
        notificationTypes |= UIRemoteNotificationTypeAlert;
    }

    if (notificationTypes == UIRemoteNotificationTypeNone)
    {
        NSLog(@"PushPlugin.register: Push notification type is set to none");
    }

    isInline = NO;

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];

    // if there is a pending startup notification
    if (notificationMessage)
    {
        [self notificationReceived];  // go ahead and process it
    }
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                        stringByReplacingOccurrencesOfString:@">" withString:@""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people addPushDeviceToken:deviceToken];

    [self successWithMessage:token];
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
  [self failWithMessage:@"" withError:error];
}

- (void)notificationReceived {
    if (notificationMessage)
    {
        NSMutableString *jsonStr = [NSMutableString stringWithString:@"{"];

        [self parseDictionary:notificationMessage intoJSON:jsonStr];

        if (isInline)
        {
            [jsonStr appendFormat:@"foreground:\"%d\"", 1];
            isInline = NO;
        } else
        {
            [jsonStr appendFormat:@"foreground:\"%d\"", 0];
        }
        
        [jsonStr appendString:@"}"];

        NSLog(@"Msg: %@", jsonStr);

        NSString *js = [NSString stringWithFormat:@"cordova.fireDocumentEvent('mixpanel.push', %@);", jsonStr];
        [self.commandDelegate evalJs:js scheduledOnRunLoop:NO];
        
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
        {
            [self parseDictionary:thisObject intoJSON:jsonString];
        }
        else if ([thisObject isKindOfClass:[NSString class]])
        {
             [jsonString appendFormat:@"\"%@\":\"%@\",",
              key,
              [[[[inDictionary objectForKey:key]
                stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"]
                 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""]
                 stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"]];
        }
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

// Private
-(void)successWithCallbackId:(NSString *)theCallbackId;
{
    [self successWithCallbackId:theCallbackId message:@""];
}

-(void)successWithCallbackId:(NSString *)theCallbackId message:(NSString *)message;
{
    self.callbackId = theCallbackId;
    [self successWithMessage:message];
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
