/**
 * @description   : Interface of the ...BtchSchd classes to be able to call them dynamically
 * @author (s)    : Brite
 **/
global interface BtchSchdInf {
    void scheduleWakeup(Boolean direct);
    void scheduleStop();
    void scheduleSolo();
}