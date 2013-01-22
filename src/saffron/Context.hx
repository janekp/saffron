/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron;

#if !client

import js.Node;
import saffron.Multipart;

typedef ContextUrl = NodeUrlObj;

typedef Context = { > ContextUrl,
    var cookies : Cookies;
    var id : String;
    var template : String;
    var token : Dynamic;
    var request : NodeHttpServerReq;
    var response : NodeHttpServerResp;
    var fields : MultipartFields;
    var files : MultipartFiles;
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
