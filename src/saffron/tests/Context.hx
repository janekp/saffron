/* Copyright (c) 2013 Janek Priimann */

package saffron.tests;

import js.Node;

@:require(test) class Context {
    public static function main() {
        var runner = new Runner();
        
        runner.addSuites('*');
        runner.wait(function(code) { Node.process.exit(code); });
        runner.execute();
    }
}
