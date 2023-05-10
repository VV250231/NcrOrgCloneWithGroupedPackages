/**
 * Application Utilities.
 */
'use strict';
var AppUtils = {};

/**
 * Returns a query parameter value by the parameter name. 
 * Example: http://www.diginsite.com?foo=bar		// sample request
 * Usage: 	AppUtils.getParameter('foo'); 	// returns 'bar'
 * @author developer.mozilla.org.
 */
AppUtils.getParameter = function(name) {
	return decodeURI(window.location.search.replace(new RegExp("^(?:.*[&\\?]" + encodeURI(name).replace(/[\.\+\*]/g, "\\$&") + "(?:\\=([^&]*))?)?.*$", "i"), "$1"));
};

/**
 * Checks for valid date.
 */
AppUtils.isValidDate = function (dateStr) {
    if (dateStr == undefined)
        return false;
    var dateTime = Date.parse(dateStr);

    if (isNaN(dateTime)) {
        return false;
    }
    return true;
};

/**
 * Tab format JSON object for display, logging, etc.
 */
AppUtils.formatJSON = function(data) {
	return JSON.stringify(data, 'undefined', '\t');
};

/**
 * Checks for undefined (null or undefined) type.
 */
AppUtils.isUndefined = function(value) { 
	return (value === null || typeof value === 'undefined') ? true : false; 
};

/**
 * Checks for number type.
 */
AppUtils.isNumber= function(value) { 
	return (value !== null && !isNaN(value)) ? true : false; 
};

AppUtils.isNonZeroNumber= function(value) { 
	return AppUtils.isNumber(value) && parseInt(value, 10) > 0; 
};

/**
 * Checks for string type.
 */
AppUtils.isString = function(value) { 
	return (typeof value === 'string') ? true : false; 
};

AppUtils.isUndefinedString = function(value) { 
	return (AppUtils.isUndefined(value) || !AppUtils.isString(value) || value.trimToNull() == null ) ? true : false; 
};

/**
 * Checks for boolean type.
 */
AppUtils.isBoolean = function(value) { 
	return !AppUtils.isUndefined(value) && (value === true || value === false) ? true : false; 
};

/**
 * Checks for function type.
 */
AppUtils.isFunction = function(value) { 
	return (typeof value === 'function') ? true : false; 
};

/**
 * Checks for object type.
 */
AppUtils.isObject = function(value) { 
	return (typeof value === 'object') ? true : false; 
};

/**
 * Checks for array type.
 */
AppUtils.isArray = function(value) {
	return Object.prototype.toString.call(value) === '[object Array]';
};

/**
* Check if v1 contains part or complete v2.
* Checking is case insensitive.
*/
AppUtils.contains = function(v1, v2){
       if(AppUtils.isUndefined(v1) || AppUtils.isUndefined(v2) || (v1+"").trimToNull() === null ||  (v2+"").trimToNull() === null)           
              return false;
       
       return (v1+"").toLowerCase().contains((v2+"").toLowerCase()); 
};


/**
 * String prototype extensions.
 */
'use strict';
if (typeof String.prototype.trim !== 'function') {
	/**
	 * Adds trim function for IE8. 
	 */
	String.prototype.trim = function() {
		return this.replace(/^\s+|\s+$/g, '');
	};
}

if (typeof String.prototype.trimToNull !== 'function') {
	/**
	 * Trims a string to null if empty.
	 */
	String.prototype.trimToNull = function() {
		try {
			var str = ('' + this.toString());
			str = str.trim();
			if (str && str.length > 0)
				return str;
			else if (!str || str.length == 0)
				return null;
		}
		catch (err) {
			throw err;
		}
		return null;
	};
}

if (typeof String.prototype.contains !== 'function') {
	/**
	 * Adds contains function for IE8. 
	 */
    String.prototype.contains = function() {
        return String.prototype.indexOf.apply( this, arguments ) !== -1;
    };
}

/**
 * Number prototype extensions.
 */

var isNumber = function(value) {
    if ((undefined === value) || (null === value)) {
        return false;
    }
    if (typeof value == 'number') {
        return true;
    }
    return !isNaN(value - 0);
};

var isInteger = function(value) {
	if(!isNumber(value))
		return false;
	
    var er = /^-?[0-9]+$/;
    return er.test(value);
};

/**
 * Array prototype extensions.
 */

if (!Array.prototype.indexOf) {
	/**
	 * Adds indexOf function for IE8. 
	 */
    Array.prototype.indexOf = function(obj, start) {
         for (var i = (start || 0), j = this.length; i < j; i++) {
             if (this[i] === obj) { return i; }
         }
         return -1;
    };
};
