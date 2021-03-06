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
    function capture(block : Dynamic, context : Dynamic, fn : Dynamic) : TemplateChunk;
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
                
                templates[untyped '__saffron'] = "{saffron}";
            	
                for(file in files) {
                    if(untyped file.indexOf('.html', file.length - 5) != -1) {
                        file = saffron.Template.srcRoot + file;
                        templates[untyped file] = Node.fs.readFileSync(file, 'UTF-8');
                    }
                }
                
                return templates;
            })();
#else
            saffron.Template.onLoad = function(name, fn) {
            	if(name == '__saffron') {
            		fn(null, "{saffron}");
            		return;
            	}
            	
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
            
            if(saffron.Template.helpers == null) {
            	saffron.Template.helpers = { };
            }
            
            var resolve = untyped function(chunk, context, input : Dynamic) : String {
            	var output : String = input;
            	
            	if(__js__('typeof input === "function"')) {
      				if(input.isFunction == true){
        				output = input();
      				} else {
						output = '';
						
        				chunk.tap(function(data) {
           					output += data;
           					return '';
          				}).render(input, context).untap();
          				
        				if(output == '') {
          					output = false;
						}
					}
				}
				
				return output;
            };
            
            var includes = function(a : String, b : String) : Bool {
            	if(a != b) {
            		var b_ : Array<String>;
            		
            		if(a == null || b == null) {
            			return false;
            		}
            		
            		a = Std.string(a);
            		b_ = Std.string(b).split(',');
            		
            		for(b__ in b_) {
            			if(a == b__) {
            				return true;
            			}
            		}
            		
            		return false;
            	}
            	
            	return true;
            };
            
            saffron.Template.helpers.test = function(chunk : TemplateChunk, ctx, bodies, params) : TemplateChunk {
            	var op = resolve(chunk, ctx, params.op);
            	
            	return (bodies.block != null &&
            			((op == 'in' && includes(resolve(chunk, ctx, params.a), resolve(chunk, ctx, params.b))) || 
            			 (op != 'in' && resolve(chunk, ctx, params.a) == resolve(chunk, ctx, params.b)))) ?
            		chunk.capture(bodies.block, ctx, function(string, chunk) {
            			chunk.end(string);
        			}) : chunk;
            };
            
            if(saffron.Widget != null) {
            	saffron.Template.helpers.widget = function(chunk, ctx, bodies, params) {
            		var name = params.name;
            		var widget : Widget = ctx.get('get' + name.charAt(0).toUppercase() + name.substring(1));
            		
                    return (widget != null) ? widget.render(chunk) : null;
                };
            }
            
            if(saffron.Locale != null) {
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