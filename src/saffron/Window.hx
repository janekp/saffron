/* Copyright (c) 2012 Janek Priimann */

package saffron;

@:require(client) @:native("window") extern class Window {
    public static var location : js.Dom.Location;
    public static var onload : js.Dom.Event -> Void;
}
