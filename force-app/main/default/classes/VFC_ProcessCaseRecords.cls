public class VFC_ProcessCaseRecords {
      public List<Case> selCaseLst;
    public String caseIds;
    public List<String> caseIdList = new List<String>();
public string previouspage = ApexPages.currentPage().getParameters().get('retURL');   
    
    public string getCaseIds() {
      return caseIds;  
    } 
    public List<string> getCaseIdList() {
      return caseIdList;  
    } 
    
      // Constructor
      public VFC_ProcessCaseRecords(ApexPages.StandardSetController cntlr){
          
		system.debug('RetUrl: ' + previouspage);
           selCaseLst = cntlr.getSelected(); //get selected records from account list view
           caseIds = '';  
           for(Case c : selCaseLst){
               caseIds += c.Id + ','; //build list of ids string concatenated with comma      
               caseIdList.add(c.Id);
            }
           caseIds = caseIds.removeEnd(','); 
          cntlr.cancel();
      } 

      /*public PageReference redirectToLC(){
            String returnUrl = '/flow/CASE_BulkMergeCases?ids='+caseIds;
            PageReference pgReturnPage = new PageReference(returnUrl);
          
            pgReturnPage.setRedirect(true);
            return pgReturnPage;
      }*/

  }