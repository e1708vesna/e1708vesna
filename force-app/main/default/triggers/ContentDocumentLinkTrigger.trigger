/**
 * @description   : Trigger to force access for community users to uploaded files
 * @author (s)    : BRITE
 */
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert) {
	for(ContentDocumentLink l:Trigger.new) {
		l.Visibility='AllUsers';
	}    
}