/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if !client

#if !macro
import js.Node;
#else
import haxe.macro.Context;
import haxe.macro.Expr;
#end

private typedef ServerRemoteHandler = {
    var id : String;
    var query : String;
    var args : String;
};

class Server {

    @:macro public function config(ethis : Expr, key : Expr, value : Expr) : Expr {
        var k = Macros.stringify(key);
        var s : Expr = {
            expr : EField(ethis, k), 
            pos : Context.currentPos()
        };
        
        return macro $s = $value;
    }
    
    @:macro public function get(ethis : Expr, action : String, handler : Expr, ?auth : Expr) : Expr {
        return Macros.generateHandler(ethis, action, 'GET', handler, auth);
    }
    
    @:macro public function post(ethis : Expr, action : String, handler : Expr, ?auth : Expr) : Expr {
        return Macros.generateHandler(ethis, action, 'POST', handler, auth);
    }
    
#if !macro
    public static var context : Server = null;
    
    public var auth : Context -> (Dynamic -> Int -> Void) -> Void = null;
    public var database : Void -> Data.DataAdapter = null;
    public var client_prefix : String = '/index.js';
    public var max_post_size : Int = 1024 * 16; // 16kib
    public var strip_trailing_slash : Bool = true; // /hello/ -> /hello
    public var remote_prefix : String = '/r/';
    public var root : String = null;
    
    private var errors : Dynamic;
    private var handlers : Dynamic;
    private var handlers_static : Dynamic;
    private var routes : Dynamic;
    
    public function new() {
        this.errors = { };
        this.handlers = { };
        this.handlers_static = { };
        this.routes = { };
    }
    
    public function addError(status : Int, fn : NodeHttpServerReq -> NodeHttpServerResp -> Void) : Void {
        untyped this.errors[status] = fn;
    }
    
    public function addHandler(path : String, regex : String, handler : Context.ContextHandler, method : String, auth : String, key : String, value : String) : Void {
        var r : Environment.EnvironmentRegExp = (regex != null) ? new Environment.EnvironmentRegExp(regex, "g") : null;
        var h : Context.ContextHandler;
        
        if(method == null) {
            method = 'GET';
        }
        
        if(key != null) {
            this.routes[untyped key] = value;
        }
        
        if(auth == 'auth_required') {
            h = function(ctx) {
                if(this.auth != null) {
                    this.auth(ctx, function(token, err) {
                        ctx.token = token;
                        
                        if(token != null) {
                            handler(ctx);
                        } else {
                            this.handleError((err != null) ? err : 403, ctx.request, ctx.response);
                        }
                    });
                } else {
                    this.handleError(403, ctx.request, ctx.response);
                }
            };
        } else if(auth == 'auth_optional') {
            h = function(ctx) {
                if(this.auth != null) {
                    this.auth(ctx, function(token, err) {
                        ctx.token = token;
                        handler(ctx);
                    });
                } else {
                    handler(ctx);
                }
            };
        } else {
            h = handler;
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
    
    private function handleError(status : Int, req : NodeHttpServerReq, res : NodeHttpServerResp) : Void {
        var handler : NodeHttpServerReq -> NodeHttpServerResp -> Void = untyped this.errors[status];
        
        if(handler != null) {
            handler(req, res);
        } else {
            res.writeHead((status >= 100 && status < 600) ? status : 500, { "Content-Type": "text/html" });
            res.end();
        }
    }
    
    public function handleRequest(req : NodeHttpServerReq, res : NodeHttpServerResp, ?next : Void -> Void) {
        var ctx : Context = untyped Node.url.parse(req.url, true);
        var handler : Context.ContextHandler = null;
        var regex, plen;
        
        ctx.request = req;
        ctx.response = res;
        
        if(this.strip_trailing_slash && (plen = ctx.pathname.length) > 1 && ctx.pathname.charAt(plen - 1) == '/') {
            ctx.pathname = untyped __js__('ctx.pathname.substr(0, plen - 1)');
        }
        
        if(ctx.query == null) {
            ctx.query = { };
        }
        
        if(req.method == 'POST') {
            var postData = '';
            
            handler = this.findHandler(this.handlers_static[untyped 'POST'], this.handlers[untyped 'POST'], ctx);
            
            if(handler != null) {
                if(Cookies != null) {
                    ctx.cookies = new Cookies(req, res);
                }
                
                req.on('data', function(data) {
                    postData += data;
                    
                    if(postData.length > this.max_post_size) {
                        throw 'POST data exceeds the max limit (must: ' + postData.length + ' <= ' + this.max_post_size + ')';
                    }
                });
                
                req.on('end', function() {
                    var query = Node.queryString.parse(postData);
                    
                    untyped __js__("for(var key in query) { url.query[key] = query[key]; }");
                    
                    handler(ctx);
                });
            } else if(next != null) {
                next();
            } else {
                this.handleError(404, req, res);
            }
        } else if(req.method == 'OPTIONS') {
            var hasGet = (this.findHandler(this.handlers_static[untyped 'GET'], this.handlers[untyped 'GET'], ctx) != null) ? true : false;
            var hasPost = (this.findHandler(this.handlers_static[untyped 'POST'], this.handlers[untyped 'POST'], ctx) != null) ? true : false;
            
            if(hasGet || hasPost) {
                res.writeHead(200, {
                    'Access-Control-Allow-Methods': ((hasGet) ? 'GET, ' : '') + ((hasPost) ? 'POST, ' : '') + 'OPTIONS',
                    'Access-Control-Allow-Headers': 'X-Requested-With'
                });
                res.end();
            } else if(next != null) {
                next();
            } else {
                res.writeHead(200, { 'Access-Control-Allow-Methods': 'GET, OPTIONS' });
                res.end();
            }
        } else if(req.method == 'GET') {
            handler = this.findHandler(this.handlers_static[untyped 'GET'], this.handlers[untyped 'GET'], ctx);
            
            if(handler != null) {
                if(Cookies != null) {
                    ctx.cookies = new Cookies(req, res);
                }
                
                handler(ctx);
            } else if(next != null) {
                next();
            } else {
                this.handleError(404, req, res);
            }
        } else if(next != null) {
            next();
        } else {
            this.handleError(405, req, res);
        }
    }
    
    public function start(?port : Int, ?host : String) : Connect {
        Server.context = this;
        Data.adapter = this.database;
        
#if server
        if(this.client_prefix != null) {
            this.addHandler(this.client_prefix, null, Server.__clientHandler, 'GET', 'none', null, null);
        }
        
        if(this.remote_prefix != null && Server.__remoteHandlers != null) {
            for(handler in Server.__remoteHandlers) {
                this.addHandler(this.remote_prefix + handler.id, null, Server.__remoteHandler(handler), 'POST', 'none', null, null);
            }
        }
#end
        
        if(Connect != null) {
            var server = Connect.createServer().use(function(req, res, next) {
                this.handleRequest(req, res, next);
            });
            
            if(this.root != null) {
                server.use(Connect.staticFiles(this.root));
            }
            
#if debug
            try {
                server.use(untyped Node.require('mapstrace')());
            }
            catch(err : Dynamic) {
                trace("module 'mapstrace' not found/loaded. Install it or remove -debug");
            }
#end
            
            return server.listen(port, host);
        } else {
#if debug
            if(this.root != null) {
                trace("module 'connect' not found/loaded. 'root' is ignored");
            }
#end
            
            Node.http.createServer(function(req, res) {
                try {
                    this.handleRequest(req, res);
                }
                catch(err : Dynamic) {
                }
            }).listen(port, host);
        }
        
        return null;
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
    
#if server
    private static var __remoteHandlers : Array<ServerRemoteHandler>;
    private static var __clientScript : String;
    
    private static function __remoteHandler(handler : ServerRemoteHandler) : Context.ContextHandler {
        return function(ctx) {
            var args : String = ctx.query[untyped 'v'];
            
            // TODO: Quick proto
            saffron.Data.adapter().query(handler.query, (handler.args != null && args != null) ? [ untyped parseInt(args) ] : null, function(err, results) {
                ctx.response.writeHead(200, { "Content-Type": "application/json" });
                
                if(err != null) {
                    ctx.response.end(Environment.JSON.stringify({ error: err }));
                } else {
                    ctx.response.end(Environment.JSON.stringify({ results: results }));
                }
            });
        };
    }
    
    private static function __clientHandler(ctx : Context) : Void {
        if(Server.__clientScript == null) {
            try {
                Server.__clientScript = untyped require('fs').readFileSync(require.resolve(__filename + '.client'), 'utf-8');    
            }
            catch(e : Dynamic) {
            }
            
            if(Server.__clientScript == null) {
                Server.__clientScript = '';
            }
        }
        
        ctx.response.writeHead(200, { "Content-Type": "text/javascript" });
        ctx.response.end(Server.__clientScript);
    }
#end
    
#end
}

#else

typedef Server = Client;

#end