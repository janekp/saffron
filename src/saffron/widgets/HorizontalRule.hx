/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;

class HorizontalRule extends Widget {
    public function new(?id : String) {
        super(id);
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        return chunk.write('<hr' + this.generateStandardAttributes() + ' />');
    }
}
