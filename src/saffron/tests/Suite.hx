/* Copyright (c) 2013 Janek Priimann */

package saffron.tests;

import saffron.tools.Jasmine;

@:require(test) @:keepSub class Suite {
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
}
