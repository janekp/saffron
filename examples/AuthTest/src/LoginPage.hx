/* Copyright (c) 2013 Janek Priimann */

package;

import saffron.Environment;
import saffron.Page;
import saffron.tools.Node;

class LoginPage extends Page {
    public function index(?error : String, ?username : String, ?state : Dynamic) : Void {
        if(state == null) {
            state = { url: this._ctx.href, params: this._ctx.query };
        }
        
        this._ctx.template = 'login';
        this.render({ error: error, user: username, state: new NodeBuffer(Environment.JSON.stringify(state)).toString('base64') });
    }
    
    public function login() : Void {
        var state : Dynamic = null;
                
        if(this.isPost()) {
            var username = this.param('username');
            var password = this.param('password');
            
            try {
                state = Environment.JSON.parse(new NodeBuffer(this.param('state'), 'base64').toString('utf8'));
            }
            catch(e : Dynamic) {
                trace('bad state!');
            }
            
            if(password == 'abc') {
                trace('state=' + Environment.JSON.stringify(state));
                
                this.cookies().set('session', username);
                this.renderRedirect((state != null && Std.is(state.url, String) && state.url != '/login' && state.url != '/logout') ? state.url : '/');
            } else {
                this.index('Incorrect password!', username, state);
            }
        } else {
            this.index();
        }
    }
    
    public function logout() : Void {
        this.cookies().set('session', null);
        this.renderRedirect('/');
    }
}
