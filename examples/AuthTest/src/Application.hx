/* Copyright (c) 2013 Janek Priimann */

package;

import js.Node;
import saffron.Context;
import saffron.Server;
import saffron.Template;

class Application {
    public static function auth(ctx : Context, permission : Dynamic, fn : Dynamic -> Int -> Void) : Void {
        if(ctx.cookies != null) {
            var session = ctx.cookies.get('session');
            
            if(session != null) {
                // Validate the session here
                fn(session, null);
            }
        }
        
        fn(null, 403);
    }
    
    public static function login(ctx : Context) : Void {
        new LoginPage(ctx).index();
    }
    
    public static function main() {
        var server = new Server();
        
        // Config
        server.config(auth, Application.auth);
        
        server.addError(403, Application.login);
        
        // Routes
        server.get('/', IndexPage, auth_required);
        server.get('/test', IndexPage, auth_required('com.whatever.err'));
        server.get('/login', LoginPage.login);
        server.post('/login', LoginPage.login);
        server.get('/logout', LoginPage.logout);
        
        // Start the server
        server.start(3000);
    }
}