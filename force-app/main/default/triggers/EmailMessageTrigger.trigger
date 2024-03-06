trigger EmailMessageTrigger on EmailMessage (before insert, before update, before delete, after insert, after update, after delete) {
    new EmailMessageServiceTrgHndl().run();
}