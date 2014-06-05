/**
 * Mixpanel.js
 *
 * Cordova Mixpanel plugin for version >= 3.0.0
 *
 * Copyright(c) Poetic Systems 2014
 */

var exec = require('cordova/exec');

var Mixpanel = function(){};

Mixpanel.init = function(token, s, f){
  return exec(s, f, "Mixpanel", "init", [token]);
};

Mixpanel.track = function(eventName, properties, s, f){
  return exec(s, f, "Mixpanel", "track", [eventName, properties]);
};

Mixpanel.identify = function(distinctId, s, f){
  return exec(s, f, "Mixpanel", "identify", [distinctId]);
};

Mixpanel.createAlias = function(alias, s, f){
  return exec(s, f, "Mixpanel", "createAlias", [alias]);
};

Mixpanel.peopleSet = function(properties, s, f){
  return exec(s, f, "Mixpanel", "peopleSet", [properties]);
};

Mixpanel.trackCharge = function(amount, s, f){
  return exec(s, f, "Mixpanel", "trackCharge", [amount]);
};

Mixpanel.trackChargeWithProperties = function(amount, properties, s, f){
  return exec(s, f, "Mixpanel", "trackCharge", [amount, properties]);
};

Mixpanel.setShowNotificationOnActive = function(bool, s, f){
  return exec(s, f, "Mixpanel", "setShowNotificationOnActive", [bool]);
};

Mixpanel.showNotification = function(s, f){
  return exec(s, f, "Mixpanel", "showNotification", []);
};

Mixpanel.showNotificationWithID = function(id, s, f){
  return exec(s, f, "Mixpanel", "showNotificationWithID", [id]);
};

Mixpanel.setShowSurveyOnActive = function(bool, s, f){
  return exec(s, f, "Mixpanel", "setShowSurveyOnActive", [bool]);
};

Mixpanel.showSurvey = function(s, f){
  return exec(s, f, "Mixpanel", "showSurvey", []);
};

Mixpanel.showSurveyWithID = function(id, s, f){
  return exec(s, f, "Mixpanel", "showSurveyWithID", [id]);
};

module.exports = Mixpanel;
