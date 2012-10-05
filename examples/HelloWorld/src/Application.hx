/* Copyright (c) 2012 Janek Priimann */

package;

import saffron.Server;

class Application {
    public static function main() {
        var server = new Server();
        
        // Config
        server.config(root, 'static');
        server.config(database, MockDatabase.connect);
        
        // Routes
        server.get('/', IndexPage);
        server.get('/view/:id{0-9}', ItemPage);
        
        // Start the client/server
        server.start(3000);
    }
}