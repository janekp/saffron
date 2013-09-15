saffron
=======

Saffron is an experimental web-development framework prototype for Haxe/NodeJS. The main ideas are:

	* Express
	* Macros and templates
    * allow code-sharing between server/client
    * client- and server-side rendering
    * intelligent data preloading
    * secure database access
    * lightweight runtime

It makes development with Haxe and Express much easier. For example:

	// IndexHandler.hx
	class IndexHandler extends Handler {
		public function index() : Void {
			this.render({ });
		}
	
		public function hello() : Void {
			this.render({ });
		}
		
		private function world() : Void {
		}
	}
	
	// OtherHandler.hx
	class OtherHandler extends Handler {
		public function edit(id : Int) : Void {
			this.render({ "id": id });
		}
	}
	
	// Application.hx
    class Application {
		public static function main() {
			var server = new Server();
			
			// Routes
			server.get('/:action', IndexHandler);
			server.post('/:action{edit}/:id', OtherHandler);
			
			// Start the client/server
			server.start(3000);
		}
	}
	
	// Gets compiled to JS
	var Application = function() { }
	Application.main = function() {
		var server = new saffron.Server();
		server.express.get("/",function(req,res) {
			new IndexHandler(req,res).index();
		});
		server.express.get("/hello",function(req,res) {
			new IndexHandler(req,res).hello();
		});
		server.express.post("/edit",function(req,res) {
			new OtherHandler(req,res).edit(req.params.id);
		});
		server.start(3000);
	}

Install
=======

    haxelib git saffron https://github.com/janekp/saffron.git src
    
    # Node dependencies
    sudo npm install -g express
    
    # Optional dependencies
    sudo npm install -g mysql generic-pool mapstrace formidable@latest
    sudo npm install -g jasmine-node winston send
    
    # Node can't find modules?
    sudo npm link <MODULENAME>