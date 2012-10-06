/* Copyright (c) 2012 Janek Priimann */

package;

import saffron.Data;
import saffron.Page;

class IndexPage extends Page {
    public function index() : Void {
        Data.query('SELECT ITEMS', function(err, results) {
            this.render({ items: results });
        });
    }
}