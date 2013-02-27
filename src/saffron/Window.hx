/* Copyright (c) 2012 Janek Priimann */

package saffron;

@:require(client) @:native("window") extern class Window {
    public static var location : js.html.Location;
    public static var onload : js.html.Event -> Void;
}
