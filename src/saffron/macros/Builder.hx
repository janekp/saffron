/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron.macros;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

@:allow(saffron.Macros) class Builder {
	static function generatePage() : Array<Field> {
        var type = Context.getLocalClass().get();
        var fields = Context.getBuildFields();
        var autogen = new Array<Field>();
        var widgetMeta;
        
        for(field in fields) {
            if(!Helper.contains(field.access, Access.AStatic)) {
                if((widgetMeta = Helper.containsMeta(field, ':widget')) != null) {
                	var widgetName = field.name;
                	var widgetGetterName = 'get' + widgetName.charAt(0).toUpperCase() + widgetName.substring(1);
                	var widgetId = (widgetMeta.length > 0) ? widgetMeta : widgetName;
                	var widgetArgs = 0;
                	var widgetType = switch(field.kind) {
                		case FFun(f):
                			widgetArgs = f.args.length;
                			
                			switch(f.args[0].type) {
                				case TPath(p):
                					(p.pack.length > 0) ? p.pack.join('.') + '.' + p.name : p.name;
                				default:
                					null; // TODO: Maybe TemplateWidgetChunk ?!?
                			}
                		default:
                			null;
                	};
                	var egetter = (widgetArgs == 1) ? macro function(?params : Dynamic) {
                		return this.findWidgetById($v{widgetId}, function() : Dynamic {
							var widget = new $widgetType((params != null && params.id != null) ? params.id : $v{widgetId});
							
							this.$widgetName(widget);
							
							return widget;
						});
                	} : macro function(?params : Dynamic) {
                		return this.findWidgetById($v{widgetId}, function() : Dynamic {
							var widget = new $widgetType((params != null && params.id != null) ? params.id : $v{widgetId});
							
							this.$widgetName(widget, params);
							
							return widget;
						});
                	}
                	             	
                	autogen.push({
                        name: widgetGetterName,
                        pos: field.pos,
                        meta: [ { name: ':keep', pos: field.pos, params: new Array<Expr>() } ],
                        access: [ Access.APrivate ],
                        doc: null,
                        kind: FieldType.FFun(switch(egetter.expr) {
							case EFunction(_name, f):
								f;
							default:
								null;
						})
                    });
                }
            }
        }
        
        return fields.concat(autogen);
    }
    
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
