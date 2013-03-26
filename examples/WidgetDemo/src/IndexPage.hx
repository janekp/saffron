/* Copyright (c) 2013 Janek Priimann */

package;

import saffron.Widget;
import saffron.widgets.*;

class IndexPage extends Page {
    @:render private function button1() : Button {
        return this.findWidgetById('button1', function(button : Button, id : String) : Widget {
            if(button == null) {
                button = new Button(id);
            }
            
            button.setTitle('Button 1 & <');
            
            return button;
        });
    }
    
    @:render private function list1() : TableView {
        return this.findWidgetById('list1', function(tableView : TableView, id : String) : Widget {
            if(tableView == null) {
                tableView = new TableView(id);
            }
            
            tableView.setAdapter([ 'Item #1', 'Item #2', 'Item #3' ]);
            
            return tableView;
        });
    }
    
    @:render private function choices1() : SingleChoiceButton {
        return this.findWidgetById('choices1', function(choice : SingleChoiceButton, id : String) : Widget {
            if(choice == null) {
                choice = new SingleChoiceButton(id);
            }
            
            choice.setAdapter([
                { key: 'Item #1', value: 'a' },
                { key: 'Item #2', value: 'b' },
                { key: 'Item #3', value: 'c' }
            ]);
            
            choice.setType(SingleChoiceButton.type_popup);
            
            return choice;
        });
    }
    
    @:render private function choices2() : SingleChoiceButton {
        return this.findWidgetById('choices2', function(choice : SingleChoiceButton, id : String) : Widget {
            if(choice == null) {
                choice = new SingleChoiceButton(id);
            }
            
            choice.setAdapter([
                { key: 'Item #1', value: 'a' },
                { key: 'Item #2', value: 'b' },
                { key: 'Item #3', value: 'c' }
            ]);
            choice.setSelectedIndex(1);
            choice.setType(SingleChoiceButton.type_radio);
            
            return choice;
        });
    }
    
    @:render private function choices3() : MultiChoiceButton {
        return this.findWidgetById('choices3', function(choice : MultiChoiceButton, id : String) : Widget {
            if(choice == null) {
                choice = new MultiChoiceButton(id);
            }
            var p = new Layout(null);
            choice.setAdapter([
                { key: 'Item #1', value: 'a' },
                { key: 'Item #2', value: 'b' },
                { key: 'Item #3', value: 'c' }
            ]);
            
            return choice;
        });
    }
}