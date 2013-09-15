/* Copyright (c) 2013 Janek Priimann */

package saffron;

#if !macro
import js.Node;
import saffron.Async;
import saffron.tools.Express;
#else
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class Handler {
	macro public function async(ethis : Expr, fn : Expr, ?parallel : Bool, ?nextTick : Bool) : Expr {
        return Macros.generateAsync(ethis, fn, parallel, nextTick);
    }
    
    macro public function parallel(ethis : Expr, fn : Expr, ?nextTick : Bool) : Expr {
        return Macros.generateAsync(ethis, fn, true, nextTick);
    }
    
#if !macro
	public var request : ExpressRequest;
    public var response : ExpressResponse;
    private var _async : Dynamic;
    
    public function new(request : ExpressRequest, response : ExpressResponse) {
    	this.request = request;
    	this.response = response;
    	this._async = new Async();
    }
    
    public inline function redirect(location : String, ?code : Int = 200) : Void {
    	this.response.redirect(code, location);
    }
    
    public inline function render(json : Dynamic, ?code : Int = 200) : Void {
    	this.response.json(code, json);
    }
    
    public inline function sendfile(path : String) : Void {
    	this.response.sendfile(path);
    }
#end
}
