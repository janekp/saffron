/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if macro

import haxe.macro.Expr;

#end

typedef DataIdentifier = Int;

typedef DataError = {
    var code : String;
    var fatal : Bool;
}

typedef DataResult = {
    var insertId : DataIdentifier;
}

typedef DataAdapter = {
    function exec(q : String, ?p : Array<Dynamic>, fn : DataError -> DataResult -> Void) : Void;
    function query(q : String, ?p : Array<Dynamic>, fn : DataError -> Array<Dynamic> -> Void) : Void;
}

class Data {
    public static var adapter : Void -> DataAdapter = null;
    
    @:macro public static function exec(ctx : Expr, q : String, p : Expr, ?fn : Expr) : Expr {
        return Macros.generateDataExec(ctx, q, p, fn);
    }
    
    @:macro public static function query(ctx : Expr, q : String, p : Expr, ?fn : Expr) : Expr {
        return Macros.generateDataQuery(ctx, q, p, fn);
    }
    
#if server
    @:macro private static function clearRemoteHandlers() : Expr {
        return Macros.clearRemoteHandlers();
    }
    
#if !macro
    private static function __init__() : Void untyped {
        Data.clearRemoteHandlers();
        
        try {
            var path = require.resolve(__filename + '.calls');
            saffron.Server.__remoteHandlers = require('vm').runInThisContext('[' + require('fs').readFileSync(path, 'utf-8') + ']', path);
        }
        catch(e : Dynamic) {
        }
    }
#end

#end
}
