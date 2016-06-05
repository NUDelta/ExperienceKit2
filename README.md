# ExperienceKit2

### Basic Structure

* The smallest unit in an experience is a `Moment`
* These Moments can be put together into a `MomentBlock`
* MomentBlocks can be injected in order in the `ExperienceManager` that runs the MomentBlocks in linear order.

### Importing

* Test app) pull and build in XCode. 

For use in other applications, follow the below instructions

* Copy and paste the `ExperienceKit` folder under `ExperienceTestSingle\ExternalLibs`
* Import all the libraries used in the sample project
* Make sure bridging headers are properly made (defined in Bridging-Header.h in the test app)
* Make sure that Parse keys are properly defined in the target app (defined in Constants.swift in the test app)


### Scaffolding

* Scenario) we might want to insert certain MomentBlocks in the event of certain situations that occur throughout the experinence. (ex. coming near a certain object of interest)
* This can be done by use of the `ScaffoldingManager`
* Moments can be inserted inside a simple array of moments named `MomentBlockSimple`, along with the `requirement` needed to activate that MomentBlock

* Usage) The ScaffoldingManager keeps looping through all the pool of MomentBlockSimples, upon when during the ExperineceManager, a `OpportunityPoller` is inserted.  

### Moment Types

* Moment: base class for all moments
* SilentMoment: class for all moments requiring the app to continue to run in the background at all times. 
* Interim: a moment that runs for X amount of seconds. 
* Sound: plays an array of sound files
* SynthVoiceMoment: plays a string through a synthesized voice.
* ConditionalMoment: user defines a condition (function), if the condition is deemed true, the 'true moment' is played, if the condition is deemed false, the 'false moment' is played'
* ContinuousMoment: continues the moment while a user defined function keeps returning true.
* FunctionMoment: convenience moment that runs a user defined function and finishes. 
* OpportunityPoller: keeps polling the ScaffoldingManager every X seconds, for a certain total length. 

