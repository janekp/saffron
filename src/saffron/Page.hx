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

class Page {
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
#end
}