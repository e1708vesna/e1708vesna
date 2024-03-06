public class DocuSignNavigationController {
    // opening the DocuSign VF page from within a Flow requires a PageReference
    @AuraEnabled
    public static String getPage(String targetUrl) {
        return new PageReference(targetUrl).getUrl(); 
    } 
}