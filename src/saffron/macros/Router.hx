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
    private static var remoteDataHandlers : Map<String, Bool> = null;
    
    static function generateHandlerRaw(ethis : String, orig : String, path : String, method : String, handler : String, auth : String, perm : String, tmpl : String, action : String) {
        var i = path.indexOf(':id');
        var j = path.indexOf('*');
        var path_r = path;
        var regex = 'null';
        var idreg = '^\\/';
        var id = '', c;
        
        // Convert to regex?
        if(i != -1 || j != -1) {
            if(i != -1 && path.indexOf(':id{') == i) {
                c = path.indexOf('}', i);
                
                if(c == -1) {
                    c = path.length;
                }
                
                idreg = path.substr(i + 4, c - i - 4);
                path = path.substr(0, i + 3) + path.substr(c + 1);
                path_r = path;
            }
            
            regex = '"^' + path.replace('.', "\\.").replace('+', "\\+").replace('?', "\\?").replace('|', "\\|").replace(':id', "([" + idreg + "]+)").replace('*', '.*') + '$"';
            path = null;
        }
        
        if(i != -1 && action != 'render') {
            id = (idreg == '0-9') ? 'untyped __js__("(!isNaN(parseInt(ctx.id, 10))) ? parseInt(ctx.id, 10) : 0")' : 'ctx.id';
        }
        
        return ethis + ".addHandler(" + ((path != null) ? "\"" + path + "\"" : 'null') + ", " + regex + ", function(ctx) {" +
#if !client
            "ctx.template = \"" + tmpl + "\";" +
            "(new " + handler + "(ctx))." + action + "(" + id + ");" +
#else
            "var __obj = new " + handler + "(ctx);" +
            "if(ctx.template == null) { ctx.template = \"" + tmpl + "\"; __obj." + action + "(" + id + "); }" +
#end
        "}, \"" + method + "\", \"" + auth + "\", " + ((perm != null) ? "\"" + perm + "\"" : 'null') + ", \"" +
            handler + ((orig == 'index') ? '' : "." + action) + ((id != '') ? ':id' : '') + "\", \"" + path_r + "\")";
    }
    
    static function generateHandler(ethis : Expr, path : String, method : String, handler : Expr, auth : Expr) : Expr {
        var _auth = Helper.stringify(auth);
        var _perm = (_auth == 'auth_required' || _auth == 'auth_optional') ? Helper.stringifyInnerExpr(auth) : null;
        var _handler = Helper.stringify(handler);
        var _this = Helper.stringify(ethis);
        var action, actions = null;
        var _ctx = _handler;
        var _tmpl = '';
        var i, j, c, ch;
        var str = '';
        var type;
        
        if(_handler.indexOf('.') != -1) {
            var cc = _handler.split('.');
            var am = false;
            
            _handler = '';
            
            for(c in cc) {
                if(!am) {
                    _handler += c;
                    
                    if(c.charAt(0).toUpperCase() == c.charAt(0)) {
                        am = true;
                    } else {
                        _handler += '.';
                    }
                } else if(action != null) {
                    action = '.' + c;
                } else {
                    action = c;
                }
            }
            
            _ctx = _handler;
        }
        
        if(_ctx.endsWith('Page')) {
            _ctx = _ctx.substr(0, _ctx.length - 4);
        } else if(_ctx.endsWith('Handler')) {
            _ctx = _ctx.substr(0, _ctx.length - 7);
        } else if(_ctx.endsWith('Controller')) {
            _ctx = _ctx.substr(0, _ctx.length - 10);
        }
        
        for(i in 0..._ctx.length) {
            ch = _ctx.charCodeAt(i);
            
            if(ch >= 65 && ch <= 90) {
                if(_tmpl != '') {
                    _tmpl += '/';
                }
                
                _tmpl += _ctx.charAt(i).toLowerCase();
            } else {
                _tmpl += _ctx.charAt(i);
            }
        }
        
        if(_auth != 'auth_required' &&
           _auth != 'auth_optional' &&
           _auth != 'auth_never' &&
           _auth != 'null') {
            Context.error(_auth + ' is not supported', Context.currentPos());
        }
        
        type = Helper.typeToClass(Context.getType(_handler));
        
        // addMetadata
        if(path == null || path == '*' || path == '/*') {
            path = '';
        }
        
        if((i = path.indexOf(':action{')) != -1 && (j = path.indexOf('}', i)) != -1) {
            actions = path.substring(i + 8, j).split(',');
            j += 1;
            
            if(action != null) {
                var _a = false;
                
                for(_action in actions) {
                    if(_action == action) {
                        _a = true;
                        break;
                    }
                }
                
                if(_a) {
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
                
                str += Router.generateHandlerRaw(_this, action, (i != -1 && j != -1) ? ((action == 'index') ? path.substr(0, (i > 1 && path.charAt(i - 1) == '/') ? i - 1 : i) : path.substr(0, i) + action + path.substr(j)) : path, method, _handler, _auth, _perm, _tmpl + ((action != 'index') ? '.' + action : ''), (Helper.hasField(type, action)) ? action : 'render');
            }
        } else {
            str = Router.generateHandlerRaw(_this, action, path, method, _handler, _auth, _perm, _tmpl, (Helper.hasField(type, 'index')) ? 'index' : 'render');
        }
        
        return Context.parse('{' + str + ';}', Context.currentPos());
    }
    
    
    static function addRemoteHandler(id : String, q : String, p : Expr) : Expr {
        var file = Compiler.getOutput() + '.calls';
        var fout = (Router.remoteDataHandlers == null) ? File.write(file, false) : File.append(file, false);
        
        if(Router.remoteDataHandlers == null) {
            Router.remoteDataHandlers = new Map<String, Bool>();
        }
        
        if(!Router.remoteDataHandlers.get(id)) {
            var a = null;
            
            if(switch(p.expr) { case EConst(_c): false; default: true; }) {
                // TODO: Temporary
                a = 'I';
            }
            
            fout.writeString('{ id: "' + id + '", query: "' + q + '", args: ' + ((a != null) ? '"' + a + '"' : 'null') + ' },\n');
            fout.close();
            
            Router.remoteDataHandlers.set(id, true);
        }
        
        return Macros.generatePlaceholder();
    }
    
    static function clearRemoteHandlers() : Expr {
        var file = Compiler.getOutput() + '.calls';
        
        if(FileSystem.exists(file)) {
            FileSystem.deleteFile(file);
        }
        
        Router.remoteDataHandlers = null;
        
        return Macros.generatePlaceholder();
    }
}

#end
