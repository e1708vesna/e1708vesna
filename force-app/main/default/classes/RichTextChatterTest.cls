@IsTest(SeeAllData=true)
public class RichTextChatterTest {

    @IsTest
    static void testPost() {
        //Create account
        Account acc = TestUtil.createAccount();
        
        // Create test request
        RichTextChatter.Requests req = new RichTextChatter.Requests();
        req.body = '<p>Hello world!</p>';
        req.recordId = acc.Id;
        List<RichTextChatter.Requests> requestList = new List<RichTextChatter.Requests>();
        requestList.add(req);
        
        // Call post method
        List<RichTextChatter.Results> results = RichTextChatter.post(requestList);
        
        // Assert that the returned body has been modified as expected
        String expectedBody = '<p>Hello world!</p>';
        System.assertEquals(expectedBody, results[0].bodyChanged);
        
        // Assert that a feed item has been created
        System.assertNotEquals(null, results[0].feeditemId);
    }
    
}