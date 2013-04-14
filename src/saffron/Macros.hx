/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

import saffron.macros.*;

class Macros {
    public static function buildPage() : Array<Field> {
        return Builder.generatePage();
    }
    
    public static function clearRemoteHandlers() : Expr {
        return Router.clearRemoteHandlers();
    }
    
    public static function stringify(e : Expr) : String {
        return Helper.stringify(e);
    }
    
    public static function generateAsync(ethis : Expr, fn : Expr, parallel : Bool, nextTick : Bool) : Expr {
        if(parallel || nextTick) {
            var _p = { expr: EConst(CIdent((parallel) ? 'true' : 'false')), pos: Context.currentPos() };
            var _n = { expr: EConst(CIdent((nextTick) ? 'true' : 'false')), pos: Context.currentPos() };
            
            return macro saffron.Async.AsyncContext.context($ethis._ctx).async($fn, $_p, $_n);
        }
        
        return macro saffron.Async.AsyncContext.context($ethis._ctx).async($fn);
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
    
    public static function generateDataQuery(ctx : Expr, q : Expr, p : Expr, fn : Expr) : Expr {
        return Adapter.generateDataQuery(ctx, q, p, fn);
    }
    
    public static function generateDataSubscribe(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
        return Adapter.generateDataSubscribe(ctx, q, p, fn);
    }
    
    public static function generateDataUnsubscribe(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
        return Adapter.generateDataUnsubscribe(ctx, q, p, fn);
    }
    
    public static function generateDataPush(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
        return Adapter.generateDataPush(ctx, q, p, fn);
    }
}

#end
