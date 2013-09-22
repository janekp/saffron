/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;

class Container extends Widget {
    private var children : Array<Widget> = null;
    
    public function new(?id : String) {
        super(id);
        this.setClass('container');
    }
    
    public function addWidget(widget : Widget) : Void {
        if(this.children == null) {
            this.children = new Array<Widget>();
        }
        
        this.children.push(widget);
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        chunk = chunk.write('<div' + this.generateStandardAttributes() + '>');
        
        if(this.children != null) {
            for(child in this.children) {
                chunk = child.render(chunk);
            }
        }
        
        chunk = chunk.write('</div>');
        
        return chunk;
    }
}
