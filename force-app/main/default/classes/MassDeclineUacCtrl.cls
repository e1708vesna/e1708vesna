/**
 * @author (s)    : Brite
 * @description   : Controller Class for the MassDeclineUac page
 */
public with sharing class MassDeclineUacCtrl {
    
    private ApexPages.StandardSetController stdsc;
    public String selectedIds {get; set;}
    public List<UpgradeAssuranceContract__c> selectedList {get; set;}
    
    /* SECTION: Class Constructors */
    public MassDeclineUacCtrl(){       
    }
     
    // Standard Controller Constructor
    public MassDeclineUacCtrl(ApexPages.StandardSetController stdsc){
        this.stdsc = stdsc;
        selectedList = (UpgradeAssuranceContract__c[])stdsc.getSelected();
        
        //Put result in the following format for the Lightning page.
        Boolean firstItem = true;
        selectedIds = '[';
        for (UpgradeAssuranceContract__c tmpRec : selectedList) {
            if (firstItem) {
                firstItem = false;
                selectedIds += '{';
            } else {
                selectedIds += '\'},{';
            }
            selectedIds += '\'sobjectType\': \'UpgradeAssuranceContract__c\',\'Id\': \'';
            selectedIds += tmpRec.Id;
        }
        if (selectedIds.length() > 1) {
            selectedIds += '\'}';
        }
        selectedIds += ']';
        
        if (stdsc.getSelected().isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.NoUacSelected));
        }
    }       
}