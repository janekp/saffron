/* Copyright (c) 2013 Janek Priimann */

package saffron.tests;

import js.Node;
import saffron.tools.Jasmine;

@:autoBuild(saffron.macros.Builder.generateSuite()) @:require(test) @:keepSub class Suite {
    public static var all : Map<String, Dynamic>;
    
    private var _env : JasmineEnv;
    
    public function new(env : JasmineEnv) {
        this._env = env;
    }
    
    public function before() : Void {
    }
    
    public function after() : Void {
    }
    
    public function run() : Void {
    }
    
    private function requests(options : Helper.HelperRequestOptions, params : Dynamic, fn : Int -> Dynamic -> String -> Void) : Void {
        var complete = false;
        
        runs(function() {
            Helper.request(options, params, function(status, data, type) {
                complete = true;
                fn(status, data, type);
            });
        });
        
        waitsFor(function() {
            return complete;
        });
    }
    
    private function gets(str : String, ?params : Dynamic, fn : Int -> Dynamic -> String -> Void) : Void {
        var url = Node.url.parse(str, false);
        
        requests({
            protocol: url.protocol,
            host: url.host,
            port: Std.parseInt(url.port),
            path: untyped url.path,
            method: 'GET'
        }, params, fn);
    }
    
    private function posts(str : String, ?params : Dynamic, fn : Int -> Dynamic -> String -> Void) : Void {
        var url = Node.url.parse(str, false);
        
        requests({
            protocol: url.protocol,
            host: url.host,
            port: Std.parseInt(url.port),
            path: untyped url.path,
            method: 'POST'
        }, params, fn);
    }
    
    private inline function beforeEach(fn : Void -> Void) : Void {
        return this._env.beforeEach(fn);
    }
    
    private inline function afterEach(fn : Void -> Void) : Void {
        return this._env.afterEach(fn);
    }
    
    private inline function describe(description : String, fn : Void -> Void) : Void {
        this._env.describe(description, fn);
    }
    
    private inline function xdescribe(description : String, fn : Void -> Void) : Void {
        this._env.xdescribe(description, fn);
    }
    
	private inline function it(description : String, fn : Void -> Void) : Void {
	    this._env.it(description, fn);
	}
	
	private inline function xit(description : String, fn : Void -> Void) : Void {
	    this._env.xit(description, fn);
	}
	
    private inline function expect(value : Dynamic) : JasmineMatchers {
        return this._env.currentSpec.expect(value);
    }
    
	private inline function runs(fn : Void -> Void) : Void {
	    this._env.currentSpec.runs(fn);
	}
	
	private inline function waits(timeout : Int) : Void {
	    this._env.currentSpec.waits(timeout);
	}
	
	private inline function waitsFor(fn : Void -> Bool, ?msg : String, ?timeout : Int) : Void {
	    this._env.currentSpec.waitsFor(fn, msg, timeout);
	}
	
	private inline function spyOn(x : Dynamic, method : String) : JasmineSpy {
	    return this._env.currentSpec.spyOn(x, method);
	}
	
	private static function __init__() : Void {
	    Suite.all = new Map<String, Dynamic>();
	}
}
