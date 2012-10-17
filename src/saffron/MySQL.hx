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
            saffron.MySQL.poolAdapters = { };
            saffron.MySQL.createConnectionFromPool = function(options) {
                var key = '' + options.host + ':' + options.port + ':' + options.user + ':' + options.password + ':' + options.database;
                var adapter = saffron.MySQL.poolAdapters[key];
                
                if(adapter == null) {
                    var pOptions = {
                        name: 'mysql',
                        max: options.poolSize,
                        idleTimeoutMillis: 30000,
                        log: false,
                        create: function(fn) {
                            fn(saffron.MySQL.createConnection(options));
                        },
                        destroy: function(connection) {
                            
                        }
                    };
                    
                    adapter = {
                        pool: __js__("require('generic-pool').Pool(pOptions)"),
                        query: function(q, p, fn) {
                            adapter.pool.acquire(function(connection) {
                                connection.query(q, p, fn);
                            });
                        }
                    };
                    
                    saffron.MySQL.poolAdapters[key] = adapter;
                }
                
                return adapter;
            };
        }
        catch(e : Dynamic) {
        }
    }
}

#end
