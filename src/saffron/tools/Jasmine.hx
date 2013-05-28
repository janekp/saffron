/* Copyright (c) 2013 Janek Priimann */

package saffron.tools;

#if !client

import saffron.tools.Node;

typedef JasmineClock = {
    function reset() : Void;
    function tick(interval : Int) : Void;
}

typedef JasmineMatchers = {
    var not(default, null) : JasmineMatchers;
    
    function toBe(expected : Dynamic) : Void;
	function toBeDefined() : Void;
	function toBeFalsy() : Void;
	function toBeGreaterThan(expected : Dynamic) : Void;
	function toBeLessThan(expected : Dynamic) : Void;
	function toBeNull() : Void;
	function toBeTruthy() : Void;
	function toBeUndefined() : Void;
	function toContain(expected : Dynamic) : Void;
	function toEqual(expected : Dynamic) : Void;
	function toHaveBeenCalled() : Void;
	function toHaveBeenCalledWith(arguments : Dynamic) : Void;
	function toMatch(expected : Dynamic) : Void;
	function toThrow(expected : String) : Void;
}

typedef JasmineEnv = {
    var updateInterval(default, default) : Int;
    var currentSpec : JasmineSpec;
    
	function addReporter(reporter : JasmineReporter) : Void;
	function execute() : Void;
	
	function beforeEach(fn : Void -> Void) : Void;
	function afterEach(fn : Void -> Void) : Void;
	function describe(description : String, fn : Void -> Void) : Void;
	function xdescribe(description : String, fn : Void -> Void) : Void;
	function it(description : String, fn : Void -> Void) : Void;
	function xit(description : String, fn : Void -> Void) : Void;
}

typedef JasmineReporter = {
    function log(line : String) : Void;
}

typedef JasmineRunner = {
    function results() : JasmineRunnerResults;
}

typedef JasmineRunnerResults = {
    var failedCount(default, null) : Int;
}

typedef JasmineSpec = { > JasmineMatchers,
	function expect(value : Dynamic) : JasmineMatchers;
	function runs(fn : Void -> Void) : Void;
	function waits(timeout : Int) : Void;
	function waitsFor(fn : Void -> Bool, ?msg : String, ?timeout : Int) : Void;
	function spyOn(x : Dynamic, method : String) : JasmineSpy;
}

typedef JasmineSpy = {
    var callCount(default, null) : Int;
    
	function andCallFake(fakeFn : Dynamic) : JasmineSpy;
	function andCallThrough() : JasmineSpy;
	function andReturn(value : Dynamic) : JasmineSpy;
	function andThrow(msg : String) : JasmineSpy;
	function plan() : Void;
	function reset() : Void;
}

typedef JasmineTerminalReporterOptions = {
    ?print : String -> Void,
    ?color : Bool,
    ?includeStackTrace : Bool,
    ?onComplete : JasmineRunner -> Dynamic -> Void,
    ?stackFilter : Dynamic
}

extern class Jasmine {
    public static var Clock : JasmineClock;
    
    public static function getEnv() : JasmineEnv;
    public static function createConsoleReporter() : JasmineReporter;
    public static function createHtmlReporter() : JasmineReporter;
    public static function createJUnitXmlReporter(savePath : String, ?consolidate : Bool = true, ?useDotNotation : Bool = true) : JasmineReporter;
    public static function createTerminalReporter(?options : JasmineTerminalReporterOptions) : JasmineReporter;
    public static function createSpy() : JasmineSpy;
    
    private static function __init__() : Void untyped {
        try {
            if(saffron.tools == null) {
                saffron.tools = { };
            }
            
            saffron.tools.Jasmine = Node.require('jasmine-node');
            saffron.tools.Jasmine.createConsoleReporter = function() {
                return __js__('new (saffron.tools.Jasmine.ConsoleReporter)')();
            };
            saffron.tools.Jasmine.createHtmlReporter = function() {
                return __js__('new (saffron.tools.Jasmine.HtmlReporter)')();
            };
            saffron.tools.Jasmine.createJUnitXmlReporter = function(savePath, consolidate, useDotNotation) {
                return __js__('new (saffron.tools.Jasmine.JUnitXmlReporter)')(savePath, consolidate, useDotNotation);
            };
            saffron.tools.Jasmine.createTerminalReporter = function(options) {
                return __js__('new (saffron.tools.Jasmine.TerminalReporter)')(options);
            };
        }
        catch(e : Dynamic) {
        }
    }
}

#else

typedef Jasmine = { }

#end
