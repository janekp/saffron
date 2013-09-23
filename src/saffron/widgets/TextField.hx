/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;

class TextField extends Widget {
	private static inline var key_multiline = 'multiline';
	private static inline var key_placeholder = 'placeholder';
    private static inline var key_required = 'required';
    private static inline var key_text = 'text';
    
    public function new(?id : String) {
        super(id);
    }
    
    public function isRequired() : Bool {
        return (this.get(key_required) == true) ? true : false;
    }
    
    public function setRequired(required : Bool) : Void {
        this.set(key_required, required);
    }
    
    public function isMultiline() : Bool {
        return (this.get(key_multiline) == true) ? true : false;
    }
    
    public function setMultiline(multiline : Bool) : Void {
        this.set(key_multiline, multiline);
    }
    
    public function getText() : String {
        return this.get(key_text);
    }
    
    public function setText(text : String) : Void {
        this.set(key_text, text);
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
    	return (this.isMultiline()) ?
    		chunk.write(
    			'<textarea' +
    				this.generateStandardAttributes() +
    				this.generateAttribute(key_required, (this.isRequired()) ? key_required : null) +
        			this.generateAttribute('name', this.getId()) + '>' +
        				this.generateHtml(this.getText()) +
        		'</textarea>') : 
    		chunk.write(
        		'<input type="text"' +
        			this.generateStandardAttributes() +
        			this.generateAttribute('name', this.getId()) +
        			this.generateAttribute(key_required, (this.isRequired()) ? key_required : null) +
        			this.generateAttribute('value', this.getText()) +
        		'/>');
    }
}
