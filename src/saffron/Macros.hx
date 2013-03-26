/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if macro

import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef MacroType = haxe.macro.Type;
typedef ClassType = haxe.macro.Type.ClassType;

private class _Macros {
    public static function typeToClass(t : MacroType) : ClassType {
        switch(t) {
            case TInst(ct, _params):
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
                if((ip == true || field.isPublic == true) && Type.enumEq(field.kind, FMethod(MethNormal))) {
                    r.push(field.name);
                }
            }
        }
        
        return (type.superClass != null) ? _Macros.getMethods(type.superClass.t.get(), ip, r) : r;
    }
    
    public static function generateHandler(ethis : String, orig : String, path : String, method : String, handler : String, auth : String, perm : String, tmpl : String, action : String) {
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
            case ECall(c, _params): {
                return Macros.stringify(c);
            };
            default:
        }
        
        return null;
    }
    
    public static function stringifyInnerExpr(e : Expr) : String {
        switch(e.expr) {
            case ECall(_n, params): {
                return Macros.stringify(params[0]);
            };
            default:
        }
        
        return null;
    }
    
    public static function generatePlaceholder() : Expr {
#if neko
        return macro untyped '';
#else
        return macro untyped __js__('');
#end
    }
    
    private static function contains(array : Array<Dynamic>, obj : Dynamic) : Bool {
        for(item in array) {
            if(item == obj) {
                return true;
            }
        }
        
        return false;
    }
    
    private static function containsMeta(field : Field, name : String) : String {
        for(meta in field.meta) {
            if(meta.name == name) {
                return (meta.params.length > 0) ? stringify(meta.params[0]) : '';
            }
        }
        
        return null;
    }
    
    public static function buildPage() : Array<Field> {
        var type = Context.getLocalClass().get();
        var fields = Context.getBuildFields();
        var autogen = new Array<Field>();
        var render;
        
        for(field in fields) {
            if(!contains(field.access, Access.AStatic)) {
                if((render = containsMeta(field, ':render')) != null) {
                    var _name = field.name;
                    var expr = macro function(chunk : saffron.Template.TemplateChunk) : saffron.Template.TemplateChunk {
                        var widget : saffron.Widget = this.$_name();
                        return (widget != null) ? widget.render(chunk) : chunk;
                    };
                    var func : Function = switch(expr.expr) {
                        case EFunction(_name, f):
                            f;
                        default:
                            null;
                    };
                    
                    autogen.push({
                        name: (render.length > 0) ? render : 'render' + field.name.charAt(0).toUpperCase() + field.name.substring(1),
                        pos: field.pos,
                        meta: [ { name: ':keep', pos: field.pos, params: new Array<Expr>() } ],
                        access: [ Access.APrivate ],
                        doc: null,
                        kind: FieldType.FFun(func)
                    });
                }
            }
        }
        
        return fields.concat(autogen);
    }
    
    public static function generateHandler(ethis : Expr, path : String, method : String, handler : Expr, auth : Expr) : Expr {
        var _auth = Macros.stringify(auth);
        var _perm = (_auth == 'auth_required' || _auth == 'auth_optional') ? Macros.stringifyInnerExpr(auth) : null;
        var _handler = Macros.stringify(handler);
        var _this = Macros.stringify(ethis);
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
        
        type = _Macros.typeToClass(Context.getType(_handler));
        
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
                
                for(action in _Macros.getMethods(type, false)) {
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
                
                str += _Macros.generateHandler(_this, action, (i != -1 && j != -1) ? ((action == 'index') ? path.substr(0, (i > 1 && path.charAt(i - 1) == '/') ? i - 1 : i) : path.substr(0, i) + action + path.substr(j)) : path, method, _handler, _auth, _perm, _tmpl + ((action != 'index') ? '.' + action : ''), (_Macros.hasField(type, action)) ? action : 'render');
            }
        } else {
            str = _Macros.generateHandler(_this, action, path, method, _handler, _auth, _perm, _tmpl, (_Macros.hasField(type, 'index')) ? 'index' : 'render');
        }
        
        return Context.parse('{' + str + ';}', Context.currentPos());
    }
    
    public static function generateAsync(ethis : Expr, fn : Expr, parallel : Bool, nextTick : Bool) : Expr {
        if(parallel || nextTick) {
            var _p = { expr: EConst(CIdent((parallel) ? 'true' : 'false')), pos: Context.currentPos() };
            var _n = { expr: EConst(CIdent((nextTick) ? 'true' : 'false')), pos: Context.currentPos() };
            
            return macro saffron.Async.AsyncContext.context($ethis._ctx).async($fn, $_p, $_n);
        }
        
        return macro saffron.Async.AsyncContext.context($ethis._ctx).async($fn);
    }
    
    private static var remoteDataHandlers : Map<String, Bool> = null;
    
    public static function generateDataQuery(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
#if client
        var _q = { expr: EConst(CString(haxe.crypto.Sha1.encode(q))), pos: Context.currentPos() };
#else
        var _q = { expr: EConst(CString(q)), pos: Context.currentPos() };
#end
        
        if(switch(p.expr) { case EFunction(_name, _f): true; default: false; }) {
            fn = p;
            p = { expr: EConst(CIdent('null')), pos: Context.currentPos() };
        }
        
#if server
        var id = haxe.crypto.Sha1.encode(q);
        var file = Compiler.getOutput() + '.calls';
        var fout = (Macros.remoteDataHandlers == null) ? File.write(file, false) : File.append(file, false);
        
        if(Macros.remoteDataHandlers == null) {
            Macros.remoteDataHandlers = new Map<String, Bool>();
        }
        
        if(!Macros.remoteDataHandlers.get(id)) {
            var a = null;
            
            if(switch(p.expr) { case EConst(_c): false; default: true; }) {
                // TODO: Temporary
                a = 'I';
            }
            
            fout.writeString('{ id: "' + id + '", query: "' + q + '", args: ' + ((a != null) ? '"' + a + '"' : 'null') + ' },\n');
            fout.close();
            
            Macros.remoteDataHandlers.set(id, true);
        }
#end
        
        return macro saffron.Data.adapter().query($_q, $p, $fn);
    }
    
    public static function generateDataSubscribe(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
        return macro "";
    }
    
    public static function generateDataUnsubscribe(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
        return macro "";
    }
    
    public static function generateDataPush(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
        return macro "";
    }
    
    public static function clearRemoteHandlers() : Expr {
        var file = Compiler.getOutput() + '.calls';
        
        if(FileSystem.exists(file)) {
            FileSystem.deleteFile(file);
        }
        
        Macros.remoteDataHandlers = null;
        
        return Macros.generatePlaceholder();
    }
}

private typedef RemoteDataHandler = {
    var query : String;
    var arguments : String;
}

#end
