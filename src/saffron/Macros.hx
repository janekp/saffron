/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

import saffron.macros.*;

class Macros {
    public static function stringify(e : Expr) : String {
        return Helper.stringify(e);
    }
    
	public static function generateDataFetch(etype : Expr, efn : Expr, eerr : Expr, eresult : Expr) : Expr {
		var type = Helper.stringify(etype);
		
		return macro ${efn}(${eerr}, (${eerr} == null && ${eresult} != null && ${eresult}.length == 1) ? new $type(${eresult}[0]) : null);
	}
    
    public static function generateDataFetchAll(etype : Expr, efn : Expr, eerr : Expr, eresult : Expr) : Expr {
		var type = Helper.stringify(etype);
		var earr : Expr = {
			expr : ENew({ name: 'Array', pack: [], params: [ TPType(TPath({ name: type, pack: [], params: [] })) ] }, []),
			pos: Context.currentPos()
		};
		
		return macro if(${eerr} == null && ${eresult} != null) {
            var data = $earr;
            
            for(row in ${eresult}.rows()) {
                data.push(new $type(row));
            }
            
            ${efn}(null, data);
        } else {
            ${efn}(${eerr}, null);
        };
    }
    
    public static function generateDataQuery(q : String, p : Array<Dynamic>, efn : Expr) : Expr {
    	var array = false;
    	var type = switch(efn.expr) {
            case EFunction(name, f):
            	switch(f.args[1].type) {
            		case TPath(path):
            			var _t = Helper.stringifyTypePath(path);
            			
            			if(_t == 'Array') {
            				array = true;
            				_t = switch(path.params[0]) {
            					case TPType(p):
            						switch(p) {
            							case TPath(_path):
            								Helper.stringifyTypePath(_path);
            							default:
            								null;
            						}
            					default:
            						null;
            				};
            			}
            			
            			_t;
            		default:
            			null;
            	}
            default:
            	null;
        };
        
    	if(type == 'DataResult' || type == 'saffron.DataResult') {
    		return macro saffron.Data.adapter().query($v{q}, $v{p}, ${efn});
    	}
    	
    	if(array == true) {
    		var earr : Expr = {
				expr : ENew({ name: 'Array', pack: [], params: [ TPType(TPath({ name: type, pack: [], params: [] })) ] }, []),
				pos: Context.currentPos()
			};
		
			return macro saffron.Data.adapter().query($v{q}, $v{p}, function(err : DataError, result : DataResult) {
				var fn = ${efn};
				
				if(err == null && result != null) {
					var data = $earr;
					
					for(row in result.rows()) {
						data.push(new $type(row));
					}
					
					fn(null, data);
				} else {
					fn(err, null);
				};
			});
    	}
    	
    	return macro saffron.Data.adapter().query($v{q}, $v{p}, function(err : DataError, result : DataResult) {
    		${efn}(err, (err == null && result != null && result.length == 1) ? new $type(result[0]) : null);
    	});
    }
    
    public static function generateSetter(ethis : Expr, key : Expr, value : Expr) : Expr {	
        var k = Macros.stringify(key);
        var s : Expr = {
            expr : EField(ethis, k), 
            pos : Context.currentPos()
        };
        
        return macro $s = $value;
    }
    
    public static function generateAsync(ethis : Expr, fn : Expr, parallel : Bool, nextTick : Bool) : Expr {
        if(parallel || nextTick) {
            var _p = { expr: EConst(CIdent((parallel) ? 'true' : 'false')), pos: Context.currentPos() };
            var _n = { expr: EConst(CIdent((nextTick) ? 'true' : 'false')), pos: Context.currentPos() };
            
            return macro saffron.Async.AsyncContext.context($ethis)._async($fn, $_p, $_n);
        }
        
        return macro saffron.Async.AsyncContext.context($ethis)._async($fn);
    }
    
    public static function generateHandler(ethis : Expr, path : String, method : String, handler : Expr, auth : Expr) : Expr {
        return Router.generateHandler(ethis, path, method, handler, auth);
    }
    
    public static function generatePlaceholder() : Expr {
#if neko
        return macro untyped '';
#else
        return macro untyped __js__('');
#end
    }
}

#end
