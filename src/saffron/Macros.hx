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
