/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

@:require(client) class Client {
    
    macro public function config(ethis : Expr, key : Expr, value : Expr) : Expr {
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
    
    macro public function get(ethis : Expr, action : String, handler : Expr, ?auth : Expr) : Expr {
        return Macros.generateHandler(ethis, action, 'GET', handler, auth);
    }
    
    macro public function post(ethis : Expr, action : String, handler : Expr, ?auth : Expr) : Expr {
        return Macros.generatePlaceholder();
    }
    
    macro public function start(ethis : Expr, ?port : ExprOf<Int>, ?host : ExprOf<String>) : Expr {
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
    
    public function addHandler(path : String, regex : String, handler : Context.ContextHandler, method : String, auth : String, permission : String, key : String, value : String) : Void {
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
    
    @:keep
    public function navigate(url : String) : Void {
        try {
            var ctx = this.createContext(url);
            var handler = this.findHandler(this.handlers_static[untyped 'GET'], this.handlers[untyped 'GET'], ctx);
            
            if(handler != null) {
                untyped window.history.pushState({ }, 'Title', url);
                handler(ctx);
            }
        }
        catch(e : Dynamic) {
            trace(e.message);
        }
    }
    
    private function createContext(url : String) : Context {
        var ctx : Context = untyped { };
        var a : Dynamic = untyped document.createElement('A');
        
        a.href = url;
        
        ctx.href = url;
        ctx.host = a.hostname;
        ctx.protocol = untyped a.protocol.replace(':', '');
        ctx.hostname = a.hostname;
        ctx.port = a.port;
        ctx.pathname = untyped a.pathname.replace(__js__("/^([^\\/])/"), '/$1');
        ctx.search = a.search;
        ctx.query = untyped (function() {
            var q = {}, p = a.search.replace(__js__("/^\\?/"), '').split('&'), s;
            
            for(i in 0...p.length) {
                if(p[i].length > 0) {
                    s = p[i].split('=');
                    q[s[0]] = s[1];
                }
            }
            
            return q;
        }());
        ctx.hash = untyped a.hash.replace('#', '');
        
        if(untyped __js__('saffron.Async')) {
            ctx.async = untyped __js__('new saffron.Async()');
        }
        
        return ctx;
    }
    
    private function findHandler(handlers_static : Dynamic, handlers : Array<Context.ContextRegex>, ctx : Context) : Context.ContextHandler {
        var func = (handlers_static != null) ? handlers_static[untyped ctx.pathname] : null;
        var result;
        
        if(func == null && handlers != null) {
            for(handler in handlers) {
                if(handler.pattern.global) {
                    handler.pattern.lastIndex = 0;
                }
                
                if((result = handler.pattern.exec(ctx.pathname)) != null) {
                    if(result.length > 1) {
                        ctx.id = result[1];
                    }
                    
                    func = handler.func;
                    break;
                }
            }
        }
        
        if(func == null && handlers_static != null) {
            func = handlers_static[untyped __js__('""')];
        }
        
        return func;
    }
    
    public function run() : Void {
        Client.context = this;
        untyped __js__("document.onclick = function(e) { e = e || window.event; var element = e.target || e.srcElement; if(element.tagName == 'A') { saffron.Client.context.navigate(element.href); return false; } };");
    }
#end
}
