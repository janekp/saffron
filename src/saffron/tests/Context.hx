/* Copyright (c) 2013 Janek Priimann */

package saffron.tests;

import saffron.tools.Node;

@:require(test) class Context {
    public static var outputPath : String = null;
    
    public static function main() {
        var runner = new Runner({ filename: outputPath });
        
        runner.addSuites('*');
        runner.wait(function(code) { Node.process.exit(code); });
        runner.execute();
    }
}
