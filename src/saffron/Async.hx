/* Copyright (c) 2013 Janek Priimann */

package saffron;

extern class Async {
    public function new();
    
    public static inline function context(ctx : Dynamic) : Async {
        return ctx;
    }
    
    @:overload(function(fn : (?Dynamic -> Void) -> Dynamic -> Void, ?parallel : Bool, ?nextTick : Bool) : Async {})
    @:overload(function(fn : (?Dynamic -> Void) -> Void, ?parallel : Bool, ?nextTick : Bool) : Async {})
    public function begin(fn : Void -> Void, ?parallel : Bool, ?nextTick : Bool) : Async;
    
    @:overload(function(result : Dynamic) : Void {})
    public function finish() : Void;
    
    private static function __init__() : Void untyped {
        __js__("
        (function(exports) {
            function await(finish) {
                finish();
            }
            
            function invoke(fn, finish, result) {
                fn(finish, result);
                
                if(fn.length === 0) {
                    finish();
                }
            }
            
            var nextTickFn = (typeof(process) !== 'undefined' && typeof(process.nextTick) !== 'undefined')
                ? process.nextTick : window.setTimeout;
            
            exports.Async = function(options) {
                function async(fn, parallel, nextTick) {
                    if(typeof(fn) !== 'function') {
                        fn = await;
                        parallel = false;
                    }
                    
                    if(nextTick === true) {
                        var fn_o = fn;
                        
                        fn = function(finish, result) {
                            nextTickFn(function() {
                                invoke(fn_o, finish, result);
                            }, 0);
                        };
                    }
                    
                    if(async.depth === 0) {
                        async.depth = (parallel === true) ? 2 : 1;
                        invoke(fn, async.finish, async.result);
                    } else if(parallel === true && async.depth > 1 && async.result === undefined) {
                        async.depth += 1;
                        invoke(fn, async.finish, async.result);
                    } else {
                        if(async.queue === undefined) {
                            async.queue = new Array();
                        }
                        
                        if(parallel === true) {
                            if(async.queue.length > 0 && async.queue[async.queue.length - 1] instanceof Array) {
                                async.queue[async.queue.length - 1].push(fn);
                            } else {
                                async.queue.push(new Array(fn));
                            }
                        } else {
                            async.queue.push(fn);
                        }
                    }
                    
                    return async;
                }
                
                async.depth = 0;
                async.begin = async;
                async.finish = function(result) {
                    if(async.depth > 1) {
                        if(typeof(result) !== 'undefined') {
                            if(async.result === undefined) {
                                async.result = new Array();
                            }
                            
                            async.result.push(result);
                        }
                        
                        if(async.depth > 2) {
                            async.depth -= 1;
                            return;
                        }
                        
                        result = async.result;
                    }
                    
                    if(async.queue !== undefined && async.queue.length > 0) {
                        var fns = async.queue.shift();
                        
                        async.depth = 1;
                        async.result = undefined;
                        
                        if(fns instanceof Array) {
                            var i, c;
                            
                            for(i = 0, c = fns.length; i < c; i++) {
                                async.depth += 1;
                                invoke(fns[i], async.finish, result);
                            }
                        } else {
                            invoke(fns, async.finish, result);
                        }
                    } else {
                        async.depth = 0;
                        async.result = result;
                    }
                };
                
                return async;
            };
        })(saffron)");
    }
}
