/**
 * @description   : ContactHelper test class
 * @author (s)    : BRITE
 */
@isTest
private class CommunityFileMapDaoTest {

	/**
	 * Test the creation retrieval of the communityFileMap Id
	 */
    static testMethod void communityFileMapIdTest() {
    	String developerName = 'GENERAL';
    	CommunityFileMap__c cfm = new CommunityFileMap__c (DeveloperName__c = developerName);
    	insert cfm;
    	
    	Test.startTest();
    	Id cfmId = CommunityFileMapDao.getIdByDeveloperName(developerName);
    	system.assertEquals(cfm.Id,cfmId,'Case1: Id should match'); 
    	Test.stopTest(); 
    }
    
}