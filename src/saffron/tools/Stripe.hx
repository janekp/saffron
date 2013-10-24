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

typedef StripeCharge = {
	var id : String;
	var object : String;
	var created : Int;
	var livemode : Bool;
	var paid : Bool;
	var amount : Int;
	var currency : String;
	var refunded : Bool;
	var card : Dynamic;
	var captured : Bool;
	var balance_transaction : String;
	var failure_message : String;
	var failure_code : Int;
	var amount_refunded : Int;
	var customer : Dynamic;
	var invoice : Dynamic;
	var description : String;
	var metadata : Dynamic;
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
