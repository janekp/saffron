saffron
=======

Saffron is an experimental web-development framework prototype for Haxe/NodeJS. The main ideas are:

    * allow code-sharing between server/client
    * client- and server-side rendering
    * intelligent data preloading
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

The Haxe compiler won't include classes and methods that are not used, so it's relatively safe by default.
If want to be sure that certain code is only executed on the server-side then there are two ways:

    // Use compiler metadata
    @:require(server) class Database {
        public static function foo() : Void {
            // Compilation fails if the client tries to access Database.foo()
        }
    }
    
    // Use macros
    public function foo() : Void {
        #if server
        // Server only
        #end
        
        #if client
        // Client only
        #end
    }
    