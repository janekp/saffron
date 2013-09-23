/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;

class Label extends Widget {
    private static inline var key_text = 'text';
    
    public function new(?id : String) {
        super(id);
        this.setClass('label');
    }
    
    public function getText() : String {
        return this.get(key_text);
    }
    
    public function setText(text : String) : Void {
        this.set(key_text, text);
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        return chunk.write(
        	'<p' + this.generateStandardAttributes() + '>' +
        		this.generateHtml(this.getText()) +
        	'</p>');
    }
}
