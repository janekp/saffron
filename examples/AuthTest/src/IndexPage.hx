/* Copyright (c) 2013 Janek Priimann */

package;

import saffron.Page;

class IndexPage extends Page {
    public function index() : Void {
        this.render({ user: this.cookies().get('session') });
    }
    
    private override function layout() : String {
        return 'layout';
    }
}