/* Copyright (c) 2013 Janek Priimann */

package saffron;

class Locale {
    private static var strings : Dynamic = { };
    private static var code : String = null;
    
    public static function register(code : String, strings : Dynamic) : Void {
        if(Locale.code == null) {
            Locale.code = code;
        }
        
        Locale.strings[untyped code] = untyped strings;
    }
    
    public static function str(key : String) : String {
        var value = null;
        
        if(key != null) {
            value = (Locale.code != null) ? Locale.strings[untyped Locale.code][untyped key] : null;
            
            if(value == null && Locale.strings.en != null) {
                value = Locale.strings.en[untyped key];
            }
        }
        
        return (value != null) ? value : ((key != null) ? key : '');
    }
}