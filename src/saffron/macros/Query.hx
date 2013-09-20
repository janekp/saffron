/* Copyright (c) 2013 Janek Priimann */

package saffron.macros;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

import sys.FileSystem;
import sys.io.File;

using StringTools;

@:allow(saffron.Macros) class Query {
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
    
    public static function generateDataQuery(eq : ExprOf<String>, ep : ExprOf<Array<Dynamic>>, efn : Expr) : Expr {
    	var array = false;
    	var type = switch(efn.expr) {
            case EFunction(name, f):
            	if(f.args[1].type == null) {
            		'DataResult';
            	} else {
					switch(f.args[1].type) {
						case TPath(path):
							var _t = Helper.stringifyTypePath(path);
						
							if(_t == 'Array') {
								array = true;
								_t = switch(path.params[0]) {
									case TPType(ep):
										switch(ep) {
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
				}
            default:
            	null;
        };
        
    	if(type == 'DataResult' || type == 'saffron.DataResult') {
    		return macro saffron.Data.adapter().query($eq, $ep, ${efn});
    	}
    	
    	if(array == true) {
    		var earr : Expr = {
				expr : ENew({ name: 'Array', pack: [], params: [ TPType(TPath({ name: type, pack: [], params: [] })) ] }, []),
				pos: Context.currentPos()
			};
			
			return macro saffron.Data.adapter().query($eq, $ep, function(err : DataError, result : DataResult) {
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
    	
    	return macro saffron.Data.adapter().query($eq, $ep, function(err : DataError, result : DataResult) {
    		${efn}(err, (err == null && result != null && result.length == 1) ? new $type(result[0]) : null);
    	});
    }
}

#end
