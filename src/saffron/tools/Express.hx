/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron.tools;

import js.Node;

typedef ExpressCookieOptions = {
	public var expires : Date;
	public var maxAge : Int;
	public var httpOnly : Bool;
	public var domain : String;
	public var path : String;
	public var secure : Bool;
	public var signed : Bool;
};

typedef ExpressRequest = { > NodeHttpServerReq,
	public var cookies : Dynamic;
	public var signedCookies : Dynamic;
	public var params : Dynamic;
	public var ip : String;
	public var ips : Array<String>;
	public var path : String;
	public var host : String;
	public var fresh : Bool;
	public var stale : Bool;
	public var xhr : Bool;
	public var protocol : String;
	public var originalUrl : String;
	public var secure : Bool;
	
	@:overload(function(types : Array<String>) : Bool {})
	public function accepts(type : String) : Bool;
	public function is(type : String) : Bool;
	public function get(name : String) : String;
	public function param(name : String) : String;
	
	// Extensions
	public var permission : String;
	public var user : Dynamic;
};

typedef ExpressResponse = { > NodeHttpServerResp,
	public function cookie(name : String, value : String, options : ExpressCookieOptions) : ExpressResponse;
	public function clearCookie(name : String, ?options : ExpressCookieOptions) : ExpressResponse;
	public function status(code : Int) : ExpressResponse;
	public function set(key : String, value : String) : ExpressResponse;
	public function redirect(code : Int, url : String) : ExpressResponse;
	public function charset(name : String) : ExpressResponse;
	public function location(url : String) : ExpressResponse;
	public function type(name : String) : ExpressResponse;
	@:overload(function(data : Dynamic) : Void {})
    public function send(code : Int, data : Dynamic) : ExpressResponse;
    @:overload(function(data : Dynamic) : Void {})
    public function json(code : Int, data : Dynamic) : ExpressResponse;
	@:overload(function(data : Dynamic) : Void {})
    public function jsonp(code : Int, data : Dynamic) : ExpressResponse;
    public function format(obj : Dynamic) : ExpressResponse;
	public function attachment(path : String) : ExpressResponse;
	public function sendfile(path : String) : ExpressResponse;
	public function download(path : String, filename : String) : ExpressResponse;
};

extern class Express {
	public static inline var environment_production = 'production';
    public static inline var environment_development = 'development';
    
    @:overload(function(username : String, password : String) : Dynamic {})
    public static function basicAuth(fn : String -> String -> (Int -> Void) -> Void) : Dynamic;
    public static function bodyParser() : Dynamic;
    public static function json() : Dynamic;
    public static function urlencoded() : Dynamic;
    public static function multipart() : Dynamic;
    public static function logger() : Dynamic;
    public static function compress() : Dynamic;
    public static function methodOverride() : Dynamic;
    @:overload(function() : Dynamic {})
    public static function cookieParser(secret : String) : Dynamic;
    public static function cookieSession() : Dynamic;
    public static function csrf() : Dynamic;
    public static function directory(path : String) : Dynamic;
    public static function Static(path : String) : Dynamic;
    
    public function new() : Void;
    
    public function configure(env : String, fn : Void -> Void) : Void;
    public function locals(variables : Dynamic) : Void;
    @:overload(function(path : String, fn : ExpressRequest -> ExpressResponse -> Void) : Void {})
    public function get(path : String, fn1 : ExpressRequest -> ExpressResponse -> (Int -> Void) -> Void, fn2 : ExpressRequest -> ExpressResponse -> Void) : Void;
    public function post(path : String, fn : ExpressRequest -> ExpressResponse -> Void) : Void;
    public function all(path : String, fn : ExpressRequest -> ExpressResponse -> Void) : Void;
    public function use(fn : ExpressRequest -> ExpressResponse -> (Int -> Void) -> Void) : Void;
    public function listen(port : Int) : Void;
    public function param(name : String, fn : Dynamic) : Void;
    public function enable(feature : String) : Void;
    public function disable(feature : String) : Void;
    
    private static function __init__() : Void untyped {
        try {
        	if(saffron.tools == null) {
                saffron.tools = { };
            }
            
            saffron.tools.Express = Node.require('express');
            saffron.tools.Express.Static = untyped __js__("saffron.tools.Express.static");
        }
        catch(e : Dynamic) {
        }
    }
}
