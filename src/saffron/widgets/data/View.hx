/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets.data;

import saffron.Template;

#if !client
import js.Node;
#end

class View extends Widget {
    private var adapter : Adapter = null;
    
    public function getAdapter() : Adapter {
        return this.adapter;
    }
    
    public function setAdapter(adapter : Dynamic) : Void {
        this.adapter = untyped adapter;
    }
    
    private function renderItem(chunk : TemplateChunk, row : Int) : TemplateChunk {
        return chunk;
    }
    
    private function renderItems(chunk : TemplateChunk) : TemplateChunk {
        var i = 0, c = (this.adapter != null) ? this.adapter.length : 0;
        
        if(c > 0) {
            var render : View -> TemplateChunk -> Int -> TemplateChunk = this.adapter.render;
            
            if(render == null) {
                render = function(view, chunk, row) {
                    return this.renderItem(chunk, row);
                };
            }
            
            while(i < c) {
                chunk = render(this, chunk, i);
                i += 1;
            }
        }
        
        return chunk;
    }
}
