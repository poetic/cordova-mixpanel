//
//  CDVMixpanel.h
//
//  Copyright (c) 2014 Poetic Systems. All rights reserved.

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import "Mixpanel.h"

@interface CDVMixpanel: CDVPlugin
{
    NSDictionary *notificationMessage;
    BOOL    isInline;
    NSString *notificationCallbackId;
    
    BOOL ready;
}

@property (nonatomic, copy) NSString *callbackId;
@property (nonatomic, copy) NSString *notificationCallbackId;

@property (nonatomic, strong) NSDictionary *notificationMessage;
@property BOOL                          isInline;

- (void)register:(CDVInvokedUrlCommand*)command;

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

- (void)setNotificationMessage:(NSDictionary *)notification;
- (void)notificationReceived;

-(void)init:(CDVInvokedUrlCommand *)command;
-(void)track:(CDVInvokedUrlCommand *)command;
-(void)identify:(CDVInvokedUrlCommand *)command;
-(void)createAlias:(CDVInvokedUrlCommand *)command;
-(void)peopleSet:(CDVInvokedUrlCommand *)command;
-(void)trackCharge:(CDVInvokedUrlCommand *)command;
-(void)trackChargeWithProperties:(CDVInvokedUrlCommand *)command;
-(void)setShowNotificationOnActive:(CDVInvokedUrlCommand *)command;
-(void)showNotification:(CDVInvokedUrlCommand *)command;
-(void)showNotificationWithID:(CDVInvokedUrlCommand *)command;
-(void)setShowSurveyOnActive:(CDVInvokedUrlCommand *)command;
-(void)showSurvey:(CDVInvokedUrlCommand *)command;
-(void)showSurveyWithID:(CDVInvokedUrlCommand *)command;

@end

