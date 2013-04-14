/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron.macros;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

@:allow(saffron.Macros) class Adapter {
    static function generateDataQuery(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
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
        
        Router.addRemoteHandler(id, q, p);
#end
        
        return macro saffron.Data.adapter().query($_q, $p, $fn);
    }
    
    static function generateDataSubscribe(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
        return Macros.generatePlaceholder();
    }
    
    static function generateDataUnsubscribe(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
        return Macros.generatePlaceholder();
    }
    
    static function generateDataPush(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
        return Macros.generatePlaceholder();
    }
    
}

#end
