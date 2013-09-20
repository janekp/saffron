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
    
    macro public static function query(eq : ExprOf<String>, ep : ExprOf<Array<Dynamic>>, ?efn : Expr) : Expr {
    	if(Macros.stringify(efn) == 'null') {
    		var tmp = efn;
    		
    		efn = ep;
    		ep = tmp;
    	}
    	
    	return Macros.generateDataQuery(eq, ep, efn);
    }
    
    public static inline function params(p : Array<Dynamic>) : Array<Dynamic> {
    	return p;
    }
    
    public static inline function queryRaw(q : String, ?p : Array<Dynamic>, fn : DataError -> DataResult -> Void) : Void {
        return Data.adapter().query(q, p, fn);
    }
    
    public static var adapter : Void -> DataAdapter;
}
