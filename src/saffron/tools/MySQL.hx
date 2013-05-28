/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron.tools;

#if !client

import saffron.Data;
import saffron.Environment;
import saffron.tools.Node;

typedef MySQLOptions = {
    ?host : String,
    ?port : Int,
    ?socketPath : String,
    ?user : String,
    ?password : String,
    ?database : String,
    ?charset : String,
    ?debug : Bool,
    ?insecureAuth : Bool,
    ?multipleStatements : Bool,
    ?queryFormat : String -> Array<Dynamic> -> String,
    ?supportBigNumbers : Bool,
    ?bigNumberStrings : Bool,
    ?timezone : String,
    ?typeCast : Bool
}

typedef MySQLPoolOptions = { > MySQLOptions,
    poolSize : Int
}

extern class MySQL {
    public static function createConnection(options : MySQLOptions) : DataAdapter;
    public static function createConnectionFromPool(options : MySQLPoolOptions) : DataAdapter;
    
    public static var catchError : String -> String -> Dynamic -> Void;
    
    private static function __init__() : Void untyped {
        try {
            if(saffron.tools == null) {
                saffron.tools = { };
            }
            
            saffron.tools.MySQL = Node.require("mysql");
            
#if debug
            saffron.tools.MySQL.catchError = function(q, p, err) {
                trace('{ query: "' + q + '", params: ' + saffron.Environment.JSON.stringify(p) + ' , error: "' + err + '" }');
            };
#end
            
            saffron.tools.MySQL.poolAdapters = { };
            saffron.tools.MySQL.createConnectionFromPool = function(options) {
                var key = '' + options.host + ':' + options.port + ':' + options.socketPath + ':' + options.user + ':' + options.password + ':' + options.database;
                var adapter = saffron.tools.MySQL.poolAdapters[key];
                
                if(adapter == null) {
                    var pOptions = {
                        name: 'mysql',
                        max: options.poolSize,
                        idleTimeoutMillis: 30000,
                        log: false,
                        create: function(fn) {
                            fn(saffron.tools.MySQL.createConnection(options));
                        },
                        destroy: function(connection) {
                            connection.destroy();
                        }
                    };
                    
                    adapter = {
                        pool: __js__("require('generic-pool').Pool(pOptions)"),
                        query: function(q, p, fn) {
                            if(__js__("typeof(p) === 'function'")) {
                                fn = p;
                                p = null;
                            }
                            
                            adapter.pool.acquire(function(err, connection) {
                                if(err) {
                                    if(saffron.tools.MySQL.catchError != null) {
                                        saffron.tools.MySQL.catchError(q, p, err);
                                    }
                                    
				                    fn(err, null);
				                } else {
				                    connection.query(q, p, function(err, result) {
				                        __js__("try {");
				                        if(err != null && saffron.tools.MySQL.catchError != null) {
                                            saffron.tools.MySQL.catchError(q, p, err);
                                        }
				                        fn(err, result);
				                        __js__("} finally { ");
				                        adapter.pool.release(connection);
				                        __js__("}");
                                    });
                                }
                            });
                        }
                    };
                    
                    saffron.tools.MySQL.poolAdapters[key] = adapter;
                }
                
                return adapter;
            };
        }
        catch(e : Dynamic) {
        }
    }
}

#end
