/* Copyright (c) 2013 Janek Priimann */

package saffron.tools;

#if !client
import saffron.tools.Node;
#end

class Text {
    public static function escapeHtml(html : String) : String {
        return (html != null) ? html.split('&').join('&amp;').split('<').join('&lt;').split('"').join('&quot;').split("'").join('&apos;') : '';
    }
    
    public static function escapeHtmlParam(key : String, value : String) : String {
        return (value != null) ? key + '="' + Text.escapeHtml(value) + '"' : '';
    }
    
    public static function escapeHtmlParamUnsafe(key : String, value : String) : String {
        return (value != null) ? key + '="' + value + '"' : '';
    }
}
