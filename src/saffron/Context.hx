/* Copyright (c) 2012 Janek Priimann */

package saffron;

#if !client

import js.Node;

typedef ContextUrl = NodeUrlObj;

typedef Context = { > ContextUrl,
    var cookies : Cookies;
    var id : String;
    var server : Server;
    var template : String;
    var token : Dynamic;
    var request : NodeHttpServerReq;
    var response : NodeHttpServerResp;
}

#else

typedef ContextUrl = {
    var href : String;
    var host : String;
    var protocol : String;
    var auth : String;
    var hostname : String;
    var port : String;
    var pathname : String;
    var search : String;
    var query : Dynamic;
    var hash : String;
}

typedef Context = { > ContextUrl,
    var cookies : Cookies;
    var id : String;
    var client : Client;
    var template : String;
    var token : Dynamic;
    var resume : Void -> Void;
    var pause : Void -> Void;
    var destroy : Void -> Void;
}

#end

typedef ContextHandler = Context -> Void;

typedef ContextRegex = {
    var pattern : Environment.EnvironmentRegExp;
    var func : ContextHandler;
}
