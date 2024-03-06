trigger SkillChangeEventTrigger on SkillChangeEvent (after insert) {
	System.debug('** SkillChangeEvent');	
}