//
//  CDVMixpanel.m
//
//  Copyright (c) 2014 Poetic Systems. All rights reserved.
//

#import "CDVMixpanel.h"
#import <Foundation/NSException.h>

@implementation CDVMixpanel

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

@end
