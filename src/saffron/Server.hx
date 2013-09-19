/* Copyright (c) 2013 Janek Priimann */

package saffron;

#if !macro
import js.Node;
import saffron.Data;
import saffron.tools.Express;
import saffron.tools.Formidable;
import saffron.tools.RegExp;

using StringTools;
#else
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class Server {
	macro public function config(ethis : Expr, key : Expr, value : Expr) : Expr {
		return Macros.generateSetter(ethis, key, value);
    }
    
    macro public function get(ethis : Expr, action : String, handler : Expr, ?auth : Expr) : Expr {
        return Macros.generateHandler(ethis, action, 'get', handler, auth);
    }
    
    macro public function post(ethis : Expr, action : String, handler : Expr, ?auth : Expr) : Expr {
        return Macros.generateHandler(ethis, action, 'post', handler, auth);
    }
    
#if !macro
    public var express : Express;
	public var auth : ExpressRequest -> ExpressResponse -> (Int -> Void) -> Void = null;
	public var auth_multipart : ExpressRequest -> ExpressResponse -> (Int -> Void) -> Void = null;
	public var database : Void -> DataAdapter = null;
	public var error : Dynamic -> ExpressRequest -> ExpressResponse -> (Int -> Void) -> Void = null;
	public var file_root : String = null;
	public var temp_root : String = null;
	
	public function new() {
#if !debug
		if(Node.process.env.NODE_ENV == null) {
			Node.process.env.NODE_ENV = 'production';
		}
#end
		this.express = new Express();
		this.express.disable('x-powered-by');
		this.express.param('id', function(req : ExpressRequest, res : ExpressResponse, next : ?Dynamic -> Void, id : String) {
			var regex = new RegExp('^\\d+$');
			
			if(regex.test(id)) {
				next();
			} else{
				next('route');
			}
		});
		this.express.use(Express.json());
		this.express.use(Express.urlencoded());
	}
	
	public function start(port : Int) {
#if debug
        js.Node.process.on('uncaughtException', function(err) {
        	try {
				var mapstrace = js.Node.require('mapstrace');
			
				untyped mapstrace.build(err, true, function(result) {
					trace('\n' + untyped __js__('err.toString()') + ':\n' + mapstrace.stringify(result));
					js.Node.process.exit(1);
				});
			}
			catch(e : Dynamic) {
				trace("module 'mapstrace' not found/loaded. Install it or remove -debug");
				js.Node.process.exit(1);
			}
        });
#end
		
		if(this.database != null) {
			Data.adapter = this.database;
		}
		
		if(this.error != null) {
			this.express.use(this.express.router);
			this.express.use(this.error);
		}
		
		if(this.temp_root != null) {
			if(!this.temp_root.startsWith('/')) {
				this.temp_root = Node.__dirname + '/' + this.temp_root;
			}
		}
		
		if(this.file_root != null) {
			if(!this.file_root.startsWith('/')) {
				this.file_root = Node.__dirname + '/' + this.file_root;
			}
			
			this.express.use(Express.Static(this.file_root));
		}
		
		this.express.listen(port);
	}
	
	private function removeFiles(files : Array<String>) : Void {
        for(file in files) {
            if(file != null) {
                Node.fs.unlink(file, function(err) { });
            }
        }
    }
    
	public function auth_required(req : ExpressRequest, res : ExpressResponse, next : Int -> Void) : Void {
		this.auth(req, res, next);
	}
	
	private function auth_required_multipart_(req : ExpressRequest, res : ExpressResponse, next : Int -> Void) : Void {
		var formidable = new Formidable();
		var cleanup = new Array<String>();
		var cleanup_func : Void -> Void = function() { this.removeFiles(cleanup); };
		
		if(this.temp_root != null) {
			formidable.uploadDir = this.temp_root;
		}
		
		if(req.files == null) {
			req.files = { };
		}
			
		formidable.on('file', function(name, file) {
			cleanup.push(file.path);
			
			if(req.files[name] == null) {
				req.files[name] = [ file ];
			} else {
				req.files[name].push(file);
			}
		});
		
		res.on('error', cleanup_func);
		res.on('close', cleanup_func);
		res.on('finish', cleanup_func);
		
		formidable.parse(req, function(err, fields, files) {
			if(fields != null) {
				untyped __js__("for(var field in fields) { req.body[field] = fields[field]; }");
			}
						
			if(this.auth_multipart == null) {
				this.auth(req, res, next);
			} else if(err == null) {
				next(null);
			} else {
				next(500);
			}
		});
	}
	
	public function auth_required_multipart(req : ExpressRequest, res : ExpressResponse, next : Int -> Void) : Void {
		if(req.is('multipart/form-data')) {
			if(this.auth_multipart != null) {
				this.auth_multipart(req, res, function(err : Int) {
					if(err == null) {
						this.auth_required_multipart_(req, res, next);
					} else {
						next(err);
					}
				});
			} else {
				this.auth_required_multipart_(req, res, next);
			}
		} else {
			next(403);
		}
	}
	
	public function auth_optional(req : ExpressRequest, res : ExpressResponse, next : Int -> Void) : Void {
		this.auth(req, res, function(err : Int) { next(null); });
	}
#end
}
