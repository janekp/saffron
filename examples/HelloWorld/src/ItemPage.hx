/* Copyright (c) 2012 Janek Priimann */

package;

import saffron.Data;
import saffron.Page;

class ItemPage extends Page {
    public function index(id : Int) : Void {
        Data.query('SELECT ITEMS WHERE id = ?', [ id ], function(err, results) {
            this.render((results.length == 1) ? results[0] : null);
        });
    }
}