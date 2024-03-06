@isTest
public class RestApiResponseMock implements HttpCalloutMock {
    
    private static final String DEFAULT_PATH_NAME = 'PlaceholderDefaultEndpoint';
    private Map<String, List<responseWrapper>> pathToResponseMap = new Map<String, List<responseWrapper>>();

    /*
     * Wrapper class for HttpResponse it's (optional) corresponding exception to be thrown
     * */
    private class ResponseWrapper {
        HttpResponse response;
        Exception e;
        
        ResponseWrapper(HttpResponse response, Exception e){
            this.response = response;
            this.e = e;
        }
    }
    
    
    /**
     * Adds a mock response with a specific path. Responses are returned First In First Out
     * @param path String containing the last bit of the endpoint url for which to add a response
     * @param response HttpResponse to be returned when the mockservices is used
     *  */
    public void addResponse(String path, HttpResponse response){
        addResponse(path, response, null);
    }
    
    /**
     * Adds a mock response with a specific path. Responses are returned First In First Out
     * @param path String containing the last bit of the endpoint url for which to add a response
     * @param response HttpResponse to be returned when the mockservices is used
     * @Param e Exception to be thrown when this response is returned
     *  */
    public void addResponse(String path, HttpResponse response, Exception e){
        if (!pathToResponseMap.containsKey(path)){
            pathToResponseMap.put(path, new List<responseWrapper>());
        }
        pathToResponseMap.get(path).add(new responseWrapper(response, e));
    }
    
    /**
     * Adds a mock response without a specific path. Responses are returned First In First Out
     * @param response HttpResponse to be returned when the mockservices is used for a path that does not exist in the pathToResponseMap
     *  */
    public void addDefaultResponse(HttpResponse response){
        addResponse(DEFAULT_PATH_NAME, response, null);
    }
    
    /**
     * Adds a mock response without a specific path. Responses are returned First In First Out
     * @param response HttpResponse to be returned when the mockservices is used for a path that does not exist in the pathToResponseMap
     * @Param e Exception to be thrown when this response is returned
     *  */
    public void addDefaultResponse(HttpResponse response, Exception e){
        addResponse(DEFAULT_PATH_NAME, response, e);
    }
        
    /**
     * respond method needed for the HttpCalloutMock Interface
     * Determines the correct response for a given HttpRequest.
     * @param request HttpRequest for which the corresponding HttpResponse should be returned
     * @Return HttpResponse Moch response
     *  */
    public HttpResponse respond(HttpRequest request) {
        for (String path : pathToResponseMap.keySet()){
            if (request.getEndpoint().split('\\?')[0].endsWith(path)){
                List<ResponseWrapper> responses = pathToResponseMap.get(path);
                if (responses != null && responses.size() > 0) {
                    ResponseWrapper rw = getAndRemoveResponseFromList(responses);
                    if (rw.e == null) {
                        return rw.response;
                    }
                    else {
                        throw rw.e;
                    }
                }
            }
        }
        if (pathToResponseMap.containsKey(DEFAULT_PATH_NAME)){
            List<ResponseWrapper> responses = pathToResponseMap.get(DEFAULT_PATH_NAME);
            if (responses != null && responses.size() > 0) {
                ResponseWrapper rw = getAndRemoveResponseFromList(responses);
                if (rw.e == null) {
                    return rw.response;
                }
                else {
                    throw rw.e;
                }
            }
        }
        System.assert(false, 'unexpected endpoint ' + request.getEndpoint());
        return null;
    }
    
    private ResponseWrapper getAndRemoveResponseFromList(List<ResponseWrapper> responseList){
        ResponseWrapper returnValue = responseList[0];
        if (responseList.size() > 1) { // Never remove the last defaultResponse
            responseList.remove(0);
        }
        return returnValue;
    }
}