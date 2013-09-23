/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;

class Form extends Container {
	public static inline var encoding_multipart = 'multipart/form-data';
	public static inline var method_get = 'get';
	public static inline var method_post = 'post';
	
	private static inline var key_action = 'action';
	private static inline var key_encoding = 'enctype';
    private static inline var key_method = 'method';
    
    private var fields : Dynamic;
    private var labels : Dynamic;
    
    public function new(?id : String) {
        super(id);
        this.fields = { };
        this.labels = { };
        this.setEncoding(encoding_multipart);
        this.setMethod(method_post);
    }
    
    public function getAction() : String {
        return this.get(key_action);
    }
    
    public function setAction(action : String) : Void {
        this.set(key_action, action);
    }
    
    public function getEncoding() : String {
        return this.get(key_encoding);
    }
    
    public function setEncoding(encoding : String) : Void {
        this.set(key_encoding, encoding);
    }
    
    public function getField(name : String) : String {
    	return this.fields[untyped name];
    }
    
    public function setField(name : String, value : String) : Void {
    	this.fields[untyped name] = value;
    }
    
    public function getMethod() : String {
        return this.get(key_method);
    }
    
    public function setMethod(method : String) : Void {
        this.set(key_method, method);
    }
    
    public function addWidgetWithLabel(widget : Widget, label : String) : Void {
        this.addWidget(widget);
        
        if(label != null && widget.getId() != null) {
        	this.labels[untyped widget.getId()] = label;
        }
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        chunk = chunk.write('<form' +
        	this.generateStandardAttributes() +
        	this.generateAttribute(key_action, this.getAction()) +
        	this.generateAttribute(key_encoding, this.getEncoding()) +
        	this.generateAttribute(key_method, this.getMethod()) + '>');
        
        untyped __js__("for(var field in this.fields) { chunk = chunk.write('<input type=\"hidden\" name=\"' + field + '\" value=\"' + StringTools.htmlEscape(this.fields[field], true) + '\" />'");
        
        if(this.children != null) {
            for(child in this.children) {
            	var id = child.getId();
            	
            	if(id != null) {
            		var label = this.labels[untyped id];
            		
            		if(label != null) {
            			chunk = chunk.write('<label for="' + id + '">' + this.generateHtml(label) + '</label>');
            		}
            	}
            	
                chunk = child.render(chunk);
            }
        }
        
        chunk = chunk.write('</form>');
        
        return chunk;
    }
}
