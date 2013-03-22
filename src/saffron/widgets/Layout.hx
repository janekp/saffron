/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;

#if !client
import js.Node;
#end

class Layout extends Container {
    public static inline var align_left = 0;
    public static inline var align_center = 1;
    public static inline var align_center_or_left_if_large = 2;
    public static inline var align_center_or_right_if_large = 3;
    public static inline var align_right = 4;
    
    private var align : Int = Layout.align_left;
    private var columns : Int = 1;
    
    public function new(?id : String) {
        super(id);
    }
    
    public function getAlign() : Int {
        return this.align;
    }
    
    public function setAlign(align : Int) : Void {
        this.align = align;
    }
    
    public function getColumns() : Int {
        return this.columns;
    }
    
    public function setColumns(columns : Int) : Void {
        this.columns = columns;
    }
    
    public override function render(chunk : TemplateChunk) : TemplateChunk {
        var klass;
        
        if(this.columns == 1) {
            klass = 'one columns';
        } else if(this.columns == 2) {
            klass = 'two columns';
        } else if(this.columns == 3) {
            klass = 'three columns';
        } else if(this.columns == 4) {
            klass = 'four columns';
        } else if(this.columns == 5) {
            klass = 'five columns';
        } else if(this.columns == 6) {
            klass = 'six columns';
        } else if(this.columns == 7) {
            klass = 'seven columns';
        } else if(this.columns == 8) {
            klass = 'eight columns';
        } else if(this.columns == 9) {
            klass = 'nine columns';
        } else if(this.columns == 10) {
            klass = 'ten columns';
        } else if(this.columns == 11) {
            klass = 'eleven columns';
        } else if(this.columns == 12) {
            klass = 'twelve columns';
        } else if(this.columns == 13) {
            klass = 'thirteen columns';
        } else if(this.columns == 14) {
            klass = 'fourteen columns';
        } else if(this.columns == 15) {
            klass = 'fifteen columns';
        } else if(this.columns == 16) {
            klass = 'sixteen columns';
        } else {
            klass = 'one columns';
        }
        
        if(this.align == Layout.align_center) {
            klass = klass + ' centered';
        } else if(this.align == Layout.align_center_or_left_if_large) {
            klass = klass + ' left-if-large';
        } else if(this.align == Layout.align_center_or_right_if_large) {
            klass = klass + ' right-if-large';
        } else if(this.align == Layout.align_right) {
            klass = klass + ' right';
        }
        
        chunk = chunk.write('<div id="' + this.getId() + '" class="' + klass + '">');
        
        if(this.children != null) {
            for(child in this.children) {
                chunk = child.render(chunk);
            }
        }
        
        chunk = chunk.write('</div>');
        
        return chunk;
    }
}
