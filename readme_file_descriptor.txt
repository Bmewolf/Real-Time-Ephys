RTEphys.mdl is a Simulink Model of the signal processing engine for testing modifications

RTEphsEng.mdl is the Simulink model file used to create the netlist for integration into the hardware system. It has the engine in it (from above)
If you test and keep changes to the engine, they should be also included in this model.

cnt_state_machine.m  is the Matlab file containing the State Machine in the engine. It is needed for both of the models above.

 