/* Copyright (c) 2012 Janek Priimann */

package;

import saffron.Database;
import saffron.Environment;

typedef MockDatabaseItem = {
    var id : Int;
    var title : String;
    var description : String;
}

class MockDatabase {
    private static var shared : MockDatabase = null;
    
    private var data : Array<MockDatabaseItem>;
    
    public static function connect() : DatabaseAdapter {
        if(shared == null) {
            shared = new MockDatabase();
        }
        
        return shared;
    }
    
    private function new() {
        this.data = new Array<MockDatabaseItem>();
        this.data.push({ id: 1, title: 'Hello #1', description: 'Hello World!' });
        this.data.push({ id: 2, title: 'Hello #2', description: 'Hello World!!' });
        this.data.push({ id: 3, title: 'Hello #3', description: 'Hello World!!!' });
    }
    
    public function exec(q : String, ?p : Array<Dynamic>, fn : DatabaseError -> DatabaseResult -> Void) : Void {
        Environment.setTimeout(function() {
            fn({ code: 'Unsupported', fatal: true }, null);
        }, 10);
    }
    
    public function query(q : String, ?p : Array<Dynamic>, fn : DatabaseError -> Array<Dynamic> -> Void) : Void {
        Environment.setTimeout(function() {
            if(q == 'SELECT ITEMS') {
                fn(null, this.data);
            } else if(q == 'SELECT ITEMS WHERE id = ?' && p != null && p.length == 1) {
                var result : Array<Dynamic> = new Array<Dynamic>();
                
                for(i in 0...this.data.length) {
                    if(p[0] == this.data[i].id) {
                        result.push(this.data[i]);
                        break;
                    }
                }
                
                fn(null, result);
            } else {
                fn({ code: 'InvalidQuery', fatal: true }, null);
            }
        }, 10);
    }
}