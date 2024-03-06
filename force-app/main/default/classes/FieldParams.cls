/**
 * @description   : Class to to pass field params label/type/api to from lightning      
 * @author (s)    : BRITE
 */
global class FieldParams {
    @AuraEnabled
    public String name {get; set;}
    @AuraEnabled
    public String label {get; set;}
    @AuraEnabled
    public Schema.DisplayType ftype {get; set;}
    public FieldParams (String name, String label, Schema.DisplayType ftype) {
        this.name = name;
        this.label = label;
        this.ftype = ftype;
    }
}