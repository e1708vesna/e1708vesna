/**
 * @description   : ContentVersionHelper business logic for the trigger
 * @author (s)    : BRITE
 */
public with sharing class ContentVersionHelper {
	//System.debug('Adding a Company wide share');
    public static void setCommunityFileMapLink(List<ContentVersion> contentVersionList) {
		try {
			List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
			Set<Id> idSet = new Set<Id>();
			//Id orgId = UserInfo.getOrganizationId();
				
	    	//Custom object is used to be able to read internal files
	    	CommunityFileMap__c cfm;
			List<CommunityFileMap__c> cfmList = [SELECT Id FROM CommunityFileMap__c WHERE DeveloperName__c = 'GENERAL'];
			if (cfmList.size() == 0) {	
				cfm = new CommunityFileMap__c(DeveloperName__c = 'GENERAL');
				insert cfm;
			} else {
				cfm = cfmList[0]; 				
			}
			if (cfm != null) {	
				for (ContentVersion cv : contentVersionList) {
					if (cv.Community__c) { // this also needed in trigger content document link to update this field?
						//cdlList.add(new ContentDocumentLink(ContentDocumentId = cv.ContentDocumentId, LinkedEntityId = orgId, Visibility = 'AllUsers', ShareType = 'V'));
						cdlList.add(new ContentDocumentLink(ContentDocumentId = cv.ContentDocumentId, LinkedEntityId = cfm.Id, Visibility = 'AllUsers', ShareType = 'V'));
					} else {
						idSet.add(cv.ContentDocumentId);
					} 		
				}
				if (!cdlList.isEmpty()) {
					insert cdlList;
					//system.debug('Community enabled');
				}
				if (!idSet.isEmpty()) {
					delete [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :cfm.Id and ContentDocumentId in :idSet];
					//system.debug('Community disabled');
				}
			}
		} catch(Exception ex) {
			System.debug('Adding a Company wide share failed for a File in Files. Probably the initiator is a Community user.');		
		}
	}	
}