/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;
import saffron.tools.Text;

#if !client
import js.Node;
#end

class MultiChoiceButton extends saffron.widgets.data.View {
    public function new(?id : String) {
        super(id);
    }
    
    public function isSelectedIndex(index : Int) : Bool {
        return false;
    }
    
    private override function renderItem(chunk : TemplateChunk, row : Int) : TemplateChunk {
        var selected = this.isSelectedIndex(row);
        var data : Dynamic = this.adapter[row];
        var title = null;
        var value = null;
        
        if(data == null) {
            data = '';
        }
        
        if(Std.is(data, String)) {
            title = data;
        } else {
            title = data.key;
            value = data.value;
        }
        
        title = Text.escapeHtml(title);
        value =  Text.escapeHtml(value);
        
        return chunk.write(
            '<label for="' + this.getId() + '_' + row + '">' + 
            '<input type="checkbox" id="' + this.getId() + '_' + row +
            '" value="' + value + '"' + 
            ((selected) ? ' checked="checked"' : '') +
            ' /><span>' + title + '</span></label>');
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        chunk = chunk.write('<fieldset id="' + this.getId() + '"' + ((this.getClass() != null) ? ' class="' + this.getClass() + '">' : '>'));
        chunk = this.renderItems(chunk);
        chunk = chunk.write('</fieldset>');
        
        return chunk;
    }
}
