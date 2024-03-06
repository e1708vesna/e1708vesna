public with sharing class FeatureFlags implements IFeatureFlags {

    private Map<String, FeatureFlag__mdt> features;
    private Set<String> customPermissionNames;
    private static Map<String, Boolean> mockValues = new Map<String, Boolean>();


    public FeatureFlags(IFeatureFlagProvider provider) {
        features = provider.getFeatureFlags();
        customPermissionNames = provider.getCustomPermissionNames();
    }

    public FeatureFlags() {
        this(new FeatureFlagProvider());
    }

    public FeatureEvaluationResult evaluate(String featureName) {

        if (Test.isRunningTest() && mockValues.containsKey(featureName)) {
            return new FeatureEvaluationResult(mockValues.get(featureName), featureName, FeatureReason.MOCK_VALUE);
        }

        FeatureEvaluationResult result;

        if (customPermissionNames.contains(featureName)) {

            if (FeatureManagement.checkPermission(featureName)) {
                result = new FeatureEvaluationResult(true, featureName, FeatureReason.HAS_CUSTOM_PERMISSION);
            } else {
                result = new FeatureEvaluationResult(false, featureName, FeatureReason.MISSING_CUSTOM_PERMISSION);
            }

        }

        else {

            if (features.containsKey(featureName)) {

                if (features.get(featureName).IsActive__c) {
                    result = new FeatureEvaluationResult(true, featureName, FeatureReason.CUSTOM_METADATA_TYPE_ENABLED);
                } else {
                    result = new FeatureEvaluationResult(false, featureName, FeatureReason.CUSTOM_METADATA_TYPE_DISABLED);
                }

            } else {
                result = new FeatureEvaluationResult(false, featureName, FeatureReason.FLAG_NOT_FOUND);
            }
        }

        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean lwcEvaluate(String featureName) {
        return new FeatureFlags().evaluate(featureName).isEnabled();
    }

    /**
     * @description Checks if the provided feature is enabled on user level (custom Permission) or org level (FeatureFlag__mdt)
     * @param featureNames List of feature names to check. Should be the same for every record in the context, as only the first feature is checked.
     * @author Folkert Heeneman
     * @date November 2023
     * @return List of Booleans indicating whether the provided feature is active, per record in the context. Will be the same value for all records as the feature flags do not change during the execution
     */
    @InvocableMethod(label='Feature Flag Check'
            description='Checks if the provided feature is enabled on user level (custom Permission) or org level (FeatureFlag__mdt)' iconName='slds:standard:toggle')
    public static List<InvocableMethodResult> invocableActionEvaluate(List<InvocableMethodInput> featureNames) {
        // Because all records in the execution context are executed with the same user, and feature flags do not change during execution
        // it suffices to check the feature once and return the same Boolean for all records.
        Boolean featureIsEnabled = new FeatureFlags().evaluate(featureNames[0].featureName).isEnabled();

        List<InvocableMethodResult> featureResults = new List<InvocableMethodResult>();
        for (InvocableMethodInput input : featureNames) {
            InvocableMethodResult result = new InvocableMethodResult();
            result.isFeatureEnabled = featureIsEnabled;
            featureResults.add(result);
        }

        return featureResults;
    }

    public class InvocableMethodInput {
        @InvocableVariable(Required=true Label='Feature Name' Description='The developer name of a custom permission or a FeatureFlag__mdt record representing a feature. Do not use different (dynamic) values, but use a static string. The goal is to check whether the feature is enabled for the user or the org, and this should not change per record.')
        public String featureName;
    }

    public class InvocableMethodResult {
        @InvocableVariable(Label='Is Feature Enabled?' Description='If the provided feature is enabled, either as a custom permission on the user or as a FeatureFlag__mdt record for the org, this will be true.')
        public Boolean isFeatureEnabled;
    }


    @TestVisible
    private static void setMockValue(String featureName, Boolean value) {
        mockValues.put(featureName, value);
    }


    public class FeatureEvaluationResult {

        private Boolean result;
        private String featureName;
        private FeatureReason reason;

        public Boolean isEnabled() {
            return result;
        }

        public String getFeatureName() {
            return featureName;
        }

        public FeatureReason getReason() {
            return reason;
        }


        public FeatureEvaluationResult(Boolean result, String featureName, FeatureReason reason) {
            this.result = result;
            this.featureName = featureName;
            this.reason = reason;
        }
    }

    public enum FeatureReason {
        HAS_CUSTOM_PERMISSION,
        MISSING_CUSTOM_PERMISSION,
        CUSTOM_METADATA_TYPE_ENABLED,
        CUSTOM_METADATA_TYPE_DISABLED,
        FLAG_NOT_FOUND,
        MOCK_VALUE
    }

}