/* Copyright (c) 2013 Janek Priimann */

package;

import saffron.Page;
import saffron.Template;
import saffron.Widget;
import saffron.widgets.*;

class IndexPage extends Page {
    private function findButton1() : Button {
        return this.findWidgetById('button1', function(button : Button, id : String) : Widget {
            if(button == null) {
                button = new Button(id);
            }
            
            button.setTitle('Button 1 & <');
            
            return button;
        });
    }
    
    @:keep private function button1(chunk : TemplateChunk) : TemplateChunk {
        return this.findButton1().render(chunk);
    }
    
    private function findList1() : TableView {
        return this.findWidgetById('list1', function(tableView : TableView, id : String) : Widget {
            if(tableView == null) {
                tableView = new TableView(id);
            }
            
            tableView.setAdapter([ 'Item #1', 'Item #2', 'Item #3' ]);
            
            return tableView;
        });
    }
    
    @:keep private function list1(chunk : TemplateChunk) : TemplateChunk {
        return this.findList1().render(chunk);
    }
    
    private function findChoices1() : SingleChoiceButton {
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
    
    @:keep private function choices1(chunk : TemplateChunk) : TemplateChunk {
        return this.findChoices1().render(chunk);
    }
    
    private function findChoices2() : SingleChoiceButton {
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
    
    @:keep private function choices2(chunk : TemplateChunk) : TemplateChunk {
        return this.findChoices2().render(chunk);
    }
    
    private function findChoices3() : MultiChoiceButton {
        return this.findWidgetById('choices3', function(choice : MultiChoiceButton, id : String) : Widget {
            if(choice == null) {
                choice = new MultiChoiceButton(id);
            }
            
            choice.setAdapter([
                { key: 'Item #1', value: 'a' },
                { key: 'Item #2', value: 'b' },
                { key: 'Item #3', value: 'c' }
            ]);
            
            return choice;
        });
    }
    
    @:keep private function choices3(chunk : TemplateChunk) : TemplateChunk {
        return this.findChoices3().render(chunk);
    }
}