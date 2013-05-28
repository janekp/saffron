/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;
import saffron.tools.Text;

#if !client
import saffron.tools.Node;
#end

class SingleChoiceButton extends saffron.widgets.data.View {
    public static inline var type_popup = 0;
    public static inline var type_radio = 1;
    
    private static inline var key_selected = 'selected';
    private static inline var key_type = 'type';
    
    public function new(?id : String) {
        super(id);
    }
    
    public function getSelectedIndex() : Int {
        return Std.parseInt(this.get(key_selected));
    }
    
    public function setSelectedIndex(selected : Int) : Void {
        this.set(key_selected, '' + selected);
    }
    
    public function getType() : Int {
        return Std.parseInt(this.get(key_type));
    }
    
    public function setType(type : Int) : Void {
        this.set(key_type, '' + type);
    }
    
    private override function renderItem(chunk : TemplateChunk, row : Int) : TemplateChunk {
        var selected = (this.getSelectedIndex() == row) ? true : false;
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
        
        return (this.getType() == type_popup)
            ? chunk.write(
                '<option value="' + value + '"' +
                ((selected) ? ' selected="selected"' : '') + '>' + title + '</option>')
            : chunk.write(
                '<label for="' + this.getId() + '_' + row + '">' + 
                '<input type="radio" id="' + this.getId() + '_' + row +
                '" name="' + this.getId() + '" value="' +
                value + '"' + ((selected) ? ' checked="checked"' : '') +
                ' /><span>' + title + '</span></label>');
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        if(this.getType() == type_popup) {
            chunk = chunk.write('<select id="' + this.getId() + '"' + ((this.getClass() != null) ? ' class="' + this.getClass() + '">' : '>'));
            chunk = this.renderItems(chunk);
            chunk = chunk.write('</select>');
        } else {
            chunk = chunk.write('<fieldset id="' + this.getId() + '"' + ((this.getClass() != null) ? ' class="' + this.getClass() + '">' : '>'));
            chunk = this.renderItems(chunk);
            chunk = chunk.write('</fieldset>');
        }
        
        return chunk;
    }
}
