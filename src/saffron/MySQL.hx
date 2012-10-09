/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if !client

import js.Node;
import saffron.Data;

typedef MySQLOptions = {
    var host : String;
    var port : Int;
    var user : String;
    var password : String;
    var database : String;
}

extern class MySQL {
    public static function createConnection(options : MySQLOptions) : DataAdapter;
    
    private static function __init__() : Void untyped {
        try {
            saffron.MySQL = Node.require("mysql");
        }
        catch(e : Dynamic) {
        }
    }
}

#end
