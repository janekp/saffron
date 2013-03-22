/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;

#if !client
import js.Node;
#end

class Page extends saffron.Page {
    private var state : Dynamic;
    
    public static function renderHeader(chunk : TemplateChunk, ?title : String = 'Untitled', ?stylesheet : String = 'stylesheet.css', ?language : String = 'en', ?encoding : String = 'utf-8') : TemplateChunk {
        return chunk.write(
            '<!DOCTYPE html>' + 
            '<!--[if lt IE 7 ]><html class="ie ie6" lang="en"> <![endif]-->' +
            '<!--[if IE 7 ]><html class="ie ie7" lang="en"> <![endif]-->' +
            '<!--[if IE 8 ]><html class="ie ie8" lang="en"> <![endif]-->' + 
            '<!--[if (gte IE 9)|!(IE)]><!--><html lang="en"> <!--<![endif]-->' +
            '<head>' + 
	        '<meta charset="' + encoding + '" />' + 
	        '<title>' + title + '</title>' +
	        '<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />' +
	        '<link rel="stylesheet" href="' + stylesheet + '" />' +
	        //'<link rel="shortcut icon" href="images/favicon.ico" />' +
	        //'<link rel="apple-touch-icon" href="images/apple-touch-icon-57.png" />' + 
	        //'<link rel="apple-touch-icon" sizes="72x72" href="images/apple-touch-icon-72.png" />' + 
	        //'<link rel="apple-touch-icon" sizes="114x114" href="images/apple-touch-icon-114.png" />' + 
	        '<!--[if lt IE 9]><script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script><![endif]-->' +
	        '</head><body>');
    }
    
    public static function renderFooter(chunk : TemplateChunk) : TemplateChunk {
        return chunk.write('</body></html>');
    }
    
    private function findWidgetById(id : String, ?fn : Dynamic -> String -> Widget) : Dynamic {
        var widget;
        
        if(id == null) {
            return null;
        }
        
        if(this.state == null) {
            this.state = { _w: { } };
        }
        
        widget = this.state._w[untyped id];
        
        if(widget == null && fn != null) {
            widget = fn(null, id);
            this.state._w[untyped id] = widget;
        }
        
        return widget;
    }
}
