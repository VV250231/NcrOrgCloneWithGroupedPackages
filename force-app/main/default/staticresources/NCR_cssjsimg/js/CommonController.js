/**
 * The DI application controller manages UI elements, events and themes. 
 * Data is provided by the DataService.
 */
'use strict';
app.controller('DIController',
		['$scope', '$http', '$window', '$compile','config', '$filter', '$timeout',/* 'localize',*/
		 function DIController($scope, $http, $window, $compile, config, $filter, $timeout /*, localize*/) {

	var log = new Logger({name : 'CommonController', level : config.logLevel });

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