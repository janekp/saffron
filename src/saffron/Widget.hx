/* Copyright (c) 2013 Janek Priimann */

package saffron;

import saffron.Template;

#if !client
import saffron.tools.Node;
#end

class Widget {
    private var state : Dynamic;
    
    private function new(?id : String) {
        this.state = { id: id };
    }
    
    public function getId() : String {
        return this.state.id;
    }
    
    public function setId(id : String) : Void {
        this.state.id = id;
    }
    
    public function getClass() : String {
        return this.state[untyped 'class'];
    }
    
    public function setClass(cls : String) : Void {
        this.state[untyped 'class'] = cls;
    }
    
    public function addClass(cls : String) : Void {
        // TODO: 
    }
    
    public function get(key : String) : Dynamic {
        return this.state[untyped key];
    }
    
    public function set(key : String, value : Dynamic) : Void {
        this.state[untyped key] = value;
    }
    
    public function bind(evt : String, fn : Void -> Void) : Void {
        if(fn != null) {
            // TODO: 
        } else {
            this.unbind(evt);
        }
    }
    
    public function unbind(evt : String) : Void {
        // TODO: 
    }
    
    public function render(chunk : TemplateChunk) : TemplateChunk {
        return chunk;
    }
}
