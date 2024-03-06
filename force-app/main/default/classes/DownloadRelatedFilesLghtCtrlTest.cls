@isTest
public class DownloadRelatedFilesLghtCtrlTest {

    private static String STATUS_OPEN_NO_CONTACTED = 'Open - Not Contacted';
    @isTest private static void queryContentVersions(){
        
        //Insert account and case
        Account testAcc = new Account(); //TODO
        insert testAcc;
        Case c = new Case();//TODO
        insert c;
        //Insert emailmessage for Account
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.ParentId = c.Id; 
        insert email;
        
        //Insert attachment
         ContentVersion contentVersion = new ContentVersion(
                    Title          = 'EmailAttachment',
                    PathOnClient   = 'Pic2.jpg',
                    VersionData    = Blob.valueOf('Test ContentUno'),
                    IsMajorVersion = true,
                    FirstPublishLocationId = email.Id
         );
        
        ContentVersion contentVersion2 = new ContentVersion(
                    Title          = 'Account Attachment',
                    PathOnClient   = 'Pic.jpg',
                    VersionData    = Blob.valueOf('Test ContentDeux'),
                    IsMajorVersion = true,
            FirstPublishLocationId = c.Id
        );
        insert contentVersion;
        insert contentVersion2;

        List<ContentDocument> versionList = DownloadRelatedFilesLghtCtrl.getContentVersions(c.Id);
        System.assertEquals(2, versionList.size());
    }
    
}