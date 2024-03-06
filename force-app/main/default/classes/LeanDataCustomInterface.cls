global with sharing class LeanDataCustomInterface extends LeanData.CustomInterface {
    
    global override Map<String, List<String>> getMapOfCustomInterfaceNodeNamesToEdges(){
        Map<String, List<String>> customInterfaceMap = new Map<String, List<String>>();
        
        customInterfaceMap.put('Process Custom Merge Options', new List<String>{'Success','No Dupe Lead','No Custom Merge Settings Found','Failure'});
        
        return customInterfaceMap;
    }
    
    global override Set<String> getCustomLeadFields() {
        // fields that we are accessing on any Lead object.  These fields will be fetched in SOSL & SOQL queries
        Set<String> leadFields = new Set<String>();
        List<LeanData_Custom_Merge_Setting__c> customMergeSettings = [SELECT Id, Lead_Field_Api_Name__c, Lead_Controlling_Field_Api_Name__c, Contact_Field_Api_Name__c, Contact_Controlling_Field_Api_Name__c, Account_Field_Api_Name__c, Account_Controlling_Field_Api_Name__c, Operation__c FROM LeanData_Custom_Merge_Setting__c];
        for(LeanData_Custom_Merge_Setting__c cms : customMergeSettings){
            if(cms.Lead_Field_Api_Name__c != null){
                leadFields.add(cms.Lead_Field_Api_Name__c);
            }
            if(cms.Lead_Controlling_Field_Api_Name__c != null){
                leadFields.add(cms.Lead_Controlling_Field_Api_Name__c);
            }
        }
        
        return leadFields;
    }
    
    global override Set<String> getCustomContactFields() {
        // fields that we are accessing on any Lead object.  These fields will be fetched in SOSL & SOQL queries
        Set<String> contactFields = new Set<String>();
        List<LeanData_Custom_Merge_Setting__c> customMergeSettings = [SELECT Id, Lead_Field_Api_Name__c, Lead_Controlling_Field_Api_Name__c, Contact_Field_Api_Name__c, Contact_Controlling_Field_Api_Name__c, Account_Field_Api_Name__c, Account_Controlling_Field_Api_Name__c, Operation__c FROM LeanData_Custom_Merge_Setting__c];
        for(LeanData_Custom_Merge_Setting__c cms : customMergeSettings){
            if(cms.Contact_Field_Api_Name__c != null){
                contactFields.add(cms.Contact_Field_Api_Name__c);
            }
            if(cms.Contact_Controlling_Field_Api_Name__c != null){
                contactFields.add(cms.Contact_Controlling_Field_Api_Name__c);
            }
        }
        
        return contactFields;
    }
    
    global override Set<String> getCustomAccountFields() {
        // fields that we are accessing on any Lead object.  These fields will be fetched in SOSL & SOQL queries
        Set<String> accountFields = new Set<String>();
        List<LeanData_Custom_Merge_Setting__c> customMergeSettings = [SELECT Id, Lead_Field_Api_Name__c, Lead_Controlling_Field_Api_Name__c, Contact_Field_Api_Name__c, Contact_Controlling_Field_Api_Name__c, Account_Field_Api_Name__c, Account_Controlling_Field_Api_Name__c, Operation__c FROM LeanData_Custom_Merge_Setting__c];
        for(LeanData_Custom_Merge_Setting__c cms : customMergeSettings){
            if(cms.Account_Field_Api_Name__c != null){
                accountFields.add(cms.Account_Field_Api_Name__c);
            }
            if(cms.Account_Controlling_Field_Api_Name__c != null){
                accountFields.add(cms.Account_Controlling_Field_Api_Name__c);
            }
        }
        
        return accountFields;
    }
    
    global override String customRoutingRule(SObject primary, Map<String, SObject> chosenSObjects, String parameter, Map<String, Object> additionalParameters) {
        
        System.debug('parameter');
        System.debug(parameter);
        
        if(parameter == 'Process Custom Merge Options'){
            Lead primaryLead;
            Contact primaryContact;
            if(primary.getSObjectType()==Lead.sObjectType){
                primaryLead = (Lead) primary;
            } else if(primary.getSObjectType()==Contact.sObjectType){
                primaryContact = (Contact) primary;
            }
            
            if(chosenSObjects.get('Dupe') != null || chosenSObjects.get('DupeC') != null || chosenSObjects.get('CDupe') != null || chosenSObjects.get('L2A') != null){
                if(primaryLead == null && primaryContact == null){
                    return 'No Primary Record';
                }
                List<LeanData_Custom_Merge_Setting__c> customMergeSettings = [SELECT Id, Lead_Field_Api_Name__c, Lead_Controlling_Field_Api_Name__c, Contact_Field_Api_Name__c, Contact_Controlling_Field_Api_Name__c, Account_Field_Api_Name__c, Account_Controlling_Field_Api_Name__c, Operation__c FROM LeanData_Custom_Merge_Setting__c];
                Lead dupeLead;
                Contact dupeContact;
                Contact contactDupe;
                Account matchedAccount;
                
                if(chosenSObjects.get('Dupe') != null) dupeLead = (Lead) chosenSObjects.get('Dupe');
                if(chosenSObjects.get('DupeC') != null) dupeContact = (Contact) chosenSObjects.get('DupeC');
                if(chosenSObjects.get('CDupe') != null) contactDupe = (Contact) chosenSObjects.get('CDupe');
                if(chosenSObjects.get('L2A') != null) matchedAccount = (Account) chosenSObjects.get('L2A');
                
                if(customMergeSettings.size() > 0){
                    system.debug('msPrimaryLead: ');
                    system.debug(primaryLead);
                    system.debug('msDupeContact: ');
                    system.debug(dupeContact);
                    system.debug('msPrimaryContac: ');
                    system.debug(primaryContact);
                    
                    for(LeanData_Custom_Merge_Setting__c cms : customMergeSettings){
                        if(primaryLead != null && dupeLead != null && cms.Lead_Field_Api_Name__c != null && cms.Contact_Field_Api_Name__c == null && cms.Account_Field_Api_Name__c == null){
                            processMergeSetting(primaryLead, dupeLead, cms, cms.Lead_Field_Api_Name__c, cms.Lead_Controlling_Field_Api_Name__c, cms.Lead_Field_Api_Name__c, cms.Lead_Controlling_Field_Api_Name__c);
                            Database.update(dupeLead);
                        }
                        if(primaryLead != null && dupeContact != null && cms.Lead_Field_Api_Name__c != null && cms.Contact_Field_Api_Name__c != null && cms.Account_Field_Api_Name__c == null){
                            processMergeSetting(primaryLead, dupeContact, cms, cms.Lead_Field_Api_Name__c, cms.Lead_Controlling_Field_Api_Name__c, cms.Contact_Field_Api_Name__c, cms.Contact_Controlling_Field_Api_Name__c);
                            Database.update(dupeContact);
                        }
                        if(primaryContact != null && contactDupe != null && cms.Lead_Field_Api_Name__c == null && cms.Contact_Field_Api_Name__c != null && cms.Account_Field_Api_Name__c == null){
                            processMergeSetting(primaryContact, contactDupe, cms, cms.Contact_Field_Api_Name__c, cms.Contact_Controlling_Field_Api_Name__c, cms.Contact_Field_Api_Name__c, cms.Contact_Controlling_Field_Api_Name__c);
                            Database.update(contactDupe);
                        }
                        if(primaryLead != null && matchedAccount != null && cms.Lead_Field_Api_Name__c != null && cms.Contact_Field_Api_Name__c == null && cms.Account_Field_Api_Name__c != null){
                            processMergeSetting(primaryLead, matchedAccount, cms, cms.Lead_Field_Api_Name__c, cms.Lead_Controlling_Field_Api_Name__c, cms.Account_Field_Api_Name__c, cms.Account_Controlling_Field_Api_Name__c);
                            Database.update(matchedAccount);
                        }
                    }
                    
                    return 'Success';
                    
                } else {
                    system.debug('Exited custom merge settings logic');
                    return 'No Custom Merge Settings Found';
                }
                
            } else {
                return 'No Dupe Lead';
            }
        }
        
        return 'False';
    }
    
    public static void processMergeSetting(SObject incomingRecord, SObject existingRecord, LeanData_Custom_Merge_Setting__c cms, String incomingField, String incomingControllingField, String existingField, String existingControllingField){
        //String fieldApiName = cms.Lead_Field_Api_Name__c;
        //String controllingFieldApiName = cms.Lead_Controlling_Field_Api_Name__c;
        if(incomingField == null || existingField == null){
            System.debug('Bad Setting');
        } else if(cms.Operation__c == 'Keep Existing Lead Value' || cms.Operation__c == 'Keep Existing Value Including Blank'){
            if(existingRecord.get(existingField) != null || cms.Operation__c == 'Keep Existing Value Including Blank'){
                if(existingField != 'Address'){
                    incomingRecord.put(incomingField, existingRecord.get(existingField));
                } else {
                    //special logic for addresses
                    processAddressFields('existing', incomingRecord, existingRecord, incomingField, existingField);
                }
            }
            if(incomingControllingField != null && existingControllingField != null && (existingRecord.get(existingControllingField) != null || cms.Operation__c == 'Keep Existing Value Including Blank')){
                incomingRecord.put(incomingControllingField, existingRecord.get(existingControllingField));
            }
        } else if(cms.Operation__c == 'Keep Incoming Lead Value' || cms.Operation__c == 'Keep Incoming Value Including Blank'){
            if(incomingRecord.get(incomingField) != null || cms.Operation__c == 'Keep Incoming Value Including Blank'){
                if(incomingField != 'Address'){
                    existingRecord.put(existingField, incomingRecord.get(incomingField));
                } else {
                    //special logic for addresses
                    processAddressFields('incoming', incomingRecord, existingRecord, incomingField, existingField);
                }
            }
            if(incomingControllingField != null && existingControllingField != null && (incomingRecord.get(incomingControllingField) != null || cms.Operation__c == 'Keep Incoming Value Including Blank')){
                existingRecord.put(existingControllingField, incomingRecord.get(incomingControllingField));
            }
        } else if(cms.Operation__c == 'Concatenate Values Text with Comma'){
            String primaryValue = (String) incomingRecord.get(incomingField);
            String dupeValue = (String) existingRecord.get(existingField);
            String concatenatedValue = dupeValue + ', ' + primaryValue;
            
            if(dupeValue != null && primaryValue != null){
                incomingRecord.put(incomingField, concatenatedValue);
                existingRecord.put(existingField, concatenatedValue);
            } else if(dupeValue != null && primaryValue == null){
                incomingRecord.put(incomingField, dupeValue);
                existingRecord.put(existingField, dupeValue);
            } else if(dupeValue == null && primaryValue != null){
                incomingRecord.put(incomingField, primaryValue);
                existingRecord.put(existingField, primaryValue);
            } else if(dupeValue == null && primaryValue == null){
                //do nothing
            }
        } else if(cms.Operation__c == 'Concatenate Values Text with Semi-colon'){
            String primaryValue = (String) incomingRecord.get(incomingField);
            String dupeValue = (String) existingRecord.get(existingField);
            String concatenatedValue = dupeValue + '; ' + primaryValue;
            
            if(dupeValue != null && primaryValue != null){
                incomingRecord.put(incomingField, concatenatedValue);
                existingRecord.put(existingField, concatenatedValue);
            } else if(dupeValue != null && primaryValue == null){
                incomingRecord.put(incomingField, dupeValue);
                existingRecord.put(existingField, dupeValue);
            } else if(dupeValue == null && primaryValue != null){
                incomingRecord.put(incomingField, primaryValue);
                existingRecord.put(existingField, primaryValue);
            } else if(dupeValue == null && primaryValue == null){
                //do nothing
            }
        } else if(cms.Operation__c == 'Concatenate Values Text with New Line'){
            String primaryValue = (String) incomingRecord.get(incomingField);
            String dupeValue = (String) existingRecord.get(existingField);
            String concatenatedValue = dupeValue + '\n' + primaryValue;
            
            if(dupeValue != null && primaryValue != null){
                incomingRecord.put(incomingField, concatenatedValue);
                existingRecord.put(existingField, concatenatedValue);
            } else if(dupeValue != null && primaryValue == null){
                incomingRecord.put(incomingField, dupeValue);
                existingRecord.put(existingField, dupeValue);
            } else if(dupeValue == null && primaryValue != null){
                incomingRecord.put(incomingField, primaryValue);
                existingRecord.put(existingField, primaryValue);
            } else if(dupeValue == null && primaryValue == null){
                //do nothing
            }
        } else if(cms.Operation__c == 'Concatenate Values Text with Timestamp'){
            String dateString = String.valueOf(System.Today().year()) + '-' + String.valueOf(System.Today().month()) + '-' + String.valueOf(System.Today().day()) + ': ';
            
            String primaryValue = (String) incomingRecord.get(incomingField);
            String dupeValue = (String) existingRecord.get(existingField);
            String concatenatedValue = dupeValue + '\n' + dateString + primaryValue;
            
            if(dupeValue != null && primaryValue != null){
                incomingRecord.put(incomingField, concatenatedValue);
                existingRecord.put(existingField, concatenatedValue);
            } else if(dupeValue != null && primaryValue == null){
                incomingRecord.put(incomingField, dupeValue);
                existingRecord.put(existingField, dupeValue);
            } else if(dupeValue == null && primaryValue != null){
                incomingRecord.put(incomingField, primaryValue);
                existingRecord.put(existingField, primaryValue);
            } else if(dupeValue == null && primaryValue == null){
                //do nothing
            }
        } else if(cms.Operation__c == 'Concatenate Values Number'){
            Decimal primaryNumber = (Decimal) incomingRecord.get(incomingField);
            Decimal dupeNumber = (Decimal) existingRecord.get(existingField);
            Decimal concatenatedNumber = primaryNumber + dupeNumber;
            
            if(dupeNumber != null && primaryNumber != null){
                incomingRecord.put(incomingField, concatenatedNumber);
                existingRecord.put(existingField, concatenatedNumber);
            } else if(dupeNumber != null && primaryNumber == null){
                incomingRecord.put(incomingField, dupeNumber);
                existingRecord.put(existingField, dupeNumber);
            } else if(dupeNumber == null && primaryNumber != null){
                incomingRecord.put(incomingField, primaryNumber);
                existingRecord.put(existingField, primaryNumber);
            } else if(dupeNumber == null && primaryNumber == null){
                //do nothing
            }
        } else if(cms.Operation__c == 'Concatenate Values Picklist'){
            String primaryValue = (String) incomingRecord.get(incomingField);
            Set<String> primaryValueSet;
            String dupeValue = (String) existingRecord.get(existingField);
            Set<String> dupeValueSet;
            Set<String> concatenatedValueSet = new Set<String>();
            String concatenatedValue;
            
            if(primaryValue != null) primaryValueSet = new Set<String>(primaryValue.split(';'));
            if(dupeValue != null) dupeValueSet = new Set<String>(dupeValue.split(';'));
            
            if(primaryValueSet != null){
                concatenatedValueSet.addAll(primaryValueSet);
            }
            if(dupeValueSet != null){
                concatenatedValueSet.addAll(dupeValueSet);
            }
            
            for(String picklistValue : concatenatedValueSet){
                if(concatenatedValue == null){
                    concatenatedValue = picklistValue;
                } else {
                    concatenatedValue += ';' + picklistValue;
                }
            }
            
            if(dupeValue != null && primaryValue != null){
                incomingRecord.put(incomingField, concatenatedValue);
                existingRecord.put(existingField, concatenatedValue);
            } else if(dupeValue != null && primaryValue == null){
                incomingRecord.put(incomingField, dupeValue);
                existingRecord.put(existingField, dupeValue);
            } else if(dupeValue == null && primaryValue != null){
                incomingRecord.put(incomingField, primaryValue);
                existingRecord.put(existingField, primaryValue);
            } else if(dupeValue == null && primaryValue == null){
                //do nothing
            }
        } else if (cms.Operation__c == 'Keep Blank Else Incoming'){
            object incomingValue = incomingRecord.get(incomingField);
            object existingValue = existingRecord.get(existingField);
            if (incomingValue == null || existingValue == null){
                existingRecord.put(existingField, null);
                incomingRecord.put(incomingField, null);
            }
            else {
                existingRecord.put(existingField, incomingValue);
                incomingRecord.put(incomingField, incomingValue);
            }
        } else if (cms.Operation__c == 'Keep Blank Else Existing'){
            object incomingValue = incomingRecord.get(incomingField);
            object existingValue = existingRecord.get(existingField);
            if (incomingValue == null || existingValue == null){
                existingRecord.put(existingField, null);
                incomingRecord.put(incomingField, null);
            }
            else {
                existingRecord.put(existingField, existingValue);
                incomingRecord.put(incomingField, existingValue);
            }
        }
        
        return;
    }
    
    public static void processAddressFields(String preference, SObject incomingRecord, SObject existingRecord, String incomingField, String existingField){
        Boolean hasMismatch = FALSE;
        String incomingStreet, incomingPostalCode, incomingCity, incomingState, incomingCountry;
        String existingStreet, existingPostalCode, existingCity, existingState, existingCountry;
        if(incomingRecord.getSObjectType()==Lead.sObjectType) {
            incomingStreet = (String) incomingRecord.get('Street');
            incomingPostalCode = (String) incomingRecord.get('PostalCode');
            incomingCity = (String) incomingRecord.get('City');
            incomingState = (String) incomingRecord.get('State');
            incomingCountry = (String) incomingRecord.get('Country');
        } else if(incomingRecord.getSObjectType()==Account.sObjectType){
            incomingStreet = (String) incomingRecord.get('BillingStreet');
            incomingPostalCode = (String) incomingRecord.get('BillingPostalCode');
            incomingCity = (String) incomingRecord.get('BillingCity');
            incomingState = (String) incomingRecord.get('BillingState');
            incomingCountry = (String) incomingRecord.get('BillingCountry');
        } else if(incomingRecord.getSObjectType()==Contact.sObjectType){
            incomingStreet = (String) incomingRecord.get('MailingStreet');
            incomingPostalCode = (String) incomingRecord.get('MailingPostalCode');
            incomingCity = (String) incomingRecord.get('MailingCity');
            incomingState = (String) incomingRecord.get('MailingState');
            incomingCountry = (String) incomingRecord.get('MailingCountry');
        }
        if(existingRecord.getSObjectType()==Lead.sObjectType){
            existingStreet = (String) existingRecord.get('Street');
            existingPostalCode = (String) existingRecord.get('PostalCode');
            existingCity = (String) existingRecord.get('City');
            existingState = (String) existingRecord.get('State');
            existingCountry = (String) existingRecord.get('Country');
        } else if(existingRecord.getSObjectType()==Account.sObjectType){
            existingStreet = (String) existingRecord.get('BillingStreet');
            existingPostalCode = (String) existingRecord.get('BillingPostalCode');
            existingCity = (String) existingRecord.get('BillingCity');
            existingState = (String) existingRecord.get('BillingState');
            existingCountry = (String) existingRecord.get('BillingCountry');
        } else if(existingRecord.getSObjectType()==Contact.sObjectType){
            existingStreet = (String) existingRecord.get('MailingStreet');
            existingPostalCode = (String) existingRecord.get('MailingPostalCode');
            existingCity = (String) existingRecord.get('MailingCity');
            existingState = (String) existingRecord.get('MailingState');
            existingCountry = (String) existingRecord.get('MailingCountry');
        }
        
        if(incomingStreet != null && existingStreet != null && incomingStreet != existingStreet){
            hasMisMatch = TRUE;
        } else if(incomingPostalCode != null && existingPostalCode != null && incomingPostalCode != existingPostalCode){
            hasMismatch = TRUE;
        } else if(incomingCity != null && existingCity != null && incomingCity != existingCity){
            hasMismatch = TRUE;
        } else if(incomingState != null && existingState != null && incomingState != existingState){
            hasMismatch = TRUE;
        } else if(incomingCountry != existingCountry){
            hasMismatch = TRUE;
        }
        
        if(hasMismatch == TRUE){
            system.debug('hasMismatch true');
            if(preference == 'incoming'){
                setAddressField(existingRecord, 'Street', incomingStreet);
                setAddressField(existingRecord, 'PostalCode', incomingPostalCode);
                setAddressField(existingRecord, 'City', incomingCity);
                setAddressField(existingRecord, 'State', incomingState);
                setAddressField(existingRecord, 'Country', incomingCountry);
                
            } else if(preference == 'existing'){
                
                setAddressField(incomingRecord, 'Street', existingStreet);
                setAddressField(incomingRecord, 'PostalCode', existingPostalCode);
                setAddressField(incomingRecord, 'City', existingCity);
                setAddressField(incomingRecord, 'State', existingState);
                setAddressField(incomingRecord, 'Country', existingCountry);
              
            }
            return;
        } else {
            system.debug('hasMismatch FALSE');
            //handle non-mismatch by combining the two address fields
            if(incomingStreet == null && existingStreet != null){
                setAddressField(incomingRecord, 'Street', existingStreet);
            } else if(incomingStreet != null && existingStreet == null){
                setAddressField(existingRecord, 'Street', incomingStreet);
            }
            if(incomingPostalCode == null && existingPostalCode != null){
                setAddressField(incomingRecord, 'PostalCode', existingPostalCode);
            } else if(incomingPostalCode != null && existingPostalCode == null){
                setAddressField(existingRecord, 'PostalCode', incomingPostalCode);
            }
            if(incomingCity == null && existingCity != null){
                setAddressField(incomingRecord, 'City', existingCity);
            } else if(incomingCity != null && existingCity == null){
                setAddressField(existingRecord, 'City', incomingCity);
            }
            if(incomingState == null && existingState != null){
                setAddressField(incomingRecord, 'State', existingState);
            } else if(incomingState != null && existingState == null){
                setAddressField(existingRecord, 'State', incomingState);
            }
            if(incomingCountry == null && existingCountry != null){
                setAddressField(incomingRecord, 'Country', existingCountry);
            } else if(incomingCountry != null && existingCountry == null){
                setAddressField(existingRecord, 'Country', incomingCountry);
            }
            return;
        }
    }
    
    public static void setAddressField(SObject record, String fieldType, String value){
        if(record.getSObjectType()==Lead.sObjectType) {
            if(fieldType == 'Street'){
                record.put('Street', value);
            } else if(fieldType == 'PostalCode'){
                record.put('PostalCode', value);
            } else if(fieldType == 'City'){
                record.put('City', value);
            } else if(fieldType == 'State'){
                record.put('State', value);
            } else if(fieldType == 'Country'){
                record.put('Country', value);
            }
        } else if(record.getSObjectType()==Account.sObjectType){
            if(fieldType == 'Street'){
                record.put('BillingStreet', value);
            } else if(fieldType == 'PostalCode'){
                record.put('BillingPostalCode', value);
            } else if(fieldType == 'City'){
                record.put('BillingCity', value);
            } else if(fieldType == 'State'){
                record.put('BillingState', value);
            } else if(fieldType == 'Country'){
                record.put('BillingCountry', value);
            }
        } else if(record.getSObjectType()==Contact.sObjectType){
            if(fieldType == 'Street'){
                record.put('MailingStreet', value);
            } else if(fieldType == 'PostalCode'){
                record.put('MailingPostalCode', value);
            } else if(fieldType == 'City'){
                record.put('MailingCity', value);
            } else if(fieldType == 'State'){
                record.put('MailingState', value);
            } else if(fieldType == 'Country'){
                record.put('MailingCountry', value);
            }
        }
        
        return;
    }
    
    global override Map<String, Object> getCustomNotificationOptions() {
        Map<String,Object> notificationMap = new Map<String,Object>();
        Map<String,Object> noArguments = new Map<String,Object>();
        notificationMap.put('Opportunity Team', noArguments);
        notificationMap.put('Opportunity Team - Sales Only', noArguments);
        return notificationMap;
    }
    global override Map<String,Object> customNotificationRule(SObject primary, Map<String, SObject> chosenSObjects, String parameter, Map<String,Object> additionalFields){
        Map<String,Object> returnMap = new Map<String,Object>();
        if(parameter == 'Opportunity Team') {
            Set<Id> resultSet = new Set<Id>();
            Set<String> emailSet = new Set<String>();
            if (chosenSObjects.get('L2O') != null) {
                SObject matchedOpportunity = chosenSObjects.get('L2O');
                
                List<OpportunityTeamMember> opportunityTeamMembers = [SELECT UserId, User.Email FROM OpportunityTeamMember WHERE OpportunityId = :matchedOpportunity.Id];
                
                //extract the userIds
                if (opportunityTeamMembers.size() > 0) {
                    for (OpportunityTeamMember member : opportunityTeamMembers) {
                        resultSet.add((Id) member.UserId);
                    }
                }
            }
            returnMap.put('userIds', resultSet);
            returnMap.put('emails', emailSet);
            return returnMap;
        } else if (parameter == 'Opportunity Team - Sales Only'){
            Set<Id> resultSet = new Set<Id>();
            Set<String> emailSet = new Set<String>();
            Set<String> listOfRoles = new Set<String>();
            listOfRoles.add('Adyen v2 Sales');
            listOfRoles.add('Adyen v2 Sales Lead');
            if (chosenSObjects.get('L2O') != null) {
                SObject matchedOpportunity = chosenSObjects.get('L2O');
                
                List<OpportunityTeamMember> opportunityTeamMembers = [SELECT UserId, User.Email FROM OpportunityTeamMember WHERE OpportunityId = :matchedOpportunity.Id AND TeamMemberRole IN :listOfRoles];
                
                //extract the userIds
                if (opportunityTeamMembers.size() > 0) {
                    for (OpportunityTeamMember member : opportunityTeamMembers) {
                        resultSet.add((Id) member.UserId);
                    }
                }
            }
            returnMap.put('userIds', resultSet);
            returnMap.put('emails', emailSet);
            return returnMap;
        }
        
        return null;
    }
    
}