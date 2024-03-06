({
  disagreeMessage: function (cmp, event, helper) {
  helper.hideMessage(cmp);
},
  declineUac : function(cmp, event, helper) {
    var selectedList = [];
    selectedList = cmp.get("v.selectedList");
    //console.log('*** selectedList: ' + selectedList);
    
    if (selectedList != "[]") {
      helper.declineUac(cmp, selectedList);
    } else {
      helper.showMessage(cmp, $A.get("$Label.c.NoUacSelected"));
        }
  },
//  cancelUpdate : function(cmp, event, helper) {
  cancelDecline : function(cmp, event, helper) {
    helper.redirectPage();
  }
})