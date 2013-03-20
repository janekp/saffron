/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if !client
import js.Node;
#end

import saffron.Template;

class Page extends Handler {
    private var state : Dynamic;
    
    public function render(?params : Dynamic, ?template : String, ?status : Int) : Void {
        if(template == null) {
            template = this._ctx.template;
        }
        
#if !client
        if(this._ctx.template != null) {
#if server
            var ctx = Template.makeBase({ saffron: Server.__generateClientScript }).push(this);
#else
            var ctx = Template.makeBase(this);
#end
            var layout = this.layout();
            
            if(params != null) {
                ctx = ctx.push(params);
            }
            
            this._ctx.response.writeHead((status != null) ? status : 200, { "Content-Type": "text/html" });
            
            if(layout != null) {
                Template.stream(layout + '.html', Template.makeBase({
#if server
                    saffron: Server.__generateClientScript,
#end
                    body: function(chunk : TemplateChunk, _ctx : TemplateContext) : TemplateChunk {
                        return chunk.partial(template + '.html', ctx);
                    },
                    context: this._ctx,
                    language: Locale.code,
                    template: template
                })).pipe(this._ctx.response);
            } else {
                Template.stream(template + '.html', ctx).pipe(this._ctx.response);
            }
            
            this._ctx.template = null;
        }
#else
        if(this._ctx.template != null) {
            var layout = this.layout();
            
            if(layout != null) {
                Template.render(layout + '.html', Template.makeBase({
                    body: function(chunk : TemplateChunk, _ctx : TemplateContext) : TemplateChunk {
                        return chunk.partial(template + '.html', (params != null) ? params : this);
                    },
                    context: this._ctx,
                    language: Locale.code,
                    template: template
                }), function(err, html) {
                    untyped document.body.innerHTML = html;
                });
            } else {
                Template.render(template + '.html', (params != null) ? Template.makeBase(this).push(params) : Template.makeBase(this), function(err, html) {
                    untyped document.body.innerHTML = html;
                });
            }
                        
            this._ctx.template = null;
        }
#end
    }
    
    private function findWidgetById(id : String, ?fn : Dynamic -> String -> Widget) : Dynamic {
        var widget;
        
        if(id == null) {
            return null;
        }
        
        if(this.state == null) {
            this.state = { _w: { } };
        }
        
        widget = this.state._w[untyped id];
        
        if(widget == null && fn != null) {
            widget = fn(null, id);
            this.state._w[untyped id] = widget;
        }
        
        return widget;
    }
    
    private function layout() : String {
        return null;
    }
    
    private inline function client() : Bool {
#if !client
        return false;
#else
        return true;
#end
    }
}
