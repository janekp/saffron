/* Copyright (c) 2013 Janek Priimann */

package saffron.widgets.data;

import saffron.Template;

#if !client
import saffron.tools.Node;
#end

typedef AdapterItem = {
    var key : String;
    var value : String;
};

interface Adapter implements ArrayAccess<Dynamic> {
    public var length : Int;
    public var render : View -> TemplateChunk -> Int -> TemplateChunk;
}
