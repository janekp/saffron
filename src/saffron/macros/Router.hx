/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron.macros;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

import sys.FileSystem;
import sys.io.File;

using StringTools;

private typedef RemoteDataHandler = {
    var query : String;
    var arguments : String;
}

@:allow(saffron.Macros) @:allow(saffron.macros) class Router {
	static function generateHandlerRaw(self : String, orig : String, path : String, method : String, handler : String, auth : String, permission : String, action : String) {
        var hasId = (path.indexOf(':id') != -1) ? true : false;
        
        return self + ".express." + method + "(\"" + path + "\"" +
        	((auth != 'null' && auth != 'auth_never') ? ',' +
        		((permission != null) ?
        			"function(req, res, next) { req.permission = \"" + permission + "\"; " + self + '.' + auth + "(req, res, next); }" :
        			self + '.' + auth) : '')
        		+ ", function(req, res) {" +
        			((hasId) ?
        				"(new " + handler + "(req, res))." + action + "(req.params.id);" :
        				"(new " + handler + "(req, res))." + action + "();") +
        		"})";
    }
    
    static function generateHandler(eself : Expr, path : String, method : String, ehandler : Expr, eauth : Expr) : Expr {
		var auth = Helper.stringify(eauth);
        var permission = (auth == 'auth_required' || auth == 'auth_optional' || auth == 'auth_required_multipart') ? Helper.stringifyInnerExpr(eauth) : null;
        var handler = Helper.stringify(ehandler);
        var self = Helper.stringify(eself);
        var action, actions = null;
        var i, j, c, ch;
        var str = '';
        var type;
        
        if(handler.indexOf('.') != -1) {
            var cc = handler.split('.');
            var am = false;
            
            handler = '';
            
            for(c in cc) {
                if(!am) {
                    handler += c;
                    
                    if(c.charAt(0).toUpperCase() == c.charAt(0)) {
                        am = true;
                    } else {
                        handler += '.';
                    }
                } else if(action != null) {
                    action = '.' + c;
                } else {
                    action = c;
                }
            }
        }
        
        if(auth != 'auth_required' &&
           auth != 'auth_required_multipart' &&
           auth != 'auth_optional' &&
           auth != 'auth_never' &&
           auth != 'null') {
            Context.error(auth + ' is not supported', Context.currentPos());
        }
        
        type = Helper.typeToClass(Context.getType(handler));
        
        // addMetadata
        if(path == null || path == '*' || path == '/*') {
            path = '';
        }
        
        if((i = path.indexOf(':action{')) != -1 && (j = path.indexOf('}', i)) != -1) {
            actions = path.substring(i + 8, j).split(',');
            j += 1;
            
            if(action != null) {
                var a = false;
                
                for(action in actions) {
                    if(action == action) {
                        a = true;
                        break;
                    }
                }
                
                if(a) {
                    actions = new Array<String>();
                    actions.push(action);
                } else {
                    return Macros.generatePlaceholder();
                }
            }
        } else if((i = path.indexOf(':action')) != -1) {
            j = i + 7;
            
            actions = new Array<String>();
            
            if(action != null) {
                actions.push(action);
            } else {
                actions.push('index');
                
                for(action in Helper.getMethods(type, false)) {
                    if(action != 'render' && action != 'index') {
                        actions.push(action);
                    }
                }
            }
        } else if(action != null) {
            actions = new Array<String>();
            actions.push(action);
        }
        
        if(actions != null) {
            for(action in actions) {
                if(str.length > 0) {
                    str += ';';
                }
                
                if(!Helper.hasField(type, action)) {
                	Context.error(handler + ' has no public method "' + action + '"', Context.currentPos());
                }
                
                str += Router.generateHandlerRaw(self, action, (i != -1 && j != -1) ? ((action == 'index') ? path.substr(0, (i > 1 && path.charAt(i - 1) == '/') ? i - 1 : i) : path.substr(0, i) + action + path.substr(j)) : path, method, handler, auth, permission, action);
            }
        } else {
        	if(!Helper.hasField(type, 'index')) {
                Context.error(handler + ' has no public method "index"', Context.currentPos());
            }
            
            str = Router.generateHandlerRaw(self, action, path, method, handler, auth, permission, 'index');
        }
        
        return Context.parse('{' + str + ';}', Context.currentPos());
    }
}

#end
