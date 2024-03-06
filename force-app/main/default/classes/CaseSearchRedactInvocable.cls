public class CaseSearchRedactInvocable {
    
    public class NonBulkifiedMethodException extends Exception {}
    
    public class SearchResults {
        Case caseRecord;
        List<EmailMessage> emailList;
    }
    
    
    
    //This method is not bulkified and should only be used in a screenflow
    //When called in bulk, it will throw an exception
    @InvocableMethod(label='Case Search' description='Returns Case (Description) and EmailMessages (Subject, HTMLBody, TextBody) that contain the searchterm.' category='Case')
    public static List<SearchResult> searchCaseAndEmail(List<SearchParameters> parameterList) {
        
        if (parameterList.size() > 1){
            throw new NonBulkifiedMethodException('This invocable action is not bulkified and should only be used in screenflows');
        }        
        List<list<SObject>> searchList = [FIND :parameterList[0].searchTerm IN ALL FIELDS RETURNING Case (Id, Subject, Description WHERE Id =: parameterList[0].caseId) , EmailMessage (Subject, HTMLBody, TextBody WHERE ParentId = :parameterList[0].caseId)];
        SearchResult result = new SearchResult();
        if (searchList[0] != null && searchList[0].size() > 0){
            result.caseRecordId = searchList[0][0].Id;
        }
        if (searchList[1] != null){
			result.emailMessageList = (List<EmailMessage>) searchList[1];
        }
        List<SearchResult> retValue = new List<SearchResult>();
        retValue.add(result);
        return retValue;
    }
    
    public class SearchParameters {
        @InvocableVariable(label='Case Id' required=true)
  		public Id caseId;
        @InvocableVariable(label='Search Term' required=true)
  		public String searchTerm;
        
    }  
    
    public class SearchResult {
        @InvocableVariable
  		public Id caseRecordId;
        @InvocableVariable(label='Email Collection')
  		public List<EmailMessage> emailMessageList;
    }  
    
}