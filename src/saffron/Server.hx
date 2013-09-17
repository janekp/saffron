/* Copyright (c) 2013 Janek Priimann */

package saffron;

#if !macro
import js.Node;
import saffron.Data;
import saffron.tools.Express;
import saffron.tools.Formidable;
import saffron.tools.RegExp;
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
	public var auth_pre : ExpressRequest -> ExpressResponse -> (Int -> Void) -> Void = null;
	public var database : Void -> DataAdapter = null;
	public var error : Dynamic -> ExpressRequest -> ExpressResponse -> (Int -> Void) -> Void = null;
	public var temp : String = null;
	
	public function new() {
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
		
		if(this.temp != null) {
			formidable.uploadDir = this.temp;
		}
		
		formidable.parse(req, function(err, fields, files) {
			if(fields != null) {
				untyped __js__("for(var field in fields) { req.body[field] = fields[field]; }");
			}
			
			if(files != null) {
				var cleanup = new Array<String>();
				var cleanup_func : Void -> Void;
				
				untyped __js__("for(var file in files) { req.files[file] = files[file].path; cleanup.push(files[file].path); }");
				cleanup_func = function() { this.removeFiles(cleanup); };
				
				res.on('error', cleanup_func);
				res.on('close', cleanup_func);
				res.on('finish', cleanup_func);
			}
			
			this.auth(req, res, next);
		});
	}
	
	public function auth_required_multipart(req : ExpressRequest, res : ExpressResponse, next : Int -> Void) : Void {
		if(req.is('multipart/form-data') && this.temp != null) {
			if(this.auth_pre != null) {
				this.auth_pre(req, res, function(err : Int) {
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
