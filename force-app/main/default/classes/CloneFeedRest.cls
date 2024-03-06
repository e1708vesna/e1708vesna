@RestResource(urlMapping='/Service/*/clonefeed')
global with sharing class CloneFeedRest {
    
	@HttpGet
    global static void getRequest() {
        String caseId = RestContext.request.requestURI.substringBetween('Service/', '/clonefeed');
        EmailMessageCloneHandler.copyFeedFromParent(new List<Id>{caseId});
        RestResponse res = RestContext.response;
        res.statusCode = 200;
        
    }
}