/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;

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
        
        title = this.generateHtml(title);
        value = this.generateHtml(value);
        
        return chunk.write(
            '<label for="' + this.getId() + '_' + row + '">' + 
            '<input type="checkbox" id="' + this.getId() + '_' + row +
            '" name="' + this.getId() + '[]" value="' + value + '"' + 
            ((selected) ? ' checked="checked"' : '') +
            ' /><span>' + title + '</span></label>');
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        chunk = chunk.write('<fieldset ' + this.generateStandardAttributes() + '>');
        chunk = this.renderItems(chunk);
        chunk = chunk.write('</fieldset>');
        
        return chunk;
    }
}
