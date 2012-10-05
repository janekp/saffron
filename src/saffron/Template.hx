/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if !client

import js.Node;

typedef TemplateError = NodeErr;
typedef TemplateStream = NodeReadStream;

#else

typedef TemplateError = Null<String>;
typedef TemplateStream = { }

#end

typedef TemplateChunk = {
    function render(name : String, context : Dynamic) : TemplateChunk;
    function write(data : Dynamic) : TemplateChunk;
    function map(fn : TemplateChunk -> Void) : TemplateChunk;
    function end(?data : Dynamic) : TemplateChunk;
    function tap(fn : Void -> Void) : TemplateChunk;
    function untap() : TemplateChunk;
    function setError(err : TemplateError) : TemplateChunk;
}

typedef TemplateContext = {
    function current() : TemplateContext;
    function get(key : String) : Dynamic;
    function push(head : Dynamic, ?index : Int, ?length : Int) : TemplateContext;
    function rebase(head : Dynamic) : Void;
}

typedef TemplateBodies = {
    var block : Dynamic;
}

typedef TemplateOptimizers = {
    var format : TemplateContext -> Dynamic -> Dynamic;
}

typedef TemplateScript = {
}

#if !client
extern class Template {
#else
@:native("window.dust") extern class Template {
#end
    public static var helpers : Dynamic;
    public static var filters : Dynamic;
    public static var escapeHtml : Dynamic -> Dynamic;
    public static var escapeJs : Dynamic -> Dynamic;
    public static var optimizers : TemplateOptimizers;
    public static var onLoad : String -> (TemplateError -> String -> Void) -> Void;
    
    public static function compile(source : String, name : String) : String;
    public static function compileFn(source : String, name : String) : Void -> Void;
    public static function loadSource(src : TemplateScript) : Void;
    public static function render(name : String, context : Dynamic, fn : TemplateError -> Dynamic -> Void) : Void;
    public static function renderSource(src : TemplateScript, context : Dynamic, ?fn : TemplateError -> Dynamic -> Void) : TemplateStream;
    public static function stream(name : String, context : Dynamic) : TemplateStream;
    public static function makeBase(base : Dynamic) : TemplateContext;
    
    private static function __init__() : Void untyped {
#if !client
        try {
            saffron.Template = Node.require("dustjs-linkedin");
            saffron.Template.onLoad = function(name, fn) {
                Node.fs.readFile('templates/' + name, function(err, data) {
                    if(data != null) {
                        fn(err, data.toString());
                    } else {
                        trace("ERROR: Could not load template at 'templates/" + name + '"');
                        fn(null, '');
                    }
                });
            };
        }
        catch(e : Dynamic) {
        }
#else
        // TODO: onLoad?
#end
    }
}
