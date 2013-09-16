/* Copyright (c) 2013 Janek Priimann */

package saffron.tools;

import js.Node;

extern class BCrypt {
	public static function genSalt(rounds : Int, fn : String -> String -> Void) : Void;
    public static function genSaltSync(rounds : Int) : String;
    
    @:overload(function(password : String, rounds : Int, fn : String -> String -> Void) : Void {})
    public static function hash(password : String, hash : String, fn : String -> String -> Void) : Void;
    @:overload(function(password : String, rounds : Int) : String {})
    public static function hashSync(password : String, hash : String) : String;
    
    public static function compare(password : String, hash : String, fn : String -> Bool -> Void) : Void;
    public static function compareSync(password : String, hash : String) : Bool;
    
    public static function getRounds(hash : String) : Int;
    
    private static function __init__() : Void untyped {
        if(saffron.tools == null) {
            saffron.tools = { };
        }
        
        saffron.tools.BCrypt = Node.require('bcrypt');
    }
}
