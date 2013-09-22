/* Copyright (c) 2013 Janek Priimann */

package saffron;

import js.Node;
import saffron.Template;

using StringTools;

class Widget {
    private var _state : Dynamic;
    
    private function new(?id : String) {
        this._state = { id: id };
    }
    
    public function getId() : String {
        return this._state.id;
    }
    
    public function setId(id : String) : Void {
        this._state.id = id;
    }
    
    public function getClass() : String {
        return this._state[untyped 'class'];
    }
    
    public function setClass(cls : String) : Void {
        this._state[untyped 'class'] = cls;
    }
    
    public function addClass(cls : String) : Void {
        var cls_ : String = this._state[untyped 'class'];
        
        if(cls_ != null) {
        	var classes = cls_.split(' ');
        	
        	for(cls__ in classes) {
        		if(cls__ == cls) {
        			return;
        		}
        	}
        	
        	classes.push(cls);
        	this.setClass(classes.join(' '));
        } else {
        	this.setClass(cls);
        }
    }
    
    public function get(key : String) : Dynamic {
        return this._state[untyped key];
    }
    
    public function set(key : String, value : Dynamic) : Void {
        this._state[untyped key] = value;
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
    
    private inline function generateAttribute(key : String, value : String) : String {
    	return (value != null) ? ' ' + key + "=\"" + value.htmlEscape(true) + "\"" : '';
    }
    
    private inline function generateHtml(value : String) : String {
    	return (value != null) ? value.htmlEscape(true) : '';
    }
    
    private inline function generateStandardAttributes() : String {
    	return this.generateAttribute('id', this.getId()) + this.generateAttribute('class', this.getClass());
    }
}
