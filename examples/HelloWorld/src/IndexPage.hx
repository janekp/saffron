/* Copyright (c) 2012 Janek Priimann */

package;

import saffron.Page;

class IndexPage extends Page {
    public function index() : Void {
        this.query('SELECT * FROM ITEMS', function(err, results) {
            this.render({ items: results });
        });
    }
}