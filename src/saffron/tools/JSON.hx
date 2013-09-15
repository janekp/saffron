/* Copyright (c) 2013 Janek Priimann */

package saffron.tools;

@:native("JSON") extern class JSON {
    public static function stringify(obj : Dynamic) : String;
    public static function parse(str : String) : Dynamic;
}