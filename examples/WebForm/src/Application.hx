/* Copyright (c) 2013 Janek Priimann */

package;

import saffron.Server;

class Application {
    public static function main() {
        var server = new Server();
        
        // Config
        server.config(multipart, function(ctx) { return (ctx.pathname == '/') ? true : false; });
        server.config(root, 'static');
        server.config(tmp, 'tmp');
        
        // Routes
        server.get('/', IndexPage);
        server.post('/', IndexPage.upload);
        
        // Start the client/server
        server.start(3000);
    }
}