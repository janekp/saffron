/* Copyright (c) 2012 - 2013 Janek Priimann */

package saffron.macros;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;

typedef VarAccess =  haxe.macro.Type.VarAccess;

typedef AdapterQueryTree = {
    var condition : Expr;
    var left : Array<Dynamic>;
    var right: Array<Dynamic>;
}

@:allow(saffron.Macros) class Adapter {
    private static function resolveQuery(q : Expr, r : Array<Dynamic>) : Array<Dynamic> {
        switch(q.expr) {
            case EBinop(op, e1, e2): {
                if(op == Binop.OpAdd) {
                    Adapter.resolveQuery(e1, r);
                    Adapter.resolveQuery(e2, r);
                } else {
                    Context.error('Unexpected operator in query', q.pos);
                }
            };
            case EConst(c): {
                switch(c) {
                    case CString(s): {
                        if(r.length > 0 && Std.is(r[r.length - 1], String)) {
                            r.push(r.pop() + s);
                        } else {
                            r.push(s);
                        }
                    };
                    default: {
                        Context.error('Unexpected identifier in query', q.pos);
                    }
                }
            };
            case EField(e, f): {
                var type = Context.getType(Helper.stringify(e));
                var found = false;
                
                if(type != null) {
                    switch(type) {
                        case TInst(t, _params): {
                            for(st in t.get().statics.get()) {
                                if(st.name == f) {
                                    switch(st.kind) {
                                        case FVar(vr, vw): {
                                            // static inline var x = 'x'
                                            if(vr == VarAccess.AccInline && vw == VarAccess.AccNever) {
                                                var sq = Context.getTypedExpr(st.expr());
                                                
                                                switch(sq.expr) {
                                                    case EConst(_c): {
                                                        resolveQuery(sq, r);
                                                        found = true;
                                                    };
                                                    default: { };
                                                }
                                            }
                                        }
                                        default: { };
                                    }
                                    break;
                                }
                            }
                        };
                        default: { };
                    }
                }
                
                if(!found) {
                    Context.error('The value of ' + Helper.stringify(e) + '.' + f + ' cannot be determined for the query.', q.pos);
                }
            };
            case EParenthesis(e): {
                Adapter.resolveQuery(e, r);
            };
            case ETernary(econd, eif, eelse): {
                var tree : AdapterQueryTree = {
                    condition: econd,
                    left: Adapter.resolveQuery(eif, new Array<Dynamic>()),
                    right: Adapter.resolveQuery(eelse, new Array<Dynamic>())
                };
                
                r.push(tree);
            };
            default: {
                Context.error('Unexpected keyword in query', q.pos);
            };
        }
        
        return r;
    }
    
    private static function reduceQuery(query : Array<Dynamic>, depth : Int) : String {
        var result : String = '';
        
        for(q in query) {
            if(depth > 0) {
                for(i in 0...depth) {
                    result += '\t';
                }
            }
            
            if(Std.is(q, String)) {
                result += Std.string(q);
            } else {
                result += reduceQuery(q.left, depth + 1) + reduceQuery(q.right, depth + 1);
            }
        }
        
        return result;
    }
    
    private static function saltedQuery(query : Array<Dynamic>, left : Expr) : Expr {
        var ensure = function(e : Expr, ch : String) : Expr {
            return (e != null) ? e : { expr: EConst(CString(ch)), pos: Context.currentPos() };
        };
        var right : Expr = null;
        
        for(q in query) {
            if(!Std.is(q, String)) {
                if(right != null) {
                    left = (left != null) ? { expr: EBinop(OpAdd, left, right), pos: Context.currentPos() } : right;
                }
                
                right = { expr: EParenthesis({
                    expr: ETernary(
                        q.condition,
                        ensure(saltedQuery(q.left, null), 'L'),
                        ensure(saltedQuery(q.right, null), 'R')),
                    pos: Context.currentPos()
                }), pos: Context.currentPos() };
            }
        }
        
        return (right != null) ? ((left != null) ? { expr: EBinop(OpAdd, left, right), pos: Context.currentPos() } : right) : left;
    }
    
    static function generateDataQuery(ctx : Expr, q : Expr, p : Expr, fn : Expr) : Expr {
#if (client || server)
        var resolvedQuery = resolveQuery(q, new Array<Dynamic>());
        var reducedQuery = reduceQuery(resolvedQuery, 0);
        var saltedQuery = haxe.crypto.Sha1.encode(reducedQuery);
#end
        
#if client
        var _q = (resolvedQuery.length == 1 && Std.is(resolvedQuery[0], String))
            ? { expr: EConst(CString(haxe.crypto.Sha1.encode(saltedQuery))), pos: Context.currentPos() }
            : { expr: EObjectDecl([
                    { field: 'id', expr: { expr: EConst(CString(saltedQuery)), pos: Context.currentPos() } },
                    { field: 'params', expr: Adapter.saltedQuery(resolvedQuery, { expr: EConst(CString('')), pos: Context.currentPos() }) }
                ]),
                pos: Context.currentPos()
            };
#else
        var _q = q;
#end
        
        if(switch(p.expr) { case EFunction(_name, _f): true; default: false; }) {
            fn = p;
            p = { expr: EConst(CIdent('null')), pos: Context.currentPos() };
        }
        
#if server
        Router.addRemoteHandler(saltedQuery, resolvedQuery, p);
#end
        
        return macro saffron.Data.adapter().query($_q, $p, $fn);
    }
    
    static function generateDataSubscribe(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
        return Macros.generatePlaceholder();
    }
    
    static function generateDataUnsubscribe(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
        return Macros.generatePlaceholder();
    }
    
    static function generateDataPush(ctx : Expr, q : String, p : Expr, fn : Expr) : Expr {
        return Macros.generatePlaceholder();
    }
    
}

#end
