package psych.states.debug.formats;

typedef UndoStruct =
{
  var action:UndoAction;
  var data:Dynamic;
}

enum abstract UndoAction(String) from String to String
{
  var ADD = "Add Note";
  var DELETE = "Delete Note";
  var MOVE = "Move Note";
  var SELECT = "Select Note";
}
