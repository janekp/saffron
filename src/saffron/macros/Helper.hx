/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron.macros;

#if macro

import haxe.macro.Expr;

typedef MacroType = haxe.macro.Type;
typedef ClassType = haxe.macro.Type.ClassType;

@:allow(saffron.Macros) @:allow(saffron.macros) class Helper {
    static function stringify(e : Expr) : String {
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
                return Helper.stringify(c) + '.' + f;
            };
            case ECall(c, _params): {
                return Helper.stringify(c);
            };
            default:
        }
        
        return null;
    }
    
    static function stringifyTypePath(t : TypePath) : String {
    	return (t.pack.length > 0) ? t.pack.join('.') + '.' + t.name : t.name;
    }
    
    static function stringifyInnerExpr(e : Expr) : String {
        switch(e.expr) {
            case ECall(_n, params): {
                return Helper.stringify(params[0]);
            };
            default:
        }
        
        return null;
    }
    
    static function contains(array : Array<Dynamic>, obj : Dynamic) : Bool {
        for(item in array) {
            if(item == obj) {
                return true;
            }
        }
        
        return false;
    }
    
    static function containsMeta(field : Field, name : String) : String {
        for(meta in field.meta) {
            if(meta.name == name) {
                return (meta.params.length > 0) ? Helper.stringify(meta.params[0]) : '';
            }
        }
        
        return null;
    }
    
    static function typeToClass(t : MacroType) : ClassType {
        switch(t) {
            case TInst(ct, _params):
                return ct.get();
            default:
        }
        
        return null;
    }
    
    static function hasField(type : ClassType, s : String) : Bool {
        var field;
        
        if(type != null) {
            for(field in type.fields.get()) {
                if(field.name == s) {
                    return true;
                }
            }
        }
        
        return (type.superClass != null) ? Helper.hasField(type.superClass.t.get(), s) : false;
    }
    
    static function getMethods(type : ClassType, ip : Bool, ?r : Array<String>) : Array<String> {
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
        
        return (type.superClass != null) ? Helper.getMethods(type.superClass.t.get(), ip, r) : r;
    }
}

#end
