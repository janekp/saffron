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

typedef MySQLPoolOptions = { > MySQLOptions,
    var poolSize : Int;
}

extern class MySQL {
    public static function createConnection(options : MySQLOptions) : DataAdapter;
    public static function createConnectionFromPool(options : MySQLPoolOptions) : DataAdapter;
    
    private static function __init__() : Void untyped {
        try {
            saffron.MySQL = Node.require("mysql");
            saffron.MySQL.reusablePools = { };
            saffron.MySQL.createConnectionFromPool = function(options) {
                var key = '' + options.host + ':' + options.port + ':' + options.user + ':' + options.password + ':' + options.database;
                var pool = saffron.MySQL.reusablePools[key];
                
                if(pool == null) {
                    pool = __js__("new require('mysql-pool').MySQLPool(options)");
                    saffron.MySQL.reusablePools[key] = pool;
                }
                
                return pool;
            };
        }
        catch(e : Dynamic) {
        }
    }
}

#end
