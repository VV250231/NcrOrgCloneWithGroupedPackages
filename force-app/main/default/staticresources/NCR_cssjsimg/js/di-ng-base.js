/**
 * NCR-DI Angular module.
 *
 * Strict mode makes several changes to normal JavaScript semantics. First, strict mode eliminates
 * some JavaScript silent errors by changing them to throw errors. Second, strict mode fixes
 * mistakes that make it difficult for JavaScript engines to perform optimizations: strict mode code
 * can sometimes be made to run faster than identical code that's not strict mode. Third, strict
 * mode prohibits some syntax likely to be defined in future versions of ECMAScript.
 *
 * @return a configuration object.
 */
'use strict';

/** Global Constants */

var _NA = "N/A";
var _UNDEFINED = undefined;
var _NULL = null;
var _SUCCESS = 'SUCCESS';
var _WARNING = 'WARNING';
var _FAILED = 'FAILED';
var _ERROR = 'ERROR';
var _INFO = 'INFO';

var app = angular.module(
    'ncr-di', ['ui.bootstrap'/*'localization', 'ngSanitize'*/]
)
    .factory("config", function() {
        return {
            logLevel : Logger.DEBUG
        };

    });


app.directive('focusOn', function($timeout) {
    return {
        scope: { trigger: '=focusOn' },
        link: function(scope, element) {
            scope.$watch('trigger', function(value) {
                if(value === true) {
                    element[0].focus();
                    //scope.trigger = false;
                }
            });
        }
    };
});

app.directive('formatNumber', function ($filter) {
    return {
        require: '?ngModel',
        link: function (scope, elem, attrs, ctrl) {
            if (!ctrl) {
                return;
            }

            ctrl.$formatters.unshift(function () {
                return $filter('number')(ctrl.$modelValue);
            });

            ctrl.$parsers.unshift(function (viewValue) {
                var plainNumber = viewValue.replace(/[\,\.]/g, ''),
                    b = $filter('number')(plainNumber);

                elem.val(b);

                return plainNumber;
            });
        }
    };
});

app.directive('ngEnter', function() {
    return function(scope, element, attrs) {
        element.bind("keydown keypress", function(event) {
            if(event.which === 13) {
                scope.$apply(function(){
                    scope.$eval(attrs.ngEnter, {'event': event});
                });
                event.preventDefault();
            }
        });
    };
});

app.directive('formatTitle', function(){
    return {
        require: 'ngModel',
        link: function(scope, element, attrs, modelCtrl) {
            modelCtrl.$parsers.push(function (inputValue) {
                // this next if is necessary for when using ng-required on your input.
                // In such cases, when a letter is typed first, this parser will be called
                // again, and the 2nd time, the value will be undefined
                if (inputValue == undefined) return '' ;
                var transformedInput = inputValue.replace(/[^0-9a-zA-Z-]/g, '');
                if (transformedInput!=inputValue) {
                    modelCtrl.$setViewValue(transformedInput);
                    modelCtrl.$render();
                }
                return transformedInput;
            });
        }
    };
});

app.directive('formatNoSpeicalChar', function(){
    return {
        require: 'ngModel',
        link: function(scope, element, attrs, modelCtrl) {
            modelCtrl.$parsers.push(function (inputValue) {
                // this next if is necessary for when using ng-required on your input.
                // In such cases, when a letter is typed first, this parser will be called
                // again, and the 2nd time, the value will be undefined
                if (inputValue == undefined) return '' ;
                var transformedInput = inputValue.replace(/[^0-9a-zA-Z-]/g, '');
                if (transformedInput!=inputValue) {
                    modelCtrl.$setViewValue(transformedInput);
                    modelCtrl.$render();
                }
                return transformedInput;
            });
        }
    };
});

app.filter('unique', function() {
    return function(collection, keyname) {
        var output = [],  keys = [];
        angular.forEach(collection, function(item) {
            var key = item[keyname];
            if(keys.indexOf(key) === -1) {
                keys.push(key);
                output.push(item);
            }
        });
        return output;
    };
});


app.filter('searchFor', function(){

    // All filters must return a function. The first parameter
    // is the data that is to be filtered, and the second is an
    // argument that may be passed with a colon (searchFor:searchString)

    return function(arr, sTerm, sKey){
        if(!sTerm){
            return arr;
        }
        var result = [];
        sTerm = sTerm.toLowerCase();
        //var sKey = searchString.split('--')[1];
        //searchString = searchString.toLowerCase();
        // Using the forEach helper method to loop through the array
        angular.forEach(arr, function(item){
            if(item[sKey].toLowerCase().indexOf(sTerm) !== -1){
                result.push(item);
            }
        });

        return result;
    };
});

app.filter('highlight', ['$sce', function ($sce) {
    return function (input, searchParam) {
        if (!input || typeof input === 'function') return '';
        if (searchParam) {
            var words = '(' +
                    searchParam.split(/\ /).join(' |') + '|' +
                    searchParam.split(/\ /).join('|') +
                    ')',
                exp = new RegExp(words, 'gi');

            if (words.length) {
                input = input.replace(exp, "<span class=\"highlight\">$1</span>");
            }
        }
        return $sce.trustAsHtml(input);
    };
}]);



/*
 * Directive:
 * 		di-common
 *
 * Usage Example:
 * 		<div class="di-common" template='foo-bar'/>
 *
 * Notes:
 * 		- template attribute will inject the respective template defined with the perfix of 'di-' in directive folder
 * 		- Use Chrome startup switch '--allow-file-access-from-files' if testing with Chrome on local file:// protocol.
 *
 */
app.directive('diInclude', function(config) {
    /*
     * Return compiler definition object.
     */
    return {
        restrict : "C",
        templateUrl : function(tElement, tAttrs) {
            return 'view/' + tAttrs.template + '.html';
        }
    };
});


/**************************************
  ==== LEAP FROG UI DIRECTIVE's ====
 **************************************/

app.directive('diAlert', function(config) {
    /*
     * Return compiler definition object.
     */
    return {
        restrict : "C",
        scope : {
            type: '=',
            msg: '='
        },
        template : function(tElement, tAttrs) {
            return '<div class="media alert alert-'+tAttrs.type+'">'+
                '<div class="media-left"></div><div class="media-body">'+tAttrs.message+'</div>'
            '</div>';
        }

    };
});

app.directive('diMessage', function(config) {
    /*
     * Return compiler definition object.
     */
    return {
        restrict : "C",
        scope : {
            type: '=',
            msg: '='
        },
        template : function(tElement, tAttrs) {
            return '<div class="media message message-'+tAttrs.type+'">'+
                '<div class="media-left"></div><div class="media-body">'+tAttrs.message+'</div>'
            '</div>';
        }

    };
});

app.directive('diTooltip', function(config) {
    /*
     * This compile function is called when using $compile() in the application controller.
     * Once the template is ready, the parent scope is used to call scope.setSortableGrid(element)
     * to update the drag and drop grid.
     */
    var compileDirective = function compile(element, attrs, transclude) {
        return {
            pre : function preLink(scope, element, attrs, controller) {},
            post : function postLink(scope, element, attrs, controller) {
                initPopoverOverrides();
            }
        };
    };

    /*
     * Return compiler definition object.
     */
    return {
        compile : compileDirective,
        //transclude: true,
        //replace: true,
        restrict : "C",
        template : function(tElement, tAttrs) {
            return "<span aria-hidden='true' data-toggle='popover'" +
            " class='glyphicon glyphicon-"+(tAttrs.icon ? tAttrs.icon :"info-sign") + ( tAttrs.inverse ? " popover-white'" : " '" )+
            " data-placement='"+(tAttrs.position ? tAttrs.position : "top" )+"'" +
            " data-content='"+ tAttrs.content+"'></span>";
            ;
        }

    };
});


/*

 */
app.directive('diSwitch', function () {
    return {
        restrict: 'C',
        scope: {
            off: '=?',
            sm:'=?',
            disabled:'=?'
        },
        template : function(tElement, tAttrs) {

            return  "<div class='di-toggle-switch-container {{sm ? \"sm\" : \"\"}}' ng-click='onClick()'>"+
                    "<div class='di-toggle-switch {{ active ?  \"active\" : \"\" }} {{ disabled ? \"disabled\" : \"\"}}' >"+
                    "<span class='label-on'>ON</span> <span class='label-silder'> </span> <span class='label-off'>OFF</span>"+
                "</div></div>";
        },
        controller: function ($scope) {

            var self = $scope;
            //self.off = AppUtils.isBoolean(self.off) ? self.off : false;
            self.active = AppUtils.isBoolean(self.off) ? !self.off : true;
            self.sm = AppUtils.isBoolean(self.sm) ? self.sm : false;
            self.disabled = AppUtils.isBoolean(self.disabled) ? self.disabled : false;

            self.onClick = function () {
                if(!self.disabled)
                    self.active = !self.active;
            };

        }
    }
});


app.directive('diDropdown', function () {
    return {
        restrict: 'C',
        scope: {
            model: '=',
            options: '=',
            valueKey: '@',
            disabled: '=?',
            inverse: '=?',
            sm:'=?'
        },
        template : function(tElement, tAttrs) {

            return "<div class='di dropdown {{sm ? \"sm\" : \"\"}}  {{inv ? \"inverse\" : \"\"}} {{ disabled ? \"disabled\" : \"\"}}'>"+
                "<button id='dLabel' type='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false' title='{{getLabel()}}'>"+
                    "<span class='ddlabel'>{{getLabel()}}</span><span class='caret'></span>"+
                "</button>"+
                "<ul class='dropdown-menu' role='menu' aria-labelledby='dLabel'>"+
                    "<li ng-repeat='option in options' class='{{isSelected(option) ? \"active\" : \"\" }}' ng-click='onSelect(option)'>"+
                        "<span>{{getOptionValue(option)}}</span>"+
                    "</li>" +
                "</ul></div>";
        },

        controller: ['$scope', function($scope){

            $scope.isMultiSelect = AppUtils.isBoolean($scope.isMultiSelect) ? $scope.isMultiSelect : false;
            $scope.placeholder = $scope.placeholder ? $scope.placeholder : 'Select ...';
            //$scope.valueKey = $scope.propkeyname ? $scope.propkeyname :"....";
            $scope.sm = AppUtils.isBoolean($scope.sm) ? $scope.sm : false;
            $scope.disabled = AppUtils.isBoolean($scope.disabled) ? $scope.disabled : false;
            $scope.inv = AppUtils.isBoolean($scope.inverse) ? $scope.inverse : false;

            if($scope.isMultiSelect){
                $scope.model = [];
            }

            $scope.getLabel = function () {
                if(!$scope.isMultiSelect)
                    return $scope.model ? ($scope.valueKey ? $scope.model[$scope.valueKey] : $scope.model ) : $scope.placeholder;

                return $scope.placeholder;
            };
            $scope.getOptionValue = function (option) {
                return $scope.valueKey ? option[$scope.valueKey] : option;
            };
            $scope.openDropdown = function () {
                $scope.open = !$scope.open;
            };

            $scope.selectAll = function () {
                $scope.model = [];
                angular.forEach($scope.options, function (item, index) {
                    $scope.model.push(item);
                });
            };

            $scope.deselectAll = function () {
                $scope.model = [];
            };
            $scope.onSelect = function (option) {
                if($scope.isMultiSelect){
                    $scope.toggleSelectItem(option);
                }else {
                    $scope.model = option;
                    $scope.openDropdown();
                }
            };

            $scope.toggleSelectItem = function (option) {
                var intIndex = -1;
                angular.forEach($scope.model, function (item, index) {
                    if (item.id == option.id) {
                        intIndex = index;
                    }
                });

                if (intIndex >= 0) {
                    $scope.model.splice(intIndex, 1);
                }
                else {
                    $scope.model.push(option);
                }
            };

            $scope.isSelected = function (option) {
                return ($scope.model && option.id == $scope.model.id);
            };

            $scope.getClassName = function (option) {
                return  $scope.isSelected ? 'glyphicon glyphicon-ok green' : 'glyphicon glyphicon-remove red';
            };
        }]
    }
});


/**
 * Web Service class.
 */
var WebService = function(c, http) {

    var log = new Logger({name : 'WebService', level : c.config.logLevel});

    var self = this;

    /** Parent Controller Reference */
    self.controller = c;

    /** if any Default param need to sent with  every request */
    self.defaultParams = '';

    /** Default Data Prefix */
    self.urlPrefix = '/leapfrog';

    /** Angular HTTP service reference*/
    self.http = http;

    self.requestHeader = {'Content-Type' : 'application/json'};

    /** URL Prefix setter : override the default */
    self.setUrlPrefix = function(prefix){
        self.urlPrefix = prefix;
    };


    /** Request Default Query Parameter Setter */
    self.addDefaultParams = function(key, value){
        self.defaultParams = self.defaultParams + (self.defaultParams.contains('?') ? '&' : '?') + key + '=' + value;
    };

    /** Request Default Query Parameter Setter */
    self.addDefaultHeader = function(key, value){
        if(self.http)
            self.http.defaults.headers.common["DI-Header-"+key] = value;
    };




    /** GET Type HTTP data call */
    self.getData = function(url, callback){
        callWebService({ url : url, type : 'GET', data : null }, callback);
    };

    /** POST Type HTTP Data Call */
    self.postData = function(url, data, callback){
        callWebService({ url : url, type : 'POST', data : data }, callback);
    };

    /**
     * Private function to call web multiple services.
     * Use jQuery Ajax References
     */
    var jqWebService = function(params, callback, onSucces, onError) {

        //var responseObject = null;
        var startms = new Date().getTime();
        try {
            $.ajax({
                url : params.url,
                data : params.data,
                type : params.type,
                dataType : 'json',
                contentType: 'application/json',
                processData: false,
                async : true,
                cache : false,
                error: function(jqXHR, status, err) {
                    onError(jqXHR, status, err, callback);
                },
                success: function(data, status, jqXHR) {},
                complete : function(data, status, jqXHR) {
                    onSucces(data, status, jqXHR, callback);
                }
            });
        } catch(err) {
            log.error(err);
        };
    };

    /**
     * Private function to call web multiple services.
     * Use NG Ajax References
     */
    var ngWebService = function(params, callback, onSucces, onError){

        try{
            var request = self.http(
                {
                    method: params.type,
                    url: params.url,
                    data: params.data
                });
            request.then(
                function(response) { onSucces(response.data, response.status, response, callback); },
                function(response) { onError(response,  response.status,  response.error, callback); }
            ) ;

        } catch(err) {
            log.error(err);
        };
    };

    /**
     * Private function to call web multiple services.
     * Use either NG or jQuery Ajax References depending upon
     * availbility first check for NG otherwise jQuery.
     */
    var callWebService = function(params, callback) {
        params.url = self.urlPrefix + params.url + self.defaultParams;
        webService(params, callback);
    };

    var webService = function(params, callback) {

        if(params.type === 'POST')
            params.data = self.http && params.data !== null ? angular.toJson(params.data) : JSON.stringify(params.data);

        if(!self.controller.isValidUserSession()){
            log.error('Web Call blocked: Either User do have respective permission or session is not valid ... url={}', params.url);

            //if(callback)
            //callback({returnCode: -1, returnCodeDesc:'Error', status : 401, error: 'isValidUserSession'}, params.data);

            return;
        }

        //params.url = self.urlPrefix + params.url + self.defaultParams;
        log.debug(" >> "+params.url);

        var onError = function(jqXHR, status, err, callback) {
            //var ms = (new Date().getTime()-startms);
            log.error('callWebService error: status={}, error={}, url={}', status, err, params.url);
            if(callback)
                callback({returnCode: -1, returnCodeDesc:'Error', status : status, error: err}, params.data);
            self.controller.utils.notifyError('Problem processing request, check console logs for detail.', 5000);
            self.controller.hideProcessing();
        };

        var onSucces = function(data, status, jqXHR, callback) {
            try {
                if(callback) {
                    callback(
                        ( self.http ? data : JSON.parse(data.responseText) ),
                        (params.data? JSON.parse(params.data) :  null)
                    );
                }
            }catch(e){
                log.error('callWebService error parsing JSON: e={}, status={}, url={}, response={}',e.message, status, params.url, data.responseText);
                if(callback)
                    callback({returnCode: -1, returnCodeDesc:'Error', status : status, error: 'Error parsing JSON'}, params.data);
                self.controller.utils.notifyError('Problem processing response, check console logs for detail.', 5000);
            }
            self.controller.hideProcessing();
        };

        self.controller.showProcessing();
        if(self.http){
            ngWebService(params, callback, onSucces, onError);
        }
        else {
            jqWebService(params, callback, onSucces, onError);
        }

    };

};

