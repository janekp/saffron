/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if !client
import js.Node;
#end

class Page extends Handler {
    public function render(?params : Dynamic, ?template : String, ?status : Int) : Void {
#if !client
        if(this._ctx.template != null) {
#if server
            var ctx = Template.makeBase({ saffron: Server.__generateClientScript }).push((params != null) ? params : this);
#else
            var ctx = Template.makeBase((params != null) ? params : this);
#end
            
            this._ctx.response.writeHead((status != null) ? status : 200, { "Content-Type": "text/html" });
            Template.stream(((template != null) ? template : this._ctx.template) + '.html', ctx).pipe(this._ctx.response);
            this._ctx.template = null;
        }
#else
        if(this._ctx.template != null) {
            Template.render(((template != null) ? template : this._ctx.template) + '.html', (params != null) ? params : this, function(err, html) {
                untyped document.body.innerHTML = html;
            });
            this._ctx.template = null;
        }
#end
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
