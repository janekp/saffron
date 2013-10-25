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
	var customer : String;
	var invoice : Dynamic;
	var description : String;
	var metadata : Dynamic;
};

typedef StripeCustomersCreateOptions = {
	?account_balance : Int,
	?card : Dynamic,
	?coupon : Dynamic,
	?description : String,
	?email : String,
	?metadata : Dynamic,
	?plan : Dynamic,
	?quantity : Int,
	?trial_end : Int
};

typedef StripeCustomer = {
	var id : String;
	var object : String;
	var created : Int;
	var livemode : Bool;
	var description : String;
	var email : String;
	var delinquent : Bool;
	var metadata : Dynamic;
	var subscription : Dynamic;
	var discount : Dynamic;
	var account_balance : Int;
	var cards : Array<Dynamic>;
	var default_card : Dynamic;
};

typedef StripePromise = {
	@:overload(function(ok_fn : Dynamic -> Void) : StripePromise {})
	public function then(ok_fn : Dynamic -> Void, error_fn : Dynamic -> Void) : StripePromise;
};

typedef StripeCharges = {
	public function create(options : StripeChargesCreateOptions) : StripePromise;
};

typedef StripeCustomers = {
	public function create(options : StripeCustomersCreateOptions) : StripePromise;
};

extern class Stripe {
	public static function create(key : String) : Stripe;
	
	public var charges : StripeCharges;
	public var customers : StripeCustomers;
	
    private static function __init__() : Void untyped {
        if(saffron.tools == null) {
			saffron.tools = { };
		}
		
		saffron.tools.Stripe = {
			create: function(key) {
				return Node.require('stripe')(key);
			}
		};
    }
}
