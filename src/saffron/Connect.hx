/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if !client

import js.Node;

typedef ConnectHandler = NodeHttpServerReq -> NodeHttpServerResp -> (Void -> Void) -> Void;

extern class Connect {
    public static function createServer() : Connect;
    
    @:overload(function(?route : String, fn : ConnectHandler) : Connect { })
    public function use(fn : ConnectHandler) : Connect;
    
    @:overload(function(path : String, ?fn : Void -> Void) : Connect {})
    public function listen(port : Int, ?host : String, ?fn : Void -> Void) : Connect;
    
    public static function basicAuth(fn : String -> String -> ?(Dynamic -> Dynamic -> Void) -> Bool) : ConnectHandler;
    public static function compress(?options : Dynamic) : ConnectHandler;
    public static function csrf(?options : Dynamic) : ConnectHandler;
    public static function directory(root : String, ?options : Dynamic) : ConnectHandler;
    public static function favicon(?path : String, ?options : Dynamic) : ConnectHandler;
    public static function logger(?format : String) : ConnectHandler;
    public static function responseTime() : ConnectHandler;
    public static function staticCache(?options : Dynamic) : ConnectHandler;
    public static function staticFiles(root : String, ?options : Dynamic) : ConnectHandler;
    
    private static function __init__() : Void untyped {
        try {
            saffron.Connect = Node.require("connect");
            saffron.Connect.staticFiles = untyped __js__('saffron.Connect.static');
        }
        catch(e : Dynamic) {
        }
    }
}

#end
