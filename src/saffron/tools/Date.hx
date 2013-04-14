/* Copyright (c) 2012 Janek Priimann */

package saffron;

@:native("Date") extern class Date {
    @:overload(function(year : Int, month : Int, day : Int, hours : Int, minutes : Int, seconds : Int, milliseconds : Int) : Void {})
    @:overload(function(dateString : String) : Void {})
    @:overload(function(milliseconds : Int) : Void {})
    public function new() : Void;
    
    public static function now() : Date;
    public static function parse(str : String) : Date;
    @:overload(function(year : Int, month : Int, day : Int, hours : Int, minutes : Int, seconds : Int, milliseconds : Int) : Void {})
    public static function UTC(year : Int, month : Int, day : Int) : Date;
    
    public function getDate(): Int;
    public function getDay(): Int;
    public function getFullYear(): Int;
    public function getHours(): Int;
    public function getMilliseconds(): Int;
    public function getMinutes(): Int;
    public function getMonth(): Int;
    public function getSeconds() : Int;
    
    public function getTime() : Int;
    public function getTimezoneOffset() : Int;
    
    public function getUTCDate(): Int;
    public function getUTCDay(): Int;
    public function getUTCFullYear(): Int;
    public function getUTCHours(): Int;
    public function getUTCMilliseconds(): Int;
    public function getUTCMinutes(): Int;
    public function getUTCMonth(): Int;
    public function getUTCSeconds() : Int;
    
    public function toString() : String;
    public function toDateString() : String;
    public function toTimeString() : String;
    public function toISOString() : String;
    public function toUTCString() : String;
    
    public function valueOf() : Int;
}
