/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

typedef DataIdentifier = Int;

typedef DataError = {
    var code : String;
    var fatal : Bool;
}

@:native('Array') extern class DataResult implements ArrayAccess<Dynamic> {
    var insertId : DataIdentifier;
    var length : Int;
    
    public function new() : Void;
    public function push(item : Dynamic) : Void;
    
    public inline function row(index : Int) : Dynamic {
        return untyped this[index];
    }
    
    public inline function rows() : Array<Dynamic> {
        return untyped this;
    }
}

typedef DataAdapter = {
    function query(q : String, ?p : Array<Dynamic>, fn : DataError -> DataResult -> Void) : Void;
}

class Data {
	macro public static function fetch(etype : Expr, efn : Expr, eerr : Expr, eresult : Expr) : Expr {
		return Macros.generateDataFetch(etype, efn, eerr, eresult);
    }
    
    macro public static function fetchAll(etype : Expr, efn : Expr, eerr : Expr, eresult : Expr) : Expr {
		return Macros.generateDataFetchAll(etype, efn, eerr, eresult);
    }
    
    macro public static function query(q : String, ?p : Array<Dynamic>, efn : Expr) : Expr {
    	return Macros.generateDataQuery(q, p, efn);
    }
    
    public static inline function queryRaw(q : String, ?p : Array<Dynamic>, fn : DataError -> DataResult -> Void) : Void {
        return Data.adapter().query(q, p, fn);
    }
    
    public static var adapter : Void -> DataAdapter;
}
