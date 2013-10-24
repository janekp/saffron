/* Copyright (c) 2013 Janek Priimann */

package saffron.tools;

import js.Node;

typedef StripeChargesCreateOptions = {
	amount : Int,
	currency : String,
	?customer : String,
	?card : String,
	?description : String,
	?metadata : Dynamic,
	?capture : Bool,
	?application_fee : Int
};

typedef StripePromise = {
	public function then(ok_fn : Dynamic -> Void, error_fn : Dynamic -> Void) : StripePromise;
};

typedef StripeCharges = {
	public function create(options : StripeChargesCreateOptions) : StripePromise;
};

extern class Stripe {
	public function new(key : String) : Void;
	
	public var charges : StripeCharges;
	
    private static function __init__() : Void untyped {
        try {
            if(saffron.tools == null) {
                saffron.tools = { };
            }
            
            saffron.tools.Stripe = Node.require('stripe-node');
        }
        catch(e : Dynamic) {
        }
    }
}
