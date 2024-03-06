public class ChangedFieldsUtilityJelle {
    public static Schema.sObjectField[] getChangedFields(sObject o1, sObject o2) {
        Schema.sObjectField[] fieldList  = Schema.SObjectType.Case.fields.getMap().values();
        List<String> changedFields = new list<String> ();
        for (Schema.sObjectField field : fieldList) {
            Object v1 = o1.get(field);
            Object v2 = o2.get(field);
            if (didFieldChange(v1, v2)) {
                changedFields.add(String.valueOf(field));
            }
        }
        System.debug(Json.serializePretty(changedFields));
        return null;
    }
    
    private static Boolean didFieldChange(Object v1, Object v2) {
        if (v1 == null && v2 == null) {
            return false;
        }
        if (v1 != v2) {
            return true;
        }
        return false;
    }
}