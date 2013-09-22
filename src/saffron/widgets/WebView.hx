/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;

class WebView extends Widget {
    private static inline var key_html = 'html';
    
    public function new(?id : String) {
        super(id);
    }
    
    public function getHtml() : String {
        return this.get(key_html);
    }
    
    public function setHtml(html : String) : Void {
        this.set(key_html, html);
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        var html = this.getHtml();
        
        return chunk.write('<div' + this.generateStandardAttributes() + '>' + ((html != null) ? html : '') + '</div>');
    }
}
