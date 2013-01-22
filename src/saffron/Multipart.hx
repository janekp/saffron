/* Copyright (c) 2013 Janek Priimann */

package saffron;

#if !client

import js.Node;

typedef MultipartFile = {
    public var size : Int;
    public var name : String;
    public var type : String;
    public var lastModifiedDate : Date;
    public var hash : String;
    public var path : String;
    
    public function toJSON() : String;
}

@:native('Array') extern class MultipartFields {
    public inline function get(name : String) : String {
        return untyped this[name];
    }
}

@:native('Array') extern class MultipartFiles {
    public inline function get(name : String) : MultipartFile {
        return untyped this[name];
    }
}

typedef MultipartPart = {
    public var filename : String;
    
    public function addListener(event : String, fn : Void -> Void) : Void;
}

extern class Multipart {
    public function new() : Void;
    
    public var encoding : String;
    public var uploadDir : String;
    public var keepExtensions : Bool;
    public var type : String;
    public var maxFieldsSize : Int;
    public var hash : Dynamic;
    public var bytesReceived : Int;
    public var bytesExpected : Int;
    
    public function parse(req : NodeHttpServerReq, fn : NodeErr -> MultipartFields -> MultipartFiles -> Void) : Void;
    public function on(event : String,fn : NodeListener) : Dynamic;
    public function onPart(fn : MultipartPart -> Void) : Void;
    public function handlePart(part : MultipartPart) : Void;
    
    private static function __init__() : Void untyped {
        try {
            saffron.Multipart = Node.require('formidable').IncomingForm;
        }
        catch(e : Dynamic) {
        }
    }
}

#else

typedef Multipart = { }

#end