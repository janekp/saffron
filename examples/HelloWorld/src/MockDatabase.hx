/* Copyright (c) 2012 Janek Priimann */

package;

import saffron.Data;
import saffron.Environment;

typedef MockDatabaseItem = {
    var id : Int;
    var title : String;
    var description : String;
}

class MockDatabase {
    private static var shared : MockDatabase = null;
    
    private var data : DataResult;
    
    public static function adapter() : DataAdapter {
        if(shared == null) {
            shared = new MockDatabase();
        }
        
        return shared;
    }
    
    private function new() {
        this.data = new DataResult();
        this.data.push({ id: 1, title: 'Hello #1', description: 'Hello World!' });
        this.data.push({ id: 2, title: 'Hello #2', description: 'Hello World!!' });
        this.data.push({ id: 3, title: 'Hello #3', description: 'Hello World!!!' });
    }
    
    public function query(q : String, ?p : Array<Dynamic>, fn : DataError -> DataResult -> Void) : Void {
        Environment.setTimeout(function() {
            if(q == 'SELECT * FROM ITEMS') {
                fn(null, this.data);
            } else if(q == 'SELECT * FROM ITEMS WHERE id = ?' && p != null && p.length == 1) {
                var result = new DataResult();
                
                for(i in 0...this.data.length) {
                    if(p[0] == this.data.get(i).id) {
                        result.push(this.data.get(i));
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