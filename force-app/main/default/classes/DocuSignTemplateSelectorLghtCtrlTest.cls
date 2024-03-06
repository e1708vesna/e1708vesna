@isTest
public class DocuSignTemplateSelectorLghtCtrlTest {

    @isTest
    private static void queryEnvelopeConfigurationsTest(){
        //Insert Templates
        List<dsfs__EnvelopeConfiguration__c> envelopeConfigList = new List<dsfs__EnvelopeConfiguration__c>();
        
        
        
        String regionPicklist = '';
        for (Schema.PicklistEntry p: dsfs__EnvelopeConfiguration__c.ContractCountryCurrency__c.getDescribe().getPicklistValues()) {
            regionPicklist = p.getValue();
            break;
        }
        String salesChannelPicklist = '';
        for (Schema.PicklistEntry p: dsfs__EnvelopeConfiguration__c.SalesChannel__c.getDescribe().getPicklistValues()) {
            salesChannelPicklist = p.getValue();
            break;
        }
        String contractTypePicklist = '';
        for (Schema.PicklistEntry p: dsfs__EnvelopeConfiguration__c.ContractType__c.getDescribe().getPicklistValues()) {
            contractTypePicklist = p.getValue();
            break;
        }
        
        
        
        
        for (Integer i = 0; i < 10; i++){
            envelopeConfigList.add(new dsfs__EnvelopeConfiguration__c(Name='Envelope' + i, ContractCountryCurrency__c = regionPicklist, SalesChannel__c = salesChannelPicklist, ContractType__c = contractTypePicklist));
        }
        insert envelopeConfigList;
        //Call DocuSignTemplateSelectorLghtCtrl.queryEnvelopeConfigurations(String searchQuery, String region, String contractType, String salesChannel, Integer queryLimit)
       
        //Limit Test
        List<dsfs__EnvelopeConfiguration__c> returnList = DocuSignTemplateSelectorLghtCtrl.queryEnvelopeConfigurations('', '', '', '', 9);
        System.assertEquals(9, returnList.size(), 'Expected 9 records returned');
        
        //QueryString Test
        returnList = DocuSignTemplateSelectorLghtCtrl.queryEnvelopeConfigurations('Envelope1', '', '', '', 10);
        System.assertEquals(1, returnList.size(), 'Expected 1 record returned');
        
        //SalesChannel Test
        returnList = DocuSignTemplateSelectorLghtCtrl.queryEnvelopeConfigurations('', '', '', salesChannelPicklist, 10);
        System.assertEquals(10, returnList.size(), 'Expected 10 record returned');
        
        //Region Test
        returnList = DocuSignTemplateSelectorLghtCtrl.queryEnvelopeConfigurations('', regionPicklist, '', '', 10);
        System.assertEquals(10, returnList.size(), 'Expected 10 record returned');
        
        //ContractType Test
        returnList = DocuSignTemplateSelectorLghtCtrl.queryEnvelopeConfigurations('', '', contractTypePicklist, '', 10);
        System.assertEquals(10, returnList.size(), 'Expected 10 record returned');
        
        DocuSignTemplateSelectorLghtCtrl.getPicklistValues();//Nothing to assert here
        
    }
    
}