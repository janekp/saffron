/* Copyright (c) 2013 Janek Priimann */

package saffron.tools;

import js.Node;

typedef FormidableFile = {
    public var size : Int;
    public var name : String;
    public var type : String;
    public var lastModifiedDate : Date;
    public var hash : String;
    public var path : String;
    
    public function toJSON() : String;
}

@:native('Array') extern class FormidableFields {
    public inline function get(name : String) : String {
        return untyped this[name];
    }
}

@:native('Array') extern class FormidableFiles {
    public inline function get(name : String) : FormidableFile {
        return untyped this[name];
    }
}

typedef FormidablePart = {
    public var filename : String;
    
    public function addListener(event : String, fn : Void -> Void) : Void;
}

extern class Formidable {
    public function new() : Void;
    
    public var encoding : String;
    public var uploadDir : String;
    public var keepExtensions : Bool;
    public var type : String;
    public var maxFieldsSize : Int;
    public var hash : Dynamic;
    public var bytesReceived : Int;
    public var bytesExpected : Int;
    
    public function parse(req : NodeHttpServerReq, fn : NodeErr -> FormidableFields -> FormidableFiles -> Void) : Void;
    public function on(event : String,fn : NodeListener) : Dynamic;
    public function onPart(fn : FormidablePart -> Void) : Void;
    public function handlePart(part : FormidablePart) : Void;
    
    private static function __init__() : Void untyped {
        try {
        	if(saffron.tools == null) {
        		saffron.tools = { };
        	}
        	
            saffron.tools.Formidable = Node.require('formidable').IncomingForm;
        }
        catch(e : Dynamic) {
        }
    }
}
