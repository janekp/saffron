/* Copyright (c) 2013 Janek Priimann */

package;

import saffron.Page;

class IndexPage extends Page {
    public function index() : Void {
        this.render();
    }
    
    public function upload() : Void {
        var file = (this._ctx.files != null) ? this._ctx.files.get('upload') : null;
        
        this.render({
            title: (this._ctx.fields != null) ? this._ctx.fields.get('title') : '--',
            path: (file != null) ? file.path : '--',
            size: (file != null) ? file.size : 0
        });
    }
}