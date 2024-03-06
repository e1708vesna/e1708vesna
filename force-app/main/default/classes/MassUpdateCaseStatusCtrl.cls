/**
 * @description Controller class for visualforce page 'Mass Update Case Status'.
 * @author BRITE
 */
public with sharing class MassUpdateCaseStatusCtrl {

    public List<String> selectedCaseIds { get; set; }

    public MassUpdateCaseStatusCtrl (ApexPages.StandardSetController stdsc) {
        List<Case> selectedCases = (Case[]) stdsc.getSelected();
        for (Case c : selectedCases) {
            selectedCaseIds.add(c.Id);
        }
    }

    public PageReference getRedirectUrl(){
        PageReference retUrl = new PageReference('/lightning/o/Case/list');
        retUrl.setRedirect(true);
        return retUrl;
    }

}