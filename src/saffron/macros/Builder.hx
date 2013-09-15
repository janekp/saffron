/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron.macros;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

@:allow(saffron.Macros) class Builder {
    static function generateSuite() : Array<Field> {
        var type = Context.getLocalClass().get();
        var fields = Context.getBuildFields();
        var _name = (type.module == type.name || type.module.endsWith('.' + type.name)) ? type.module : type.module + '.' + type.name;
        var _klsn = (type.pack.length > 0) ? type.pack.join('.') + '.' + type.name : type.name;
        var expr = macro function() : Void {
            Suite.all.set('$_name', Type.resolveClass('$_klsn'));
        };
        var func : Function = switch(expr.expr) {
            case EFunction(_name, f):
                f;
            default:
                null;
        };
        
        return fields.concat([ {
            name: '__init__',
            pos: Context.currentPos(),
            meta: [ ],
            access: [ Access.AStatic ],
            doc: null,
            kind: FieldType.FFun(func)
        } ]);
    }
}

#end
