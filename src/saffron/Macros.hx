/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if macro

typedef StdType = Type;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using StringTools;

private class _Macros {
    public static function typeToClass(t : Type) : ClassType {
        switch(t) {
            case TInst(ct, params):
                return ct.get();
            default:
        }
        
        return null;
    }
    
    public static function hasField(type : ClassType, s : String) : Bool {
        var field;
        
        if(type != null) {
            for(field in type.fields.get()) {
                if(field.name == s) {
                    return true;
                }
            }
        }
        
        return (type.superClass != null) ? _Macros.hasField(type.superClass.t.get(), s) : false;
    }
    
    public static function getMethods(type : ClassType, ip : Bool, ?r : Array<String>) : Array<String> {
        var field;
        
        if(r == null) {
            r = new Array<String>();
        }
        
        if(type != null) {
            for(field in type.fields.get()) {
                if((ip == true || field.isPublic == true) && StdType.enumEq(field.kind, FMethod(MethNormal))) {
                    r.push(field.name);
                }
            }
        }
        
        return (type.superClass != null) ? _Macros.getMethods(type.superClass.t.get(), ip, r) : r;
    }
    
    public static function generateHandler(ethis : String, orig : String, path : String, method : String, handler : String, auth : String, tmpl : String, action : String) {
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
        "}, \"" + method + "\", \"" + auth + "\", \"" +
            handler + ((orig == 'index') ? '' : "." + action) + ((id != '') ? ':id' : '') + "\", \"" + path_r + "\")";
    }
}

class Macros {
    public static function stringify(e : Expr) : String {
        switch(e.expr) {
            case EConst(c): {
                switch(c) {
                    case CIdent(d): return d;
                    case CInt(i): return Std.string(i);
                    case CString(s): return s;
                    default:
                }
            };
            case EField(c, f): {
                return Macros.stringify(c) + '.' + f;
            };
            default:
        }
        
        return null;
    }
    
    public static function generateHandler(ethis : Expr, path : String, method : String, handler : Expr, auth : Expr) : Expr {
        var _auth = Macros.stringify(auth);
        var _handler = Macros.stringify(handler);
        var _this = Macros.stringify(ethis);
        var action, actions = null;
        var _ctx = _handler;
        var _tmpl = '';
        var i, j, c, ch;
        var str = '';
        var type;
        
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
        
        type = _Macros.typeToClass(Context.getType(_handler));
        
        if(path == null || path == '*' || path == '/*') {
            path = '';
        }
        
        if((i = path.indexOf(':action{')) != -1 && (j = path.indexOf('}', i)) != -1) {
            actions = path.substring(i + 8, j).split(',');
        } else if((i = path.indexOf(':action')) != -1) {
            j = i + 7;
            
            actions = new Array<String>();
            actions.push('index');
            
            for(action in _Macros.getMethods(type, false)) {
                if(action != 'render' && action != 'index') {
                    actions.push(action);
                }
            }
        }
        
        if(actions != null) {
            for(action in actions) {
                if(str.length > 0) {
                    str += ';';
                }
                
                str += _Macros.generateHandler(_this, action, (action == 'index') ? path.substr(0, (i > 1 && path.charAt(i - 1) == '/') ? i - 1 : i) : path.substr(0, i) + action + path.substr(j), method, _handler, _auth, _tmpl + ((action != 'index') ? '.' + action : ''), (_Macros.hasField(type, action)) ? action : 'render');
            }
        } else {
            str = _Macros.generateHandler(_this, action, path, method, _handler, _auth, _tmpl, (_Macros.hasField(type, 'index')) ? 'index' : 'render');
        }
        
        return Context.parse('{' + str + ';}', Context.currentPos());
    }
    //haxe.SHA1.encode(q)
    public static function generateDatabaseQuery(q : String, p : Expr, fn : Expr) : Expr {
        var _q = { expr: EConst(CString(q)), pos: Context.currentPos() };
        
        if(switch(p.expr) { case EFunction(name, f): true; default: false; }) {
            fn = p;
            p = { expr: EConst(CIdent('null')), pos: Context.currentPos() };
        }
        
#if client
        //return macro saffron.Data.query($q, $p, $fn);
#elseif server
        
#else
        return macro saffron.Data.adapter().query($_q, $p, $fn);
#end
    }
    
    public static function generateDatabaseExec(q : String, p : Expr, fn : Expr) : Expr {
        return macro "";
    }
    
}

#end