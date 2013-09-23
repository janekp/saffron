/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import js.Node;
import saffron.Template;

using StringTools;

class TableView extends saffron.widgets.data.View {
    private static inline var key_placeholder = 'placeholder';
    
    public function new(?id : String) {
        super(id);
        this.setClass('table');
    }
    
    private override function renderItem(chunk : TemplateChunk, row : Int) : TemplateChunk {
        var data : Dynamic = this.adapter[row];
        var title : String = null;
        var action = null;
        
        if(data == null) {
            data = '';
        }
        
        if(Std.is(data, String)) {
            title = data;
        } else {
            title = data.key;
            action = data.value;
        }
        
        title = title.htmlEscape(true);
        
        return chunk.write((action != null)
            ? '<div class="table-row' + ((row % 2 == 1) ? ' alt' : '') + '"><a href="' + action + '">' + title + '</a></div>'
            : '<div class="table-row' + ((row % 2 == 1) ? ' alt' : '') + '">' + title + '</div>');
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        chunk = chunk.write('<div' + this.generateStandardAttributes() + '>');
        chunk = this.renderItems(chunk);
        chunk = chunk.write('</div>');
        
        return chunk;
    }
}
