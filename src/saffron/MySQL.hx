/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if !client

import js.Node;
import saffron.Database;

extern class MySQL {
    public static function createConnection(options : DatabaseOptions) : DatabaseAdapter;
    
    private static function __init__() : Void untyped {
        try {
            saffron.MySQL = Node.require("mysql");
        }
        catch(e : Dynamic) {
        }
    }
}

#end
