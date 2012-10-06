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
    
    @:macro public static function exec(q : String, p : Expr, ?fn : Expr) : Expr {
        return Macros.generateDatabaseExec(q, p, fn);
    }
    
    @:macro public static function query(q : String, p : Expr, ?fn : Expr) : Expr {
        return Macros.generateDatabaseQuery(q, p, fn);
    }
}
