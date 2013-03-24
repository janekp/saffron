/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron;

#if !client

#if !macro
import js.Node;
import saffron.Multipart;
import saffron.Template;
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

    macro public function config(ethis : Expr, key : Expr, value : Expr) : Expr {
        var k = Macros.stringify(key);
        var s : Expr = {
            expr : EField(ethis, k), 
            pos : Context.currentPos()
        };
        
        return macro $s = $value;
    }
    
    macro public function get(ethis : Expr, action : String, handler : Expr, ?auth : Expr) : Expr {
        return Macros.generateHandler(ethis, action, 'GET', handler, auth);
    }
    
    macro public function post(ethis : Expr, action : String, handler : Expr, ?auth : Expr) : Expr {
        return Macros.generateHandler(ethis, action, 'POST', handler, auth);
    }
    
#if !macro
    public static var context : Server = null;
    
    public var auth : Context -> String -> (Dynamic -> Int -> Void) -> Void = null;
    public var error : Context -> Int -> Void = null;
    public var database : Void -> Data.DataAdapter = null;
    public var client_prefix : String = '/index.js';
    public var multipart : Context -> Bool = null;
    public var max_post_size : Int = 1024 * 16; // 16kib
    public var max_multipart_size : Int = 1024 * 1024 * 4; // 4 MB
    public var max_multipart_count : Int = 1; // 1 file
    public var strip_trailing_slash : Bool = true; // /hello/ -> /hello
    public var remote_prefix : String = '/r/';
    public var root : String = null;
    public var tmp : String = null;
    public var name : String = null;
    
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
    
    public function addError(status : Int, fn : Context -> Void) : Void {
        untyped this.errors[status] = fn;
    }
    
    public function addHandler(path : String, regex : String, handler : Context.ContextHandler, method : String, auth : String, permission : String, key : String, value : String) : Void {
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
                    this.auth(ctx, permission, function(token, err) {
                        ctx.token = token;
                        
                        if(token != null) {
                            handler(ctx);
                        } else {
                            this.handleError((err != null) ? err : 403, ctx);
                        }
                    });
                } else {
                    this.handleError(403, ctx);
                }
            };
        } else if(auth == 'auth_optional') {
            h = function(ctx) {
                if(this.auth != null) {
                    this.auth(ctx, permission, function(token, err) {
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
    
    private function removeFiles(files : Array<String>) : Void {
        for(file in files) {
            if(file != null) {
                Node.fs.unlink(file, function(err) { });
            }
        }
    }
    
    private function handleError(status : Int, ctx : Context) : Void {
        var handler : Context -> Int -> Void = untyped this.errors[status];
        
        if(handler == null) {
            handler = untyped this.error;
        }
        
        if(handler != null) {
            handler(ctx, status);
        } else {
            ctx.response.writeHead((status >= 100 && status < 600) ? status : 500, { 'Content-Type': 'text/html' });
            ctx.response.end();
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
        
        if(untyped __js__('saffron.Async')) {
            ctx.async = untyped __js__('new saffron.Async()');
        }
        
        if(req.method == 'POST') {
            var postData = '';
            
            handler = this.findHandler(this.handlers_static[untyped 'POST'], this.handlers[untyped 'POST'], ctx);
            
            if(handler != null) {
                if(Cookies != null) {
                    ctx.cookies = new Cookies(req, res);
                }
                
                // Multipart
                if(this.multipart != null &&
                    req.headers[untyped 'content-type'] != null &&
                    req.headers[untyped 'content-type'].indexOf('multipart') == 0 &&
                    this.multipart(ctx) == true) {
                    var multipart = new Multipart();
                    
                    if(this.tmp != null) {
                        multipart.uploadDir = tmp;
                    }
                    
                    multipart.parse(req, function(err, fields, files) {
                        ctx.fields = fields;
                        ctx.files = files;
                        
                        if(fields != null) {
                            untyped __js__("for(var field in fields) { ctx.query[field] = fields[field]; }");
                        }
                        
                        if(files != null) {
                            var cleanup = new Array<String>();
                            var cleanup_func : Void -> Void;
                            
                            untyped __js__("for(var file in files) { cleanup.push(files[file].path); }");
                            cleanup_func = function() { this.removeFiles(cleanup); };
                            
                            res.on('error', cleanup_func);
                            res.on('close', cleanup_func);
                            res.on('finish', cleanup_func);
                        }
                        
                        handler(ctx);
                    });
                // Normal urlencoded post
                } else {
                    req.on('data', function(data) {
                        postData += data;
                        
                        if(postData.length > this.max_post_size) {
                            res.writeHead(413);
                            res.end();
                            
#if debug
                            trace('POST data exceeds the max limit (must: ' + postData.length + ' <= ' + this.max_post_size + ')');
#end
                            
                            untyped req.destroy();
                        }
                    });
                    
                    req.on('end', function() {
                        var query = Node.queryString.parse(postData);
                        
                        untyped __js__("for(var key in query) { ctx.query[key] = query[key]; }");
                        
                        handler(ctx);
                    });
                }
            } else if(next != null) {
                next();
            } else {
                this.handleError(404, ctx);
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
                this.handleError(404, ctx);
            }
        } else if(next != null) {
            next();
        } else {
            this.handleError(405, ctx);
        }
    }
    
    public function start(?port : Int, ?host : String) : Connect {
        Server.context = this;
        Data.adapter = this.database;
        
        if(this.name != null) {
            if(Template != null) {
                Template.srcRoot = Template.srcRoot + this.name + '/';
            }
            
            if(this.root != null) {
                this.root = Node.path.join(this.root, this.name);
            }
        }
        
#if debug
        Node.process.on('uncaughtException', function(err) {
            Environment.crash(err, function() {
                Node.process.exit(1);
            });
        });
#end

#if server
        if(this.tmp != null) {
            this.tmp = Node.path.join(Node.__dirname, this.tmp);
            
            if(!Node.fs.existsSync(this.tmp)) {
                Node.fs.mkdir(this.tmp);
            }
        }
        
        if(this.client_prefix != null) {
            this.addHandler(this.client_prefix, null, Server.__clientScriptHandler, 'GET', 'none', null, null, null);
            
#if debug
            this.addHandler(this.client_prefix + '.map', null, Server.__clientScriptMapHandler, 'GET', 'none', null, null, null);
#end
        }
        
        if(this.remote_prefix != null && Server.__remoteHandlers != null) {
            for(handler in Server.__remoteHandlers) {
                this.addHandler(this.remote_prefix + handler.id, null, Server.__remoteHandler(handler), 'POST', 'none', null, null, null);
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
                this.handleRequest(req, res);
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
    private static var __clientLibraries : Array<String>;
    
    public static function __generateClientScript(chunk : TemplateChunk, ctx : TemplateContext) : TemplateChunk {
        return chunk.write('<script type="text/javascript" src="' + Server.context.client_prefix + '"></script>');
    }
    
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
    
    private static function __clientScriptHandler(ctx : Context) : Void {
        if(Server.__clientScript == null) {
            try {
                Server.__clientScript = untyped require('fs').readFileSync(require.resolve(__filename + '.client'), 'utf-8');    
            }
            catch(e : Dynamic) {
            }
            
            if(Server.__clientScript == null) {
                Server.__clientScript = '';
            }
            
#if debug
            Server.__clientScript = untyped Server.__clientScript.replace('sourceMappingURL=index.js.client.map', 'sourceMappingURL=index.js.map');
#end
        }
                
        if(Server.__clientLibraries == null) {
            Server.__clientLibraries = new Array<String>();
            
            try {
                var files = Node.fs.readdirSync('client_libraries');
                
                for(file in files) {
                    if(untyped file.indexOf('.js', file.length - 3) != -1) {
                        Server.__clientLibraries.push(Node.fs.readFileSync('client_libraries/' + file, 'UTF-8'));
                    }
                }
            }
            catch(e : Dynamic) {
            }
        }
        
        ctx.response.writeHead(200, { "Content-Type": "text/javascript" });
        ctx.response.write(Server.__clientScript);
        
        for(clientLibrary in Server.__clientLibraries) {
            ctx.response.write('\n');
            ctx.response.write(clientLibrary);
        }
        
        if(Template.templates != null) {
            ctx.response.write('\n__saffron.templates = {');
            untyped __js__("for(var key in saffron.Template.templates) { ctx.response.write('\"' + key + '\": ' + JSON.stringify(saffron.Template.templates[key]) + ','); }\n");
            ctx.response.write('};');
        }
        
        ctx.response.end('\ndust.onLoad = __saffron.onLoad;\ndust.ready = true;');
    }
#end
    
#if debug
    private static var __clientScriptMap : String;
    
    private static function __clientScriptMapHandler(ctx : Context) : Void {
        if(Server.__clientScriptMap == null) {
            try {
                Server.__clientScriptMap = untyped require('fs').readFileSync(require.resolve(__filename + '.client.map'), 'utf-8');    
            }
            catch(e : Dynamic) {
            }
            
            if(Server.__clientScriptMap == null) {
                Server.__clientScriptMap = '';
            }
            
            Server.__clientScriptMap = untyped Server.__clientScriptMap.replace('"index.js.client"', '"index.js"');
        }
        
        ctx.response.writeHead(200, { "Content-Type": "application/json" });
        ctx.response.end(Server.__clientScriptMap);
    }
#end
    
#end
}

#else

typedef Server = Client;

#end