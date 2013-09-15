/* Copyright (c) 2013 Janek Priimann */

package;

import saffron.Handler;

class IndexHandler extends Handler {
    public function index() : Void {
        this.render({ "A": "B" });
    }
    
    public function edit() : Void {
    	this.render({ "B": "C" });
    }
}