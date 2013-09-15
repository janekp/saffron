/* Copyright (c) 2013 Janek Priimann */

package saffron;

#if !macro
import js.Node;
import saffron.tools.Express;
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
	
	public function new() {
		this.express = new Express();
		this.express.disable('x-powered-by');
		this.express.param('id', function(req : ExpressRequest, res : ExpressResponse, next : ?Dynamic -> Void, id : String) {
			var regex = new RegExp('/^\\d+$/');
			
			if(regex.test(id)) {
				next();
			} else{
				next('route');
			}
		});
		this.express.use(Express.bodyParser());
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
		
		this.express.listen(port);
	}
	
	public function auth_required(req : ExpressRequest, res : ExpressResponse, next : Int -> Void) : Void {
		this.auth(req, res, next);
	}
	
	public function auth_optional(req : ExpressRequest, res : ExpressResponse, next : Int -> Void) : Void {
		this.auth(req, res, function(err : Int) { next(null); });
	}
#end
}
