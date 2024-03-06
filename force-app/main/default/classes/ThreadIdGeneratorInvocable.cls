/*
 * @name ThreadIdGeneratorInvocable
 * @author Service
 * @group Invocable Apex
 * @description This class provides an invocable method for generating a ThreadId for Case records. This utility is useful when constructing email threads related to Cases.
 */
public class ThreadIdGeneratorInvocable {

    /*
     * CaseInput inner class represents the input structure for the invocable method. It primarily accepts a Case ID.
     */
    public class CaseInput {
        // Case ID from Case record
        @InvocableVariable(required=true)
        public Id caseId;
    }

    /*
     * StringOutput inner class represents the output structure from the invocable method. It returns the generated Thread ID.
     */
    public class StringOutput {
        // Generated Thread ID for the given Case ID
        @InvocableVariable
        public String threadingMessageId;
    }

    /*
     * generateThreadId is an invocable method that accepts a list of Case IDs and returns a list of generated Thread IDs.
     * @param cases - List of input Case IDs
     * @return List<StringOutput> - List of generated Thread IDs
     */
    @InvocableMethod(label='Generate Thread ID' description='Generates a Thread ID for the provided Case ID')
    public static List<StringOutput> generateThreadId(List<CaseInput> cases) {
        List<StringOutput> outputs = new List<StringOutput>();

        // For each input Case ID, generate the corresponding Thread ID
        for(CaseInput caseInput : cases) {
            StringOutput output = new StringOutput();
            output.threadingMessageId = EmailMessages.getFormattedThreadingToken(caseInput.caseId);
            outputs.add(output);
        }

        return outputs;
    }
}