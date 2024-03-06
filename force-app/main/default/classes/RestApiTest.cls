@isTest
public class RestApiTest {
    
    @isTest
    private static void Param_urlEncodeKeyValuePairUtf8() {
        String toEncodeLeft = 'Hello +%-_.!~*\'()@';
        String toEncodeRight = 'World +%-_.!~*\'()@';
        String expected = 'Hello+%2B%25-_.%21%7E*%27%28%29%40=World+%2B%25-_.%21%7E*%27%28%29%40';
        String result = new RestApi.Param(toEncodeLeft, toEncodeRight).toString();
        System.assertEquals(expected, result);
    }
    
    @isTest
    private static void Param_createFromMap() {
       
        /*params.addAll(client.makeParam('foo', 'bar'));
        params.addAll(client.makeParam('foo', 10));
        params.addAll(client.makeParam('foo', 12.6));
        params.addAll(client.makeParam('foo', true));
        params.addAll(client.makeParam('foo', ''));
        params.addAll(client.makeParam('foo', Datetime.newInstanceGmt(2017, 1, 1, 15, 0, 0)));
        params.addAll(client.makeParam('foo', null));

        System.assertEquals(6, params.size());
        System.assertEquals('foo=bar', params.get(0).toString());
        System.assertEquals('foo=10', params.get(1).toString());
        System.assertEquals('foo=12.6', params.get(2).toString());
        System.assertEquals('foo=true', params.get(3).toString());
        System.assertEquals('foo=', params.get(4).toString());
        System.assertEquals('foo=2017-01-01+15%3A00%3A00', params.get(5).toString());*/
        Map<String, Object> mappedProperties = new Map<String, Object>();
        mappedProperties.put('1', 'bar');
        mappedProperties.put('2', '10');
        mappedProperties.put('3', 12.6);
        mappedProperties.put('4', true);
        mappedProperties.put('5', '');
        mappedProperties.put('6', Datetime.newInstanceGmt(2017, 1, 1, 15, 0, 0));
        mappedProperties.put('7', null);

        List<RestApi.Param> paramList = RestApi.getParamsFromMap(mappedProperties);
        System.assertEquals(6, paramList.size());
    }
    
    
    @isTest
    private static void ApiClient_extractHeadersFromResponse() {
        RestApi api = new RestApi('Named Credential');
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Cache-Control', 'private, max-age=0');
        Map<String, String> headers = api.getHeaders(res); 

        System.assertEquals(2, headers.size());
        System.assertEquals('application/json', headers.get('Content-Type'));
        System.assertEquals('private, max-age=0', headers.get('Cache-Control'));
    }
    
    @isTest
    private static void ApiClient_returnParsedBody() {
        RestApi client = new RestApi('Named Credential');
        HttpResponse res = new HttpResponse();
        RestApiResponseMock mock = new RestApiResponseMock();
        Test.setMock(HttpCalloutMock.class, mock);
        mock.addDefaultResponse(res);

        res.setStatus('OK');
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{'
            + '"city":"Austin","country":"United States","latitude":30.28403639999999,'
            + '"longitude":-97.73789449999998,"postalCode":"78705","state":"Texas",'
            + '"street":"2110 Speedway"}');
		//String method, String path, Object body, List<Param> query, List<Param> pathParams, Map<String, Object> headers, List<String> accepts,
        //List<String> contentTypes, List<String> authMethods, Type returnType
        Address a = (Address) client.invoke(
            'GET', '/address', '',
            new List<RestApi.Param>(),
            new Map<String, Object>(),
            new Map<String, Object>(),
            new List<String>{'application/json'},
            new List<String>{'text/plain'},
            new List<String>(),
            Address.class
        );

        System.assertEquals('Austin', a.getCity());
        System.assertEquals('United States', a.getCountry());
        System.assertEquals(30.28403639999999, a.getLatitude());
        System.assertEquals(-97.73789449999998, a.getLongitude());
        System.assertEquals('78705', a.getPostalCode());
        System.assertEquals('Texas', a.getState());
        System.assertEquals('2110 Speedway', a.getStreet());
    }
    
    @isTest
    private static void ApiClient_returnBadRequest() {
        RestApi client = new RestApi('Named Credential');
        HttpResponse res = new HttpResponse();
        RestApiResponseMock mock = new RestApiResponseMock();
        Test.setMock(HttpCalloutMock.class, mock);
        mock.addDefaultResponse(res);

        res.setStatus('Bad Request');
        res.setStatusCode(400);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"message":"bad request mate"}');
        
        try{
        	Address a = (Address) client.invoke(
                'GET', '/address', '',
                new List<RestApi.Param>(),
                new Map<String, Object>(),
                new Map<String, Object>(),
                new List<String>{'application/json'},
                new List<String>{'text/plain'},
                new List<String>(),
                Address.class
        	);
        }
        catch(RestApi.ApiException e){
            System.assertEquals(400, e.getStatusCode());
            System.assertEquals('Bad Request', e.getStatus());
            System.assertEquals('{"message":"bad request mate"}', e.getBody());
            Map<String, String> exceptionHeaders = e.getHeaders();
            System.assertEquals('application/json', exceptionHeaders.get('Content-Type'));
        }

        
    }

}