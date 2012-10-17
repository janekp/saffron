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
    @:macro public static function query(ctx : Expr, q : String, p : Expr, ?fn : Expr) : Expr {
        return Macros.generateDataQuery(ctx, q, p, fn);
    }
    
    @:macro public static function subscribe(ctx : Expr, q : String, p : Expr, ?fn : Expr) : Expr {
        return Macros.generateDataSubscribe(ctx, q, p, fn);
    }
    
    @:macro public static function unsubscribe(ctx : Expr, ?q : String, ?p : Expr, ?fn : Expr) : Expr {
        return Macros.generateDataUnsubscribe(ctx, q, p, fn);
    }
    
    @:macro public static function push(ctx : Expr, q : String, p : Expr, ?fn : Expr) : Expr {
        return Macros.generateDataPush(ctx, q, p, fn);
    }
    
#if server
    @:macro private static function clearRemoteHandlers() : Expr {
        return Macros.clearRemoteHandlers();
    }
#end
    
#if !macro
    public static var adapter : Void -> DataAdapter;
    
    private static function __init__() : Void untyped {
#if server
        Data.clearRemoteHandlers();
        
        try {
            var path = require.resolve(__filename + '.calls');
            saffron.Server.__remoteHandlers = require('vm').runInThisContext('[' + require('fs').readFileSync(path, 'utf-8') + ']', path);
        }
        catch(e : Dynamic) {
        }
#end
    
#if client
        saffron.Data.__remoting = {
            exec: function(q : String, ?p : Array<Dynamic>, fn : DataError -> DataResult -> Void) : Void {
                
            },
            query: function(q : String, ?p : Array<Dynamic>, fn : DataError -> Array<Dynamic> -> Void) : Void {
                if(__js__("typeof(p) === 'function'")) {
                    fn = p;
                    p = null;
                }
                
                jQuery.ajax({
                    url: saffron.Client.context.remote_prefix + q,
                    type: 'POST',
                    data: { v: (p != null) ? p[0] : ''
                } }).done(function(data) {
                    if(__js__("typeof(data) === 'object'")) {
                        fn(data.error, data.results);
                    } else {
                        fn({ code: 'Unknown', fatal: true }, null);
                    }
                }).fail(function(jqXHR, textStatus) {
                    fn({ code: 'HTTPError', fatal: true }, null);
                });
            }
        };
        saffron.Data.adapter = function() { return saffron.Data.__remoting; }
#end
    }
#end
}
