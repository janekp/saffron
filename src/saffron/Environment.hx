/* Copyright (c) 2012 Janek Priimann */

package saffron;

typedef EnvironmentJSON = {
    function stringify(obj : Dynamic) : String;
    function parse(str : String) : Dynamic;
}

@:native("RegExp") extern class EnvironmentRegExp {
    public var global : Bool;
    public var lastIndex : Int;
    
    public function new(pattern : String, ?modifiers : String) : Void;
    public function exec(str : String) : Array<String>;
}

#if !client
@:native("global") extern private class _Environment {
#else
@:native("window") extern private class _Environment {
#end
    public static function setTimeout(fn : Dynamic, ms : Int, ?args : Array<Dynamic>) : Int;
    public static function setInterval(fn : Dynamic, ms : Int, ?args : Array<Dynamic>) : Int;
}

#if !client
@:native("global") extern class Environment {
#else
@:native("window") extern class Environment {
#end
    public static function clearTimeout(id : Int) : Void;
    public static function clearInterval(id : Int) : Void;
    public static var JSON : EnvironmentJSON;
    
#if debug

    public static inline function crash(err : Dynamic, ?fn : Void -> Void) : Void {
#if !client
        if(err != null) {
            try {
                var mapstrace = saffron.tools.Node.require('mapstrace');
                
                untyped mapstrace.build(err, true, function(result) {
                    trace('\n' + untyped __js__('err.toString()') + ':\n' + mapstrace.stringify(result));
                    if(fn != null) fn(); else throw err;
                });
            }
            catch(e : Dynamic) {
                trace("module 'mapstrace' not found/loaded. Install it or remove -debug");
                if(fn != null) fn(); else throw err;
            }
        }
#else
        if(fn != null) fn(); else throw err;
#end
    }
    
    public static inline function setTimeout(fn : Dynamic, ms : Int, ?args : Array<Dynamic>) : Int {
        return untyped _Environment.setTimeout(function() {
            try {
                fn.call(untyped __js__('this'), args);
            }
            catch(e : Dynamic) {
                Environment.crash(e);
            }
        }, ms, args);
    }
    
    public static inline function setInterval(fn : Dynamic, ms : Int, ?args : Array<Dynamic>) : Int {
        return untyped _Environment.setInterval(function() {
            try {
                fn.call(untyped __js__('this'), args);
            }
            catch(e : Dynamic) {
                Environment.crash(e);
            }
        }, ms, args);
    }
#else
    public static inline function crash(e : Dynamic) : Void { throw e; }
    public static function setInterval(fn : Dynamic, ms : Int, ?args : Array<Dynamic>) : Int;
    public static function setTimeout(fn : Dynamic, ms : Int, ?args : Array<Dynamic>) : Int;
#end
}
