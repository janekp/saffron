/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;

class FileField extends Widget {
    private static inline var key_multiple = 'multiple';
    private static inline var key_required = 'required';
    
    public function new(?id : String) {
        super(id);
    }
    
    public function isMultiple() : Bool {
        return (this.get(key_multiple) == true) ? true : false;
    }
    
    public function setMultiple(multiple : Bool) : Void {
        this.set(key_multiple, multiple);
    }
    
    public function isRequired() : Bool {
        return (this.get(key_required) == true) ? true : false;
    }
    
    public function setRequired(required : Bool) : Void {
        this.set(key_required, required);
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        return chunk.write(
        	'<input type="file"' +
        		this.generateStandardAttributes() +
        		this.generateAttribute('name', this.getId()) +
        		this.generateAttribute(key_multiple, (this.isMultiple()) ? key_multiple : null) +
        		this.generateAttribute(key_required, (this.isRequired()) ? key_required : null) +
        	'/>');
    }
}
