/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if !macro

#if !client
import js.Node;
#end

#else

import haxe.macro.Context;
import haxe.macro.Expr;

#end

class Handler {
    
    @:macro public function query(ethis : Expr, q : String, p : Expr, ?fn : Expr) : Expr {
        return Macros.generateDataQuery(ethis, q, p, fn);
    }
    
#if !macro
    private var _ctx : saffron.Context;
    
    public function new(context : saffron.Context) {
        this._ctx = context;
    }
    
    private inline function error(?status : Int) : Void {
#if !client
        untyped Server.context.handleError((status != null) ? status : 500, this._ctx.request, this._ctx.response);
#else
        // TODO: 
#end
    }
    
    private inline function redirect(location : String) : Void {
#if !client
        this._ctx.response.writeHead(302, { 'Location': location });
        this._ctx.response.end();
#else
        Window.location.replace(location);
#end
    }
    
    private inline function cookies() : Cookies {
        return this._ctx.cookies;
    }
    
    private inline function param(name : String) : String {
        return this._ctx.query[untyped name];
    }
    
    private inline function isPost() : Bool {
        return (this._ctx.request.method == 'POST') ? true : false;
    }
#end
}
