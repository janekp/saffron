/* Copyright (c) 2013 Janek Priimann */

package saffron.tests;

import js.Node;
import saffron.tools.Jasmine;
import saffron.tools.JSON;

typedef HelperRequestOptions = {
    ?auth : String,
    ?data : NodeBuffer,
    ?stream : NodeReadStream,
    ?encoding : String,
    ?protocol : String,
    ?host : String,
    ?path : String,
    ?port : Int,
    ?method : String,
    ?headers : Dynamic,
    ?timeout : Int
}

@:require(test) class Helper {
    public static function request(options : HelperRequestOptions, params : Dynamic, fn : Int -> Dynamic -> String -> Void) : Void {
        if(params != null) {
            if(options.method == 'POST' || options.method == 'PUT') {
                options.data = new NodeBuffer(Node.queryString.stringify(params), 'utf8');
                
                if(options.headers == null) {
                    options.headers = { };
                }
                
                options.headers[untyped 'Content-Type'] = 'application/x-www-form-urlencoded';
                options.headers[untyped 'Content-Length'] = (options.data != null) ? options.data.length : 0;
            } else {
                if(options.path == null) {
                    options.path = '/';
                }
                
                options.path +=
                    ((options.path.indexOf('?') == -1) ? '?' : '&') +
                    Node.queryString.stringify(params);
            }
        }
        
        var opt : Dynamic = {
            auth: options.auth,
            host: options.host,
            port: (options.port != null) ? options.port : ((options.protocol == 'https') ? 433 : 80),
            path: (options.path != null) ? options.path : '/',
            method: (options.method != null) ? options.method : 'GET',
            headers: (options.headers != null) ? options.headers : { }
        };
        
        var request = Node.http.request(opt, function(response) {
            var data = '';
            
            response.setEncoding((options.encoding != null) ? options.encoding : 'utf8');
            response.on('data', function (chunk) {
                data += chunk;
            });
            response.on('end', function() {
                var type = response.headers[untyped 'content-type'];
                var result = null;
                
                if(data.length > 0 && (type == null || type == 'application/json')) {
                    try {
                        result = saffron.tools.JSON.parse(data);
                    }
                    catch(e : Dynamic) {
#if debug
                        trace('Unable to parse JSON response: ' + e);
#end
                    }
                } else {
                    result = data;
                }
                
                fn(response.statusCode, result, type);
            });
        });
        
        request.on('socket', function(socket : NodeNetSocket) {
            socket.setTimeout((options.timeout != null) ? options.timeout : 30000, function() {
                request.abort();
            });
        });
        
        request.on('error', function(e) {
            fn(null, e, null);
        });

        if(options.data != null) {
            request.write(options.data);
            request.end();
        } else if(options.stream != null) {
            untyped request.pipe(options.stream);
        } else {
            request.end();
        }
    }
}
