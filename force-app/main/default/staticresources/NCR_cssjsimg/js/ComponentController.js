/**
 * The DI application controller manages UI elements, events and themes. 
 * Data is provided by the DataService.
 */
'use strict';
app.controller('DIController',
		['$scope', '$http', '$window', '$compile','config', '$filter', '$timeout',/* 'localize',*/
		 function DIController($scope, $http, $window, $compile, config, $filter, $timeout /*, localize*/) {

	var log = new Logger({name : 'ComponentController', level : config.logLevel });

	/** Reference to Controller (self/this) */
	var self = $scope;
	
	// Extending this controller functionality with Base functionality.
	//AppBaseController(self, $http, $window, $compile, config, localize, null, $filter, $timeout);

	/** Application Configuration Data holder */
	self.config = new AppConfig(config, 'en', $window.navigator );

	/** Reference to HTTP service */
	self.webService = new WebService(self, $http);

	// Controller Level Flag true, when All level of controller get initialized.
	self.readyFlag = false;

	self.templateTypes = [{id:1, name:'Use a template'},{id:2, name:'Make an ad hoc payment'}];
	self.templateTypes2 = [{id:1, name:'Next 1 Month'},{id:2, name:'Next 2 Months'},{id:3, name:'Next 3 Months'}];
	self.templateTypes3 = [{id:1, name:'(652)-999-8888'},{id:2, name:'(589)-789-0158'},{id:3, name:'(256)-888-0025'}];
	
	self.testHtml = "<div class='di-test'><ul><li>Lorem ipsum dolor sit ame</li><li>Lorem ipsum dolor sit ame</li><li>Lorem ipsum dolor sit ame</li><li>Lorem ipsum dolor sit ame</li></ul></div>";
	self.testHtml2 = "<div class='di-test'><h3>Why didI get this page?</h3><span>Common reasons include:</span><ul<li>You recently cleared your cookies <a href='#'>Learn more</a></li><li>You are browsing in private ir incognito mode</li><li>You are using a different browser from the one you set last time</li><li>You knowingly or unknowningly asked to skip this extra security step</li></ul></div>";



	/**
	* Initializes the layout when page is ready.
	*/
	$(function() {

		log.info('Loading {} {} - please wait ...', self.config.appName, self.config.appRelease);
	 //document.domain = self.config.documentDomain;

	 self.config.update({
		 //reportsBaseUrl:diReportsBaseUrl,
		 appEnv:'POC',
		 appSysVersion:'0.1'
	 });
	 //self.webService.addDefaultParams('userId', '123');
	 //self.webService.setAuthUrl(diAuthBaseUrl);
	 //self.webService.addDefaultHeader('UserName', self.user.domainId);

	 log.info('Ready');

	 self.readyFlag = true;
	});

}]);