saffron
=======

Saffron is an experimental web-development framework prototype for Haxe/NodeJS. The main ideas are:

    * allow code-sharing between server/client
    * client- and server-side rendering
    * secure database access
    * lightweight runtime

Saffron allows to write code that may even contain raw SQL and re-use it on the client-side securely.
The database is never exposed directly. For example:

    class ItemPage extends Page {
        public function index(id : Int) : Void {
            this.query('SELECT * FROM ITEMS WHERE id = ?', [ id ], function(err, results) {
                this.render(results);
            });
        }
    }

On the server-side it's compiled to:

    var ItemPage = function(context) {
    	saffron.Page.call(this,context);
    };
    ItemPage.__super__ = saffron.Page;
    ItemPage.prototype = $extend(saffron.Page.prototype,{
    	index: function(id) {
    		var _g = this;
    		saffron.Data.adapter().query("SELECT * FROM ITEMS WHERE id = ?", [ id ],function(err,results) {
    			_g.render(results);
    		});
    	}
    });
    
    saffron.Server.__remoteHandlers = [
        {
            id: "bf4d84",
            query: "SELECT * FROM ITEMS WHERE id = ?",
            args: 'I'
        }
    ];

On the client-side it's compiled to:

    var ItemPage = function(context) {
    	saffron.Page.call(this,context);
    };
    ItemPage.__super__ = saffron.Page;
    ItemPage.prototype = $extend(saffron.Page.prototype,{
    	index: function(id) {
    		var _g = this;
    		saffron.Data.adapter().query("bf4d84", [ id ],function(err,results) {
    			_g.render(results);
    		});
    	}
    });
