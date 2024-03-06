/*
 * @name EmailPublisherLoader
 * @author Service
 * @group Quick Action
 * @description This class implements the QuickAction.QuickActionDefaultsHandler to override the default ToAddress on the email quick actions on case.
**/
global class EmailPublisherLoader implements QuickAction.QuickActionDefaultsHandler {
    // Empty constructor
    global EmailPublisherLoader() {
    }
    
    // The main interface method
    // Get the Emailmessage and override/set the defaults
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults) {
        Boolean caseEmailAction = false;
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults;
        EmailMessage emailMessage;
        for ( QuickAction.QuickActionDefaults defaultQuickAction : defaults ) {
            //Only perform the logic when the email is attached to a case record.
            if (defaultQuickAction.getContextId() != null && 'Case'.equals(String.valueOf(defaultQuickAction.getContextId().getSObjectType()))) {
                sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults) defaultQuickAction;
            	emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject(); 
                caseEmailAction = true;
                break;
            }
        }
        if (caseEmailAction){
            Case c = [SELECT Id, ContactId, Contact.Email, Contact.InboundEmail__c FROM Case 
                      WHERE Id=:sendEmailDefaults.getContextId()];
            if (String.isNotBlank(c.Contact?.InboundEmail__c) && String.isNotBlank(c.Contact?.Email)) {
                if (String.isNotBlank(emailMessage.ToAddress)){
                    emailMessage.ToAddress = removeEmailFromList(emailMessage.ToAddress, c.Contact.InboundEmail__c, c.Contact.Email);
                }
                if (String.isNotBlank(emailMessage.ccAddress)){
                    emailMessage.ccAddress = removeEmailFromList(emailMessage.CcAddress, c.Contact.InboundEmail__c, c.Contact.Email);
                }
                if (String.isNotBlank(emailMessage.bccAddress)){
                    emailMessage.bccAddress = removeEmailFromList(emailMessage.BccAddress, c.Contact.InboundEmail__c, c.Contact.Email);
                }
            }           
        }           
        
    }     
    
    /* @Description Replaces an emailaddress with a different one. Keeping uniqueness intact.
* @Param listStr Semicolon delimited list of emailaddresses.
* @Param inboundEmailAddress Email address to be replaced
* @Param outboundEmailAddress Email address to repalce the inboundEmailAddress with.
* @Return String Replaced string
*/
    private static String removeEmailFromList(String listStr, String inboundEmailAddress, String outboundEmailAddress){
        Set<String> stringSet = new Set<String>(listStr.split('; ')); 
        if (stringSet.contains(inboundEmailAddress)){
            stringSet.remove(inboundEmailAddress);
            stringSet.add(outboundEmailAddress);
            return String.join(stringSet, '; ');
        }
        return listStr;
    }
}