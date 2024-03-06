/**
 * https://twitter.com/Joy_SH/status/738087166547398656
 * https://help.salesforce.com/apex/HTViewSolution?id=000175908&language=en_US
 */ 
public with sharing class LeadConvertedViewController {

    public Lead record { get; private set; }

    public LeadConvertedViewController( ApexPages.StandardController stdController ) {
        this.record = (Lead) queryRecord( stdController.getId() );
    }

    private SObject queryRecord( ID recordId ) {

        // https://douglascayers.wordpress.com/2015/10/08/salesforce-how-to-select-all-fields-with-soql-in-apex/

        DescribeSObjectResult describeResult = recordId.getSObjectType().getDescribe();

        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );

        String query =
          ' SELECT ' +
              String.join( fieldNames, ',' ) +
          ' FROM ' +
              describeResult.getName() +
          ' WHERE ' +
              ' id = :recordId ' +
          ' LIMIT 1 '
        ;

        List<SObject> records = Database.query( query );

        return ( records.size() > 0 ) ? records[0] : null;
    }

}