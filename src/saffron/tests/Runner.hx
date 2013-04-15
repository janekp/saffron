/* Copyright (c) 2013 Janek Priimann */

package saffron.tests;

import haxe.rtti.Meta;
import saffron.tools.Jasmine;
import js.Node;

using StringTools;

typedef RunnerOptions = {
    ?logger : String -> Void,
    ?updateInterval : Int
}

@:require(test) @:keepSub class Runner {
    private var error : Bool;
    private var options : RunnerOptions;
    private var suites : Array<Dynamic>;
    
    public function new(?options : RunnerOptions) {
        this.error = false;
        this.options = (options != null) ? options : { };
        this.suites = new Array<Dynamic>();
    }
    
    public function addSuite(suite : Dynamic) : Void {
        this.suites.push(suite);
    }
    
    public function addSuites(name : String) : Void {
        var matchPrefix : Bool = false;
        
        if(name == null) {
            name = '';
        }
        
        if(name.endsWith('*')) {
            name = name.substring(0, name.length - 1);
            matchPrefix = true;
        }
        
        for(suite in Suite.all.keys()) {
            if((matchPrefix && suite.startsWith(name)) || (!matchPrefix && suite == name)) {
                this.addSuite(Suite.all.get(suite));
            }
        }
    }
    
    public function execute(?fn : JasmineEnv -> Void) : Void {
        var env = Jasmine.getEnv();
        
        if(fn != null) {
            fn(env);
        } else {
            env.updateInterval = (this.options.updateInterval != null) ? this.options.updateInterval : 250;
            env.addReporter(Jasmine.createTerminalReporter({
                color: true,
                includeStackTrace: false,
                onComplete: function(runner, log) {
                    this.error = (runner.results().failedCount != 0) ? true : false;
                }
            }));
        }
        
        env.beforeEach(function() {
            this.before();
        });
        
        for(suite in this.suites) {
            this.run(env, suite);
        }
        
        env.afterEach(function() {
            this.after();
        });
        
        env.execute();
    }
    
    public function wait(fn : Int -> Void) : Void {
        var cb : Dynamic = { };
        
        cb.uncaughtException = function() : Void {
            Node.process.removeListener('uncaughtException', cb.uncaughtException);
            this.error = true;
        };
        cb.exit = function() : Void {
            Node.process.removeListener('exit', cb.exit);
            fn((this.error) ? 1 : 0);
        };
        
        Node.process.on('uncaughtException', cb.uncaughtException);
        Node.process.on('exit', cb.exit);
    }
    
    private function before() : Void {
    }
    
    private function after() : Void {
    }
    
    private function run(env : JasmineEnv, klass : Dynamic) : Void {
        var meta = Meta.getType(klass);
        var suite : Suite = Type.createInstance(klass, [ env ]);
        var fields = Meta.getFields(klass);
        var wrap = function(name : String, fn : Void -> Void) : Void {
            env.it(name, function() { Reflect.callMethod(suite, fn, []); });
        }
        
        env.describe((meta.suite != null) ? meta.suite.join('') : Type.getClassName(klass), function() {
            env.beforeEach(function() {
                suite.before();
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
                suite.after();
            });
            
            suite.run();
        });
    }
}
