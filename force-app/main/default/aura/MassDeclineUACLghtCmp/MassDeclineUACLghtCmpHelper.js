({
  showMessage : function (cmp, message) {
    cmp.set("v.errorMessage", message);
    var divId = cmp.getGlobalId() + "_messageDiv1";   		
    var el = document.getElementById(divId);
    if(el) {
       el.className += el.className ? ' slds-backdrop slds-backdrop_open' : 'slds-backdrop slds-backdrop_open';
         el.style.display = "inline";
    }
  },
  hideMessage : function (cmp) {
      var divId = cmp.getGlobalId() + "_messageDiv1";
      var el = document.getElementById(divId);
      if(el) {
        el.className = "";
        el.style.display = "none";
      }
      cmp.set("v.message", "");
  },
  declineUac: function(cmp, selectedList) {
    var action = cmp.get("c.declineUACBulk");
    action.setParams({
      "upgradeAssuranceContractList" : selectedList
    });
    action.setCallback(this, function(response) {
          var state = response.getState();
          if (cmp.isValid()) {
            if (state === "SUCCESS") {
              if (response.getReturnValue() === "") {
                this.redirectPage();
              } else {
             console.log('*** Due to an error the decline of the UAC failed: ' + response.getReturnValue());
                this.showMessage(cmp, response.getReturnValue());
              }
            } else {
                  console.log('*** Due to an error the decline of the UAC failed: ' + response.getReturnValue());
              this.showMessage(cmp, response.getReturnValue());
            }
          }
      });
    $A.enqueueAction(action);
},
redirectPage: function () {
      if (typeof sforce == 'undefined') {
           window.history.back();
      } else {
           sforce.one.back(true);
      }
  }
})