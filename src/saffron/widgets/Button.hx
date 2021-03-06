/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;

class Button extends Widget {
    private static inline var key_action = 'action';
    private static inline var key_title = 'title';
    
    public function new(?id : String) {
        super(id);
        this.setClass('button');
    }
    
    public function getAction() : String {
        return this.get(key_action);
    }
    
    public function setAction(action : String) : Void {
        this.set(key_action, action);
    }
    
    public function getTitle() : String {
        return this.get(key_title);
    }
    
    public function setTitle(title : String) : Void {
        this.set(key_title, title);
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        return chunk.write(
        	'<a' + this.generateStandardAttributes() + this.generateAttribute('href', (this.getAction() != null) ? this.getAction() : '#') + '>' +
        		this.generateHtml(this.getTitle()) +
        	'</a>');
    }
}
