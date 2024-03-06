global class RichTextChatter {
    
    @InvocableMethod
    global static List <Results> post (List<Requests> requestList) {
        System.debug('entering RichTextChatter');
        String body = requestList[0].body;
        String recordId = requestList[0].recordId;
        
        //several things that Flow rich text supports, like color and font size, are represented by span tags. chatter doesn't support, so need to strip them out
        Pattern MyPattern = Pattern.compile('<\\/?span[^>]*>');
        Matcher MyMatcher = MyPattern.matcher(body);
        body = MyMatcher.replaceAll('');
        
        //chatter's support for hyperlinks is unconventional and I haven't figured out how to convert a normal anchor link (<a href="http://www.salesforce.com" target="_blank">link</a>) into the chatter equivalent
        //so this hack puts the url into a parentheses next to the link word. anyone who has a better approach is encouraged.
        //extract the url, find all strings that start with <a and end with > i.e.extract url from an anchor tag, extract the text, craft a replacement string
        
        String anchorPattern = '(<a href="([^"]+)" target="_blank">([^<]+)<\\/a>)';
        MyPattern = Pattern.compile(anchorPattern);
        MyMatcher = MyPattern.matcher(body);
        body = MyMatcher.replaceAll('$3 ($2) ');
        System.debug ('body after replacement is: ' + body);
        
        //also have to strip out indent markup:
        //Here's some indented stuff:</p><p class="ql-indent-2">I'm indented</p><p>
        String indentedClassPattern = ' class="ql-indent-[1-4]"';
        MyPattern = Pattern.compile(indentedClassPattern);
        MyMatcher = MyPattern.matcher(body);
        body = MyMatcher.replaceAll('');
        System.debug ('body after replacement is: ' + body);
        
        //change <br> to <p></p>:
        String brPattern = '<br>';
        MyPattern = Pattern.compile(brPattern);
        MyMatcher = MyPattern.matcher(body);
        body = MyMatcher.replaceAll('<p></p>');
        System.debug ('body after replacement is: ' + body);
        
        //change <strong> to <b> and </strong> to </b>:
        String strongPattern = 'strong>';
        MyPattern = Pattern.compile(strongPattern);
        MyMatcher = MyPattern.matcher(body);
        body = MyMatcher.replaceAll('b>');
        System.debug ('body after replacement is: ' + body);
        
        //image links work fine, but we'll do a little reformatting to remove the html
        String imagePattern = '<img src="([^"]+)">';
        MyPattern = Pattern.compile(imagePattern);
        MyMatcher = MyPattern.matcher(body);
        body = MyMatcher.replaceAll('image: $1');
        System.debug ('body after replacement is: ' + body);
        
        //Create a Results object to hold the return values
        Results response = new Results();
        
        //add the return values to the Results object
        response.bodyChanged = body;
        
        // Post a feed item that has an @-mention.        
        ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithRichText(null, recordId, body);
        response.feeditemId = fi.Id;    
        List<Results> responseWrapper= new List<Results>();
        responseWrapper.add(response);
        return responseWrapper;
      
    }
    
    global class Requests {
        @InvocableVariable(required=true)
        public String body;
        
        @InvocableVariable(required=true)
        public String recordId;
        
    }
    
    global class Results {
        
        @InvocableVariable
        public String bodyChanged;
        
        @InvocableVariable
        public String feeditemId;
        
    }
    
}