/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if !client

import js.Node;

typedef DatabaseIdentifier = Int;

typedef DatabaseError = {
    var code : String;
    var fatal : Bool;
}

typedef DatabaseAdapter = {
    function exec(q : String, ?p : Array<Dynamic>, fn : DatabaseError -> DatabaseResult -> Void) : Void;
    function query(q : String, ?p : Array<Dynamic>, fn : DatabaseError -> Array<Dynamic> -> Void) : Void;   
}

typedef DatabaseResult = {
    var insertId : DatabaseIdentifier;
}

typedef DatabaseOptions = {
    var host : String;
    var port : Int;
    var user : String;
    var password : String;
}

#end
