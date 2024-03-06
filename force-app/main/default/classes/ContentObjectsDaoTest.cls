/**
 * @description   : ContentDocumentLinkDao, ContentVersionDao test class
 * @author (s)    : BRITE
 */
@isTest
public class ContentObjectsDaoTest {
	/**
	 * Test file retrieval
	 */
    static testMethod void fileRetrieveTest() {
    	Id recIdChannelPartner = RecordTypeUtil.getRecordTypeIdByDevName('ChannelPartner', Account.getSObjectType());
    	Account acc = new Account(Name = 'channelpartner1', RecordTypeId = recIdChannelPartner);
    	insert acc;
    	
    	//Create custom object record to share files on the Community
    	String developerName = 'GENERAL';
    	CommunityFileMap__c cfm = new CommunityFileMap__c (DeveloperName__c = developerName);
    	insert cfm;
    	
		//Create the new file
		String fileName = 'MyFile.jar';
		Blob data = EncodingUtil.base64Decode('UEsDBBQACAgIACJkfE0AAAAAAAAAAAAAAAAIAAAAdGVzdC50eHSNkl1rgzAUhu/9FQd2Yy+U+NFiC70QdTDoaqmlvRxZczZkmkiSdvjvl7oxXFFZrvOc9+R583BCBltxBT8Cz18FwYqEkGTFAXziRZblfh9wILkoLWqUwGmNLyMH1rDN0ngHafacO0meZr0Jj0LWVMMVpSoFH5/g9ZhNeUauEGrBsBpDRxh+qV9RTuT4QTgf4H5SwH5HjpJqZLPRrJ0U7HLWk1JuTJzlxQA26cJggRv2qD1WSM2CzOzk6HI4sXuY43lOV2Af5vhJK2hQloJByc2YVg1Ekh5UtEpj/YEtNFJcSzao00BPTcyYRKWGWFvNwD6LuqagsKF/jN62Xfqut4hc4np9s0dalazU7d3CYJP1m5BozM06fD7BKE2l7nTdCVr8CooIWYYBMXB8WhLiQ5yY719Akm8P+3xjijvF+6wP+1aKDXKGXP/UGHN2nCgS1tb/LvZTbh+mq/8LUEsHCGyscKBaAQAAogMAAFBLAQIUABQACAgIACJkfE1srHCgWgEAAKIDAAAIAAAAAAAAAAAAAAAAAAAAAAB0ZXN0LnR4dFBLBQYAAAAAAQABADYAAACQAQAAAAA='); 
		ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.ContentDocumentId = null;
        cv.VersionData = data;
        cv.Title = fileName;
        cv.PathOnClient = filename;
        cv.Community__c = true;		//Visibility on the Community
        insert cv;	

		//Relate the file to the License        
        ContentDocumentLink cdl = new ContentDocumentLink();        
		cdl.ContentDocumentId = ContentVersionDao.getById(cv.Id)[0].ContentDocumentId;
		cdl.LinkedEntityId = acc.Id;
		cdl.ShareType = 'V';
		insert cdl;	
	

		Test.startTest();
		
		//Case 1
		List<ContentDocumentLink> cdlList = ContentDocumentLinkDao.getByLinkedEntityId(acc.Id);
		system.assertEquals(1, cdlList.size(), 'Case 1: One file should return');
		    	
		List<ContentVersion> contentVersionList = ContentVersionDao.getByTitle (filename);
		system.assertEquals(cv.Id, contentVersionList[0].Id, 'Cae 2: Id should match');
		    
		List<ContentDocument> contentDocumentList = ContentDocumentLinkDao.getByTitle (filename);
		system.assertEquals(cdl.ContentDocumentId, contentDocumentList[0].Id, 'Case 3: Id should match');
 	    
 	    //check visibility community
		cdlList = ContentDocumentLinkDao.getContentDocumentLinkList(cfm.Id, fileName);
		system.assertEquals(cdl.ContentDocumentId, cdlList[0].ContentDocumentId, 'Case 4: One file should return');
		
		//Check delete ContentDocumentLink to make the file unvisible for the community    	
        cv.Community__c = false;
        update cv;	

		cdlList = ContentDocumentLinkDao.getContentDocumentLinkList(cfm.Id, fileName);
		system.assertEquals(0, cdlList.size(), 'Case 5: ContentDocumentLink should be deleted');
		    	
		Test.stopTest();    	
    }
}