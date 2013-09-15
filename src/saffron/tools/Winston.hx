/* Copyright (c) 2013 Janek Priimann */

package saffron.tools;

#if !client

import js.Node;

typedef WinstonTransports = {
    var Console : WinstonTransport;
    var File : WinstonTransport;
    var Http : WinstonTransport;
};

typedef WinstonTransportOptions = {
    ?level : String,
    ?silent : Bool,
    ?colorize : Bool,
    ?name : String,
    ?timestamp : Bool,
    ?handleExceptions : Bool
};

typedef WinstonFileTransportOptions = { > WinstonTransportOptions,
    ?filename : String,
    ?maxsize : Int,
    ?maxFiles : Int,
    ?stream : NodeWriteStream,
    ?json : Bool
};

typedef WinstonHttpTransportAuthOptions = {
    ?username : String,
    ?password : String
};

typedef WinstonHttpTransportOptions = { > WinstonTransportOptions,
    ?ssl : Bool,
    ?host : String,
    ?port : Int,
    ?auth : WinstonHttpTransportAuthOptions,
    ?path : String
};

typedef WinstonTransport = {
    var level : String;
};

typedef WinstonOptions = {
    ?exitOnError : Bool,
    ?level : String,
    ?transports : Array<WinstonTransport>
};

typedef WinstonStreamOptions = {
    ?start : Int
};

typedef WinstonStream = {
    function on(event : String, fn : String -> Void) : Void;
};

typedef WinstonQueryOptions = {
    ?from : saffron.tools.Date,
    ?until : saffron.tools.Date
};

extern class Winston {
    public static inline var level_debug = 'debug';
    public static inline var level_info = 'info';
    public static inline var level_notice = 'notice';
    public static inline var level_warning = 'warning';
    public static inline var level_error = 'error';
    public static inline var level_critical = 'crit';
    public static inline var level_alert = 'alert';
    public static inline var level_emergency = 'emerg';
    
    public static function createLogger(?options : WinstonOptions) : Winston;
    public static function createConsoleTransport(?options : WinstonTransportOptions) : WinstonTransport;
    public static function createFileTransport(?options : WinstonFileTransportOptions) : WinstonTransport;
    public static function createHttpTransport(?options : WinstonHttpTransportOptions) : WinstonTransport;
    
    public static var transports : WinstonTransports;
    
    public var level : String;
    
    public function debug(line : String, ?meta : Dynamic) : Void;
    public function info(line : String, ?meta : Dynamic) : Void;
    public function notice(line : String, ?meta : Dynamic) : Void;
    public function warning(line : String, ?meta : Dynamic) : Void;
    public function error(line : String, ?meta : Dynamic) : Void;
    public function crit(line : String, ?meta : Dynamic) : Void;
    public function alert(line : String, ?meta : Dynamic) : Void;
    public function emerg(line : String, ?meta : Dynamic) : Void;
    
    public function log(level : String, line : String, ?meta : Dynamic) : Void;
    
    public function add(transport : WinstonTransport, ?options : WinstonTransportOptions) : Winston;
    public function remove(transport : WinstonTransport) : Winston;
    public function handleExceptions(transport : WinstonTransport) : Winston;
    public function clear() : Void;
    
    public function query(options : WinstonQueryOptions, fn : String -> Array<Dynamic> -> Void) : Void;
    public function stream(options : WinstonStreamOptions) : WinstonStream;
    public function close() : Void;
    
    private static function __init__() : Void untyped {
        try {
            if(saffron.tools == null) {
                saffron.tools = { };
            }
            
            // What about other Winston variants?
            saffron.tools.Winston = Node.require('winston');
            
            saffron.tools.Winston.createLogger = function(options) {
                return __js__('new (saffron.tools.Winston.Logger)')(options);
            };
            saffron.tools.Winston.createConsoleTransport = function(options) {
                return __js__('new (saffron.tools.Winston.transports.Console)')(options);
            };
            saffron.tools.Winston.createFileTransport = function(options) {
                return __js__('new (saffron.tools.Winston.transports.File)')(options);
            };
            saffron.tools.Winston.createHttpTransport = function(options) {
                return __js__('new (saffron.tools.Winston.transports.Http)')(options);
            };
        }
        catch(e : Dynamic) {
        }
    }
}

#else

typedef Winston = {
    // Nothing!
};

#end
