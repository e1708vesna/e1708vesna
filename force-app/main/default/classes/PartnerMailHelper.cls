/**
 * @description   : Class for the functionality Send Emails to Contacts from an Account list
 * @author (s)    : Brite
 */
public class PartnerMailHelper {
	
    public static void sendBatchMail(List<Account> accList, String templateName, String emailAddress){
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Name = :templateName LIMIT 1];   
        List<Messaging.SingleEmailMessage> msemList = new List<Messaging.SingleEmailMessage>();

        //String dateFormat = 'yyyy-MM-dd';
        //DateTime dt = DateTime.now();
        //String strDate = dt.format(dateFormat);   
        
        Messaging.SingleEmailMessage msg;
        for (Account acc : accList) {
            for (Contact con : acc.Contacts) {
                if (con.Email != null && con.Email != '') {
                    msg = new Messaging.SingleEmailMessage ();
                    msg.setTemplateId (template.Id);
                    msg.setTargetObjectId (con.Id); //  Here you can give Id of  User , Lead , Contact 
                    if (emailAddress == null) {
                        msg.setToAddresses(new String[]{con.Email});
                    } else {
                        msg.setToAddresses(new String[]{emailAddress});
                    }
                    msg.setWhatId (acc.Id); // TargetObject
                    msg.setSaveAsActivity(false);
                    msemList.add(msg);
                }
            }
        }
        if (!Test.isRunningTest()) {
            Messaging.sendEmail (msemList);
        } 
    }
}