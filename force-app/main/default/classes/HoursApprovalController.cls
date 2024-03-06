public with sharing class HoursApprovalController {

    @InvocableMethod(label = 'Update Urenregistratie List')
    public static void updateUrenregistratie(List<UrenApprovalRequest> uareq) {

        UrenApprovalRequest uaRequest = uareq[0];

        Map<Id, Urenregistratie__c> approvalMap;
        
        if(uaRequest.editedList != null){
            approvalMap = new Map<Id, Urenregistratie__c>(uaRequest.editedList);
            
        } else{
            approvalMap = new Map<Id, Urenregistratie__c>();
        }

        if(uaRequest.selectedList != null){
            for(Urenregistratie__c urRec : uaRequest.selectedList){
                if(approvalMap.containsKey(urRec.Id)){
                    approvalMap.get(urRec.Id).Akkoord__c = true;
                }
                else{
                    approvalMap.put(urRec.Id, new Urenregistratie__c(
                        Id = urRec.Id,
                        Akkoord__c = true
                    ));
                }
            }
        }
                update approvalMap.values();
    }

    public class UrenApprovalRequest{
        @InvocableVariable
        public Urenregistratie__c[] selectedList;
        @InvocableVariable
        public Urenregistratie__c[] editedList;
    }

}