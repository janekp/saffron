/* Copyright (c) 2013 Janek Priimann */

package saffron.tests;

import haxe.rtti.Meta;
import saffron.tools.Jasmine;

typedef RunnerOptions = {
    ?logger : String -> Void,
    ?updateInterval : Int
}

@:require(test) @:keepSub class Runner {
    private var suites : Array<Dynamic>;
    private var options : RunnerOptions;
    
    public function new(?options : RunnerOptions) {
        this.suites = new Array<Dynamic>();
        this.options = (options != null) ? options : { };
    }
    
    public function addSuite(suite : Dynamic) : Void {
        this.suites.push(suite);
    }
    
    public function execute(?fn : JasmineEnv -> Void) : Void {
        var env = Jasmine.getEnv();
        
        if(fn != null) {
            fn(env);
        } else {
            env.updateInterval = (this.options.updateInterval != null) ? this.options.updateInterval : 250;
            env.addReporter(Jasmine.createConsoleReporter((this.options.logger != null) ? this.options.logger : function(str) { trace(str); }));
        }
        
        for(suite in this.suites) {
            this.describe(env, suite);
        }
        
        env.execute();
    }
    
    private function describe(env : JasmineEnv, klass : Dynamic) : Void {
        var meta = Meta.getType(klass);
        var suite : Suite = Type.createInstance(klass, [ env ]);
        var fields = Meta.getFields(klass);
        var wrap = function(name : String, fn : Void -> Void) : Void {
            env.it(name, function() { Reflect.callMethod(suite, fn, []); });
        }
        
        env.describe((meta.suite != null) ? meta.suite.join('') : Type.getClassName(klass), function() {
            env.beforeEach(function() {
                suite.beforeEach();
            });
            
            for(field in Reflect.fields(fields)) {
                var m = Reflect.field(fields, field);
                
                if(Reflect.hasField(m, 'spec')) {
                    var method : Void -> Void = Reflect.field(suite, field);
                    var name = Reflect.field(m, 'spec');
                    
                    if(method != null) {
                        wrap((name != null) ? name : field, method);
                    }
                }
            }
            
            env.afterEach(function() {
                suite.afterEach();
            });
        });
    }
}
