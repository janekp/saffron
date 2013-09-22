/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;

typedef NavigationItem = {
    var action : String;
    var title : String;
};

class Navigation extends Widget {
    private static inline var key_selected = 'selected';
    
    private var items : Array<NavigationItem> = null;
    
    public function new(?id : String) {
        super(id);
        this.setClass('navigation');
    }
    
    public function getSelectedIndex() : Int {
        return Std.parseInt(this.get(key_selected));
    }
    
    public function setSelectedIndex(selected : Int) : Void {
        this.set(key_selected, '' + selected);
    }
    
    public function selectAction(action : String) : Bool {
        if(this.items != null) {
            var i = 0, c = this.items.length;
            
            while(i < c) {
                if(this.items[i].action == action) {
                    this.setSelectedIndex(i);
                    return true;
                }
                
                i++;
            }
        }
        
        this.setSelectedIndex(-1);
        
        return false;
    }
    
    public function getItems() : Array<NavigationItem> {
        return this.items;
    }
    
    public function setItems(items : Array<NavigationItem>) : Void {
        this.items = items;
    }
    
    public function addItem(item : NavigationItem) : Void {
        if(this.items == null) {
            this.items = new Array<NavigationItem>();
        }
        
        this.items.push(item);
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        chunk = chunk.write('<ul' + this.generateStandardAttributes() + '>');
        
        if(this.items != null) {
            var i = 0, c = this.items.length, s = this.getSelectedIndex();
            var item;
            
            while(i < c) {
                item = this.items[i];
                chunk = chunk.write('<li' + ((i == s) ? ' class="selected">' : '>') + '<a href="' + this.generateHtml(item.action) + '">' + this.generateHtml(item.title) + '</a></li>');
                i++;
            }
        }
        
        chunk = chunk.write('</ul>');
        
        return chunk;
    }
}
