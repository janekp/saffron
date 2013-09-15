/* Copyright (c) 2012 Janek Priimann */

package saffron.tools;

@:native("RegExp") extern class RegExp {
    public var global : Bool;
    public var lastIndex : Int;
    
    public function new(pattern : String, ?modifiers : String) : Void;
    public function exec(str : String) : Array<String>;
    public function test(str : String) : Bool;
}