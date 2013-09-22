/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets;

import saffron.Template;
import saffron.tools.Express;

class Page extends saffron.Page {
	private var container : Container;
	
	public function new(request : ExpressRequest, response : ExpressResponse, template : String) {
    	super(request, response, template);
    	this.container = new Container();
    }
    
    public override function render(?params : Dynamic, ?template : String, ?status : Int) : Void {
    	Template.stream('__saffron', Template.makeBase({
			saffron: function(chunk : TemplateChunk, ctx : TemplateContext) : TemplateChunk {
				return this.container.render(chunk);
			}
		})).pipe(this.response);
    }
}
