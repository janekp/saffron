/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron;

using StringTools;

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
    function partial(name : String, context : Dynamic) : TemplateChunk;
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

#if client
@:native('dust') extern class Template {
#else
extern class Template {
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
    
    public static var templates : Dynamic;
    public static var srcRoot : String;
    
    private static var ready : Bool;
    
    private static function __init__() : Void untyped {
#if !client
        try {
            saffron.Template = Node.require('dustjs-linkedin');
            try { saffron.Template.helper = Node.require('dustjs-helpers'); } catch(e : Dynamic) { }
            saffron.Template.srcRoot = Node.__dirname + '/templates/';
            
#if server
            saffron.Template.onLoad = function(name, fn) {
                var data = saffron.Template.templates[saffron.Template.srcRoot + name];
                
                if(data != null) {
                    fn(null, data);
                } else {
                    trace("ERROR: Could not load template at '" + saffron.Template.srcRoot + name + '"');
                    fn(null, '');
                }
            };
            
            saffron.Template.templates = (function() : Dynamic {
                var templates : Dynamic = { };
                var files = Node.fs.readdirSync(saffron.Template.srcRoot);
                
                for(file in files) {
                    if(untyped file.indexOf('.html', file.length - 5) != -1) {
                        file = saffron.Template.srcRoot  + file;
                        templates[untyped file] = Node.fs.readFileSync(file, 'UTF-8');
                    }
                }
                
                return templates;
            })();
#else
            saffron.Template.onLoad = function(name, fn) {
                Node.fs.readFile(saffron.Template.srcRoot + name, function(err, data) {
                    if(data != null) {
                        fn(err, data.toString());
                    } else {
                        trace("ERROR: Could not load template at '" + saffron.Template.srcRoot + name + '"');
                        fn(null, '');
                    }
                });
            };
#end
            
            if(saffron.Locale != null) {
                if(saffron.Template.helpers == null) {
                    saffron.Template.helpers = { };
                }
                
                saffron.Template.filters.L = Locale.str;
                saffron.Template.helpers.localize = function(chunk, ctx, bodies, params) {
                    return chunk.write((params.escape == 'false') ? Locale.str(params.str) : Locale.str(params.str).htmlEscape(true));
                };
            }
        }
        catch(e : Dynamic) {
        }
#else
        function onTemplateLoad(name, fn) {
            var data = __js__("saffron.Template.templates[saffron.Template.srcRoot + name]");
            
            if(data != null) {
                fn(null, data);
            } else {
                trace("ERROR: Could not load template at '" + saffron.Template.srcRoot + name + '"');
                fn(null, '');
            }
        };
        
        __js__("saffron.Template = { }");
        __js__("saffron.Template.onLoad = onTemplateLoad");
        __js__("window.__saffron = saffron.Template");
#end
    }
}