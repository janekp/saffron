/* Copyright (c) 2013 Janek Priimann */

package saffron;

#if !client
import js.Node;
#end

class Utils {
    public static function escapeHtml(html : String) : String {
        return (html != null) ? html.split('&').join('&amp;').split('<').join('&lt;').split('"').join('&quot;').split("'").join('&apos;') : '';
    }
}
