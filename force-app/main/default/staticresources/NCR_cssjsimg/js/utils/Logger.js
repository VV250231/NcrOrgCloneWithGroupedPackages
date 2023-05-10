/**
 * Implements a client and server logging class with multiple logging levels and message formatting.
 * In general, one logger instance is sufficient per application.  However, this class supports multiple
 * instances with unique names and logging levels.  This can be useful when deploying individual
 * components that have different logging requirements.  All messages are logged to the default browser
 * console or server based upon the following API:
 *
 * 		log.error(arguments); 				Logs error-level messages to the client console.
 * 		log.error.server(arguments); 		Logs error-level messages to the client console and server.
 *
 * 		log.warn(arguments); 				Logs warning-level messages to the client console.
 * 		log.warn.server(arguments); 		Logs warning-level messages to the client console and server.
 *
 * 		log.info(arguments); 				Logs info-level messages to the client console.
 * 		log.info.server(arguments); 		Logs info-level messages to the client console and server.
 *
 * 		log.debug(arguments); 				Logs debug-level messages to the client console.
 * 		log.debug.server(arguments); 		Logs debug-level messages to the client console and server.
 *
 * 		log.console(arguments); 			Logs messages regardless of level to the client console.
 * 		log.console.server(arguments); 		Logs messages regardless of level to the client console and server.
 * 		log.server(arguments); 				Logs messages regardless of level to the server only.
 *
 * 		log.audit(arguments);				Logs audit messages regardless of level to the server only.
 *
 * Multiple logging levels are supported:
 *
 *		Logger.NONE     - Disables all logging.
 *      Logger.ERROR    - Logs messages at ERROR level.
 *      Logger.WARN     - Logs messages at ERROR and WARN levels.
 *      Logger.INFO     - Logs messages at ERROR, WARN and INFO levels.
 *      Logger.DEBUG    - Logs messages at ERROR, WARN, INFO and DEBUG levels.
 *
 * Logging levels can be set dynamically at runtime:
 *
 *      log.setLevel(Logger.WARN);
 *
 * Each logging method supports standard string message parsing with 0-n replaceable parameters.
 * Replacement parameter positions are denoted by {} place-holders in the first message string.
 * Each place-holder is substituted with user provided arguments.  This eliminates the overhead of
 * string manipulations/concatenations before the logging level is checked.  For example:
 *
 *      // Instead of doing this where the message string is processed first:
 *      log.info('This is a test A=' + 1 + ', B=' + 2 + ', C=' + 3 + '...');
 *
 *      // You can do this where the message string is processed only when the logger level matches.
 *      log.info('This is a test A={}, B={}, C={}...', 1, 2, 3);
 *
 * Native errors (e.g. uncaught errors) are generally logged to the client console by default.
 * This class will also capture those events and log them to the server.  If multiple Logger
 * instances are in use, this feature can be disabled during instantiation.
 *
 * Example of creating and using a logger:
 *
 *      var log = new Logger({name: 'AUCTION', level: Logger.DEBUG});
 *
 *      try {
 *      	log.info.server('log something to client and server.');
 *      	...
 *      	if(auditUser) {
 *      		log.server('Log something to the server for audit purposes.');
 *      	}
 *      	...
 *      } catch (err) {
 *      	log.error.server('Log an error.');
 *      }
 *
 *
 */
var Logger = function(params) {

    /**
     * Private function that returns the formatted message with parameter replacements.
     * The try/catch ensures we fail gracefully in case of bad input.
     *
     * @param input - the message string and parameters.
     * @returns string - formatted message.
     */
    var formatMessage = function(input) {
        try {
            if(!input) {
                throw new Error('No input specified.');
            } else {
                var message = input[0].toString();
                for(var i=1; i<input.length; i++) {
                    var obj = (input[i] !== null && input[i] !== undefined) ? input[i].toString() : '';
                    message = message.replace('\{\}', obj);
                }
                return message;
            }
        } catch(err) {
        	if(window.console)
        		console.log('Logger.formatMessage error: ' + err);
        }
        return null;
    };

    /**
     * Private function returns a formatted ERROR message.
     *
     * @param args
     */
    var getErrorMessage = function(args) {
    	return (logName + ' ERROR: ' +   formatMessage(args));
    };

    /**
     * Private function returns a formatted WARN message.
     *
     * @param args
     */
    var getWarnMessage = function(args) {
    	return (logName + ' WARN: ' +   formatMessage(args));
    };

    /**
     * Private function returns a formatted INFO message.
     *
     * @param args
     */
    var getInfoMessage = function(args) {
    	return (logName + ' INFO: ' +   formatMessage(args));
    };

    /**
     * Private function returns a formatted DEBUG message.
     *
     * @param args
     */
    var getDebugMessage = function(args) {
    	return (logName + ' DEBUG: ' +   formatMessage(args));
    };

    /**
     * Private function returns a formatted LOG message.
     *
     * @param args
     */
    var getConsoleMessage = function(args) {
    	return (logName + ' LOG: ' +   formatMessage(args));
    };

    /**
     * Private function returns a formatted AUDIT message.
     *
     * @param args
     */
    var getAuditMessage = function(args) {
    	return (logName + ' AUDIT: ' +   formatMessage(args));
    };

    /**
     * Private function that derives a logging level based upon either a numeric or string value.
     * Returns a default logging level if value cannot be determined.
     *
     * @param value - a string or numeric value for logging level.
     * @returns number - the derived logging level.
     */
    var deriveLevel= function(value) {
        if(typeof(value) === 'string') {
            value = value.toUpperCase();
            if(value === 'NONE')
                return Logger.NONE;
            else if(value === 'ERROR')
                return Logger.ERROR;
            else if(value === 'WARN')
                return Logger.WARN;
            else if(value === 'INFO')
                return Logger.INFO;
            else if(value === 'DEBUG')
                return Logger.DEBUG;
        } else if(typeof(value) === 'number') {
            if(value === Logger.NONE)
                return Logger.NONE;
            else if(value === Logger.ERROR)
                return Logger.ERROR;
            else if(value === Logger.WARN)
                return Logger.WARN;
            else if(value === Logger.INFO)
                return Logger.INFO;
            else if(value === Logger.DEBUG)
                return Logger.DEBUG;
        }
        return Logger.DEFAULT;
    };


    /**
     * Private function that sends a message to the server.
     * Appends additional information to the message prior to sending.
     *
     * @param msg - the message to send
     */
    var send = function(level, msg) {
    	msg += '; LOCATION: ' + window.location.href;
    	msg += '; AGENT: ' + navigator.userAgent;
    	//msg += '; CSIZE: ' + $.cookie('cCSC');
    	/*
    	$.ajax({
		    type : 'POST',
		    dataType : 'json',
		    url : 'logs.ajax',
		    async : true,
		    data : { 'level' : level, 'msg' : msg},
		    error : function(jqXHR, status, error) {},
		    success : function(data, status, jqXHR) {},
		    complete : function(jqXHR, status) {}
		});
		*/
	};

    /**
     * Public function that sets the logging level.  This can be
     * used to dynamically change the logging level at runtime.
     *
     * @param value - a string or numeric value for logging level.
     */
    this.setLevel = function(value) {
       logLevel = deriveLevel(value);
    };

    /**
     * Public function that returns the runtime logging level.
     *
     * @returns number - logging level.
     */
    this.getLevel = function() {
        return logLevel;
    };

    /**
     * Public function that returns the runtime logger name.
     * The logger name is set during instantiation only.
     *
     * @returns string - name
     */
    this.getName = function() {
        return logName;
    };

    /**
     * Public function that logs client messages at ERROR level.
     *
     * @param arguments - one or more input arguments.
     */
    this.error = function() {
        if (logLevel >= Logger.ERROR && window.console)
            console.log(getErrorMessage(arguments));
    };

    /**
     * Public function that logs client and server messages at ERROR level.
     *
     * @param arguments - one or more input arguments.
     */
    this.error.server = function() {
        if (logLevel >= Logger.ERROR) {
        	var msg = getErrorMessage(arguments);
        	if(window.console)
        		console.log(msg);
        	send(Logger.ERROR, msg);
        }
    };

    /**
     * Public function that logs client messages at WARN level.
     *
     * @param arguments - one or more input arguments.
     */
    this.warn = function() {
        if (logLevel >= Logger.WARN && window.console)
            console.log(getWarnMessage(arguments));
    };

    /**
     * Public function that logs client and server messages at WARN level.
     *
     * @param arguments - one or more input arguments.
     */
    this.warn.server = function() {
        if (logLevel >= Logger.WARN) {
        	var msg = getWarnMessage(arguments);
        	if(window.console)
        		console.log(msg);
        	send(Logger.WARN, msg);
        }
    };

    /**
     * Public function that logs client messages at INFO level.
     *
     * @param arguments - one or more input arguments.
     */
    this.info = function() {
        if (logLevel >= Logger.INFO && window.console)
            console.log(getInfoMessage(arguments));
    };

    /**
     * Public function that logs client and server messages at INFO level.
     *
     * @param arguments - one or more input arguments.
     */
    this.info.server = function() {
        if (logLevel >= Logger.INFO) {
        	var msg = getInfoMessage(arguments);
        	if(window.console)
        		console.log(msg);
        	send(Logger.INFO, msg);
        }
    };

    /**
     * Public function that logs client messages at DEBUG level.
     *
     * @param arguments - one or more input arguments.
     */
    this.debug = function() {
        if (logLevel >= Logger.DEBUG && window.console)
            console.log(getDebugMessage(arguments));
    };

    /**
     * Public function that logs client and server messages at DEBUG level.
     *
     * @param arguments - one or more input arguments.
     */
    this.debug.server = function() {
        if (logLevel >= Logger.DEBUG) {
        	var msg = getDebugMessage(arguments);
        	if(window.console)
        		console.log(msg);
        	send(Logger.DEBUG, msg);
        }
    };

    /**
     * Public function that logs client messages regardless of logging level.
     *
     * @param arguments - one or more input arguments.
     */
    this.console = function() {
        if (logLevel > Logger.NONE && window.console)
            console.log(getConsoleMessage(arguments));
    };

    /**
     * Public function that logs client and server messages regardless of logging level.
     *
     * @param arguments - one or more input arguments.
     */
    this.console.server = function() {
    	if (logLevel > Logger.NONE) {
    		var msg = getConsoleMessage(arguments);
    		if(window.console)
    			console.log(msg);
    		send(Logger.INFO, msg);
    	}
    };

    /**
     * Public function that logs server messages regardless of logging level.
     *
     * @param arguments - one or more input arguments.
     */
    this.server = function() {
    	if (logLevel > Logger.NONE)
    		send(Logger.INFO, getConsoleMessage(arguments));
    };


    /**
     * Public function that logs audit messages regardless of logging level
     * when user has a 'jsAuditLogs' cookie.  This cookie is controlled by
     * the server.
     *
     * @param arguments - one or more input arguments.
     */
    this.audit = function() {
    	if (logLevel > Logger.NONE && $.cookie('jsAuditLogs'))
    		send(Logger.INFO, getAuditMessage(arguments));
    };

    /**
     * Initialize private variables.
     * Assume defaults if parameters are missing.
     */
    if(!params) params = {};
    var logName  = (params.name) ? params.name : 'Logger';
    var logLevel = (params.level) ? deriveLevel(params.level) : Logger.DEFAULT;
    var logNative = true;//( params.native === false) ? false : true ) ;

    /**
     * Catch and log native errors when enabled.
     */
    if(logNative) {
		window.onerror = function(message, file, line) {
	        if (logLevel >= Logger.ERROR) {
	        	var msg = getErrorMessage(['{}, file={}, line={}', message, file, line]);
	        	send(Logger.ERROR, msg);
	        }
		};
    }

};

/**
 * Logger constant.
 */
Logger.NONE = 0;
/**
 * Logger constant.
 */
Logger.ERROR = 1;
/**
 * Logger constant.
 */
Logger.WARN = 2;
/**
 * Logger constant.
 */
Logger.INFO = 3;
/**
 * Logger constant.
 */
Logger.DEBUG = 4;
/**
 * Logger constant.
 */
Logger.DEFAULT = Logger.WARN;


