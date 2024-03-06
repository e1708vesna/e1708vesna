public with sharing class ProductCtrl {
    static Integer PAGE_SIZE = 9;

    public class Filters {
        @AuraEnabled
        public String searchKey { get; set; }
        @AuraEnabled
        public Decimal maxPrice { get; set; }
        @AuraEnabled
        public String[] categories { get; set; }
        @AuraEnabled
        public String[] types { get; set; }
        @AuraEnabled
        public String[] genders { get; set; }
    }

    @AuraEnabled(Cacheable=true)
    public static PagedResult getProducts(Filters filters, Integer pageNumber) {
        String key, whereClause = '';
        Decimal maxPrice;
        String[] categories, types, genders, criteria = new List<String>{};
        if (filters != null) {
            maxPrice = filters.maxPrice;
            types = filters.types;
            genders = filters.genders;
            if (!String.isEmpty(filters.searchKey)) {
                key = '%' + filters.searchKey + '%';
                criteria.add('(Name LIKE :key OR ProductCode LIKE :key OR Type__c LIKE :key)');
            }
            if (filters.maxPrice >= 0) {
                maxPrice = filters.maxPrice;
                criteria.add('MSRP__c <= :maxPrice');
            }
            if (filters.categories != null) {
                categories = filters.categories;
                criteria.add('Category__c IN :categories');
            }
            if (filters.genders != null) {
                genders = filters.genders;
                criteria.add('Gender__c IN :genders');
            }
            if (filters.types != null) {
                types = filters.types;
                criteria.add('Type__c IN :types');
            }
            if (criteria.size() > 0) {
                whereClause = 'WHERE ' + String.join(criteria, ' AND ');
            }
        }
        Integer pageSize = ProductCtrl.PAGE_SIZE;
        Integer offset = (pageNumber - 1) * pageSize;
        PagedResult result = new PagedResult();
        result.pageSize = pageSize;
        result.pageNumber = pageNumber;
        result.totalItemCount = Database.countQuery(
            'SELECT count() FROM Product2 ' + whereClause
        );
        result.records = Database.query(
            'SELECT Id, Name, Description, MSRP__c, Category__c, Gender__c, Type__c, DisplayUrl, ProductCode FROM Product2 ' +
            whereClause +
            ' WITH SECURITY_ENFORCED' +
            ' ORDER BY Name LIMIT :pageSize OFFSET :offset'
        );
        return result;
    }

    @AuraEnabled(Cacheable=true)
    public static Product2[] getSimilarProducts(Id productId, String familyId){

        return [
            SELECT
                Id,
                Name,
                Description,
                MSRP__c,
                Category__c,
                Gender__c,
                Type__c,
                DisplayUrl,
                ProductCode
            FROM Product2
            WHERE Id != :productId 
              AND Category__c = :familyId 
            WITH SECURITY_ENFORCED
        ];
    }

}