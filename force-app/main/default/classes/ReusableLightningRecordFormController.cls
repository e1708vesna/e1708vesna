/**
* @author Sales
* @group Component Controller
* @description Controller for reusableLightningRecordForm LWC
* fetches fieldset to decide  the fields
* to be shown on record create form
*/
public class ReusableLightningRecordFormController {

    /* @Description fetches the fields to be displayed on Call to Action Form
    * @Param objectAPIName object on which the field set is defined
    * @Param fieldSetName field set from where the fields need to be fetched
    * @Return List<String> fields to be displayed
    */
    @AuraEnabled
    public static List<String> getFields(String objectAPIName, String fieldSetName) {
        return processFieldList(objectAPIName, fieldSetName);
    }
    
    private static List<String> processFieldList(String objectAPIName, String fieldSetName) {
        List<String> fieldsToBeDisplayed = new List<String>();
        Schema.SObjectType objectType = null;

        if (String.isNotBlank(objectAPIName)) {
            objectType = Schema.getGlobalDescribe().get(objectAPIName);
        }

        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();

        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            fieldsToBeDisplayed.add(fsm.fieldPath);
        }

        return fieldsToBeDisplayed;
    }
}