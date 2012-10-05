/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if !client
import js.Node;
#end

typedef CookiesGetOptions = {
    var signed : Bool;
}

typedef CookiesSetOptions = {
    var path : String;
    var expires : Date;
    var domain : String;
    var httpOnly : Bool;
    var secure : Bool;
}

#if !client
extern class Cookies {
    public function new(req : NodeHttpServerReq, res : NodeHttpServerResp, ?keys : Dynamic) : Void;
    
    public function get(name : String, ?opts : CookiesGetOptions) : String;
    public function set(name : String, value : String, ?opts : CookiesSetOptions) : Void;
    
    private static function __init__() : Void untyped {
        try {
            saffron.Cookies = Node.require("cookies");
        }
        catch(e : Dynamic) {
        }
    }
}
#else
class Cookies {
}
#end
