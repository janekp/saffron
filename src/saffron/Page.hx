/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron;

#if !macro
import js.Node;
import saffron.Async;
import saffron.Template;
import saffron.tools.Express;
#else
import haxe.macro.Context;
import haxe.macro.Expr;
#end

typedef PageHeaderAttributes = {
	?title : String, // 'Untitled',
	?stylesheet : String, // 'stylesheet.css',
	?language : String, // 'en',
	?encoding : String, // 'utf-8'
};

@:autoBuild(saffron.Macros.buildPage()) class Page {
	macro public function async(ethis : Expr, fn : Expr, ?parallel : Bool, ?nextTick : Bool) : Expr {
        return Macros.generateAsync(ethis, fn, parallel, nextTick);
    }
    
    macro public function parallel(ethis : Expr, fn : Expr, ?nextTick : Bool) : Expr {
        return Macros.generateAsync(ethis, fn, true, nextTick);
    }
    
#if !macro
	public var request : ExpressRequest;
    public var response : ExpressResponse;
    public var template : String;
    private var _async : Dynamic;
    private var _state : Dynamic;
    
    public function new(request : ExpressRequest, response : ExpressResponse, template : String) {
    	this.request = request;
    	this.response = response;
    	this.template = template;
    	this._async = new Async();
    }
    
    public function render(?params : Dynamic, ?template : String, ?status : Int) : Void {
        if(template == null) {
            template = this.template;
        }
        
        if(template != null) {
            var ctx = Template.makeBase(this);
            var layout = this.layout();
            
            if(params != null) {
                ctx = ctx.push(params);
            }
            
            this.response.writeHead((status != null) ? status : 200, { "Content-Type": "text/html" });
            
            if(layout != null) {
                Template.stream(layout + '.html', Template.makeBase({
                    body: function(chunk : TemplateChunk, _ctx : TemplateContext) : TemplateChunk {
                        return chunk.partial(template + '.html', ctx);
                    },
                    request: this.request,
                    page: this,
                    language: Locale.code,
                    template: template
                })).pipe(this.response);
            } else {
                Template.stream(template + '.html', ctx).pipe(this.response);
            }
            
            this.template = null;
        }
    }
    
    public inline function redirect(location : String, ?status : Int = 200) : Void {
    	this.response.redirect(status, location);
    }
    
    public inline function sendfile(path : String) : Void {
    	this.response.sendfile(path);
    }
    
    private function layout() : String {
        return null;
    }
    
    private function findWidgetById(id : String, ?constructor : Void -> Dynamic) : Dynamic {
    	var widget : Dynamic = null;
    	
        if(this._state == null) {
        	this._state = { _w: { } };
        }
        
        widget = this._state._w[untyped id];
        
		if(widget == null && constructor != null) {
			widget = constructor();
			this._state._w[untyped id] = widget;
        }
        
        return widget;
    }
    
    private static inline function renderHeader(chunk : TemplateChunk, attributes : PageHeaderAttributes) : TemplateChunk {
    
    // ?title : String, // = 'Untitled',
	//?stylesheet : String, // = 'stylesheet.css',
	//?language : String, // = 'en',
	//?encoding : String, // = 'utf-8'
	
        return chunk.write(
            '<!DOCTYPE html>' + 
            '<!--[if lt IE 7 ]><html class="ie ie6" lang="en"> <![endif]-->' +
            '<!--[if IE 7 ]><html class="ie ie7" lang="en"> <![endif]-->' +
            '<!--[if IE 8 ]><html class="ie ie8" lang="en"> <![endif]-->' + 
            '<!--[if (gte IE 9)|!(IE)]><!--><html lang="en"> <!--<![endif]-->' +
            '<head>' + 
	        '<meta charset="' + attributes.encoding + '" />' + 
	        '<title>' + attributes.title + '</title>' +
	        '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />' +
	        '<link rel="stylesheet" href="' + attributes.stylesheet + '" />' +
	        //'<link rel="shortcut icon" href="images/favicon.ico" />' +
	        //'<link rel="apple-touch-icon" href="images/apple-touch-icon-57.png" />' + 
	        //'<link rel="apple-touch-icon" sizes="72x72" href="images/apple-touch-icon-72.png" />' + 
	        //'<link rel="apple-touch-icon" sizes="114x114" href="images/apple-touch-icon-114.png" />' + 
	        '<!--[if lt IE 9]><script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script><![endif]-->' +
	        '</head><body>');
    }
    
    private static inline function renderFooter(chunk : TemplateChunk) : TemplateChunk {
        return chunk.write('</body></html>');
    }
#end
}