/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

@:require(client) class Client {
    
    @:macro public function config(ethis : Expr, key : Expr, value : Expr) : Expr {
        var k = Macros.stringify(key);
        
        if(k == 'client_prefix' || k == 'remote_prefix' || k == 'strip_trailing_slash') {
            var s : Expr = {
                expr : EField(ethis, k), 
                pos : Context.currentPos()
            };
            
            return macro $s = $value;
        }
        
        return Macros.generatePlaceholder();
    }
    
    @:macro public function get(ethis : Expr, action : String, handler : Expr, ?auth : Expr) : Expr {
        return Macros.generateHandler(ethis, action, 'GET', handler, auth);
    }
    
    @:macro public function post(ethis : Expr, action : String, handler : Expr, ?auth : Expr) : Expr {
        return Macros.generatePlaceholder();
    }
    
    @:macro public function start(ethis : Expr, ?port : ExprOf<Int>, ?host : ExprOf<String>) : Expr {
        return macro $ethis.run();
    }
    
#if !macro
    public static var context : Client = null;
    
    public var client_prefix : String = '/index.js';
    public var strip_trailing_slash : Bool = true; // /hello/ -> /hello
    public var remote_prefix : String = '/r/';
    
    private var handlers : Dynamic;
    private var handlers_static : Dynamic;
    private var routes : Dynamic;
    
    public function new() {
        this.handlers = { };
        this.handlers_static = { };
        this.routes = { };
    }
    
    public function addHandler(path : String, regex : String, handler : Context.ContextHandler, method : String, auth : String, key : String, value : String) : Void {
        var r : Environment.EnvironmentRegExp = (regex != null) ? new Environment.EnvironmentRegExp(regex, "g") : null;
        var h : Context.ContextHandler = handler;
        
        if(method == null) {
            method = 'GET';
        }
        
        if(key != null) {
            this.routes[untyped key] = value;
        }
        
        if(r != null) {
            var handlers : Array<Context.ContextRegex> = this.handlers[untyped method];
            
            if(handlers == null) {
                handlers = new Array<Context.ContextRegex>();
                untyped this.handlers[method] = handlers;
            }
            
            handlers.push({ func: h, pattern: r });
        } else {
            var handlers : Dynamic = this.handlers_static[untyped method];
            
            if(handlers == null) {
                handlers = { };
                untyped this.handlers_static[method] = handlers;
            }
            
            untyped handlers[path] = h;
        }
    }
    
    public function run() : Void {
    }
#end
}
