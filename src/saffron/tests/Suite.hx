/* Copyright (c) 2013 Janek Priimann */

package saffron.tests;

import saffron.tools.Jasmine;

@:require(test) @:keepSub class Suite {
    private var _env : JasmineEnv;
    
    public function new(env : JasmineEnv) {
        this._env = env;
    }
    
    public function beforeEach() : Void {
    }
    
    public function afterEach() : Void {
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
