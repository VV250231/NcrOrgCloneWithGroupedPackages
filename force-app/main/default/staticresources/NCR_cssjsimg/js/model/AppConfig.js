/**
 * Application configuration model.
 * Uses input parameters if specified or DI defaults.
 */
'use strict';
function AppConfig(params, userLang, navigator, siteCode) {
	
    var self = this;
    
    params = (params) ? params : {};
    
    self.navigator = null;
    self.appName = (params.appName) ? params.appName : 'DI';
    self.appDescription = (params.appDescription) ? params.appDescription : 'DI-APP';
    self.appRelease = (params.appRelease) ? params.appRelease : '1.0';
    self.companyCode = (params.companyCode) ? params.companyCode : 'NCR-DI';
    self.currencySymbol = (params.currencySymbol) ? params.currencySymbol : '$';
    self.lang = (userLang && userLang !== "null") ? userLang : 'en';
    self.siteCode = (siteCode) ? siteCode : '';
    self.documentDomain = (params.documentDomain) ? params.documentDomain : 'digitalinsight.com';
    self.logLevel = (params.logLevel) ? params.logLevel : Logger.INFO;  /* Application logging level. */
    self.dateConfig = { 'show-weeks': false, 'format-day': 'dd', 'format-month': 'MMM', 'format-year': 'yyyy' };
    self.dateFormat = 'MMM dd, yyyy';
    self.dateTimeFormat = 'd-MMM-yyyy, hh:mm:ss a';
	self.reportsBaseUrl = (params.reportsBaseUrl) ? params.reportsBaseUrl : 'http://unknown.host';
	self.appSysVersion = (params.appSysVersion) ? params.appSysVersion : -1;
	self.appEnv = (params.appEnv) ? params.appEnv : -1;
	
    // Validate Client Browser Type
    var browsers = {chrome: /chrome/i, safari: /safari/i, firefox: /firefox/i, ie: /internet explorer/i, ie8: /MSIE 8/};
    
    for(var key in browsers) {
    	if (browsers[key].test(navigator.userAgent)) {
    		self.navigator =  key;
    		break;
    	}
    };
    
    if(self.navigator === null )
    	self.navigator = 'unknown';
    
    self.isIE = (self.navigator === 'ie' || self.navigator === 'ie8');
    self.isFF = (self.navigator === 'firefox');
    self.isChrome = (self.navigator === 'chrome');
    self.isSafari = (self.navigator === 'safari');
   
    /**
     * Updates selective configuration parameters after the initial configuration has been set.
     * Can be used to make live changes to active configuration settings.
     * 
     * @params - parameters to override current values.
     */
    self.update = function(params) {
        self.appName = (params.appName) ? params.appName : self.appName;
        self.appDescription = (params.appDescription) ? params.appDescription : self.appDescription;
        self.appRelease = (params.appRelease) ? params.appRelease : self.appRelease;
        self.logLevel = (params.logLevel) ? params.logLevel : self.logLevel;
        //self.lang = (params.lang) ? params.lang : self.lang;
        self.reportsBaseUrl = (params.reportsBaseUrl) ? params.reportsBaseUrl : self.reportsBaseUrl;
    	self.appSysVersion = AppUtils.isNumber(params.appSysVersion) ? params.appSysVersion : self.appSysVersion;
    	self.appEnv = (params.appEnv) ? params.appEnv : self.appEnv;

    };

};
