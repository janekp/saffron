/* Copyright (c) 2012 Janek Priimann */

package;

import saffron.Page;

class ItemPage extends Page {
    public function index(id : Int) : Void {
        this.query('SELECT * FROM ITEMS WHERE id = ?', [ id ], function(err, results) {
            this.render((results.length == 1) ? results[0] : null);
        });
    }
}