/* Copyright (c) 2013 Janek Priimann */

package;

import saffron.Server;

class Application {
    public static function main() {
        var server = new Server();
        
        // Config
        server.config(root, 'static');
        
        // Routes
        server.get('/', IndexPage);
        
        // Start the client/server
        server.start(3000);
    }
}