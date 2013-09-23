/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;

class SubmitField extends Widget {
    private static inline var key_title = 'title';
    
    public function new(?id : String) {
        super(id);
    }
    
    public function getTitle() : String {
        return this.get(key_title);
    }
    
    public function setTitle(title : String) : Void {
        this.set(key_title, title);
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        return chunk.write(
        	'<input type="submit"' +
        		this.generateStandardAttributes() +
        		this.generateAttribute('value', this.getTitle()) + '/>');
    }
}
