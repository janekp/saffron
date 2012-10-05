/* Copyright (c) 2012 Janek Priimann */

package;

import saffron.Page;

class IndexPage extends Page {
    public function index() : Void {
        this.database().query('SELECT ITEMS', function(err, results) {
            this.render({ items: results });
        });
    }
}