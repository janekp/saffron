/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron;

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
    public static function query(q : String, ?p : Array<Dynamic>, fn : DataError -> DataResult -> Void) : Void {
        return Data.adapter().query(q, p, fn);
    }
    
    public static var adapter : Void -> DataAdapter;
}
