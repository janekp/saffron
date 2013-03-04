/* Copyright (c) 2013 Janek Priimann */

package saffron;

class Chainable {
    public var next : ?Dynamic -> Void;
    
    private var called : Bool;
    private var result : Dynamic;
    private var queue : Array<(?Dynamic -> Void) -> Dynamic -> Void>;
    
    public function new() {
        this.called = false;
        this.queue = null;
        this.next = function(?result : Dynamic) : Void {
            if(this.queue != null && this.queue.length > 0) {
                var fn : (?Dynamic -> Void) -> Dynamic -> Void = this.queue.shift();
                
                fn(this.next, result);
            } else {
                this.called = false;
                this.result = result;
            }
        };
    }
    
    @:overload(function(fn : (?Dynamic -> Void) -> Void) : Chainable {})
    public function add(fn : (?Dynamic -> Void) -> Dynamic -> Void) : Chainable {
        if(this.queue != null && this.queue.length > 0) {
            this.queue.push(fn);
        } else if(this.called) {
            if(this.queue == null) {
                this.queue = new Array<(?Dynamic -> Void) -> Dynamic -> Void>();
            }
            
            this.queue.push(fn);
        } else {
            this.called = true;
            fn(next, this.result);
        }
        
        return this;
    }
}
