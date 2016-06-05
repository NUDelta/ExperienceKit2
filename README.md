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

### ExperienceManager

* The current experience can be started / paused / resumed / stopped through the ExperienceManager

### Scaffolding

* Scenario) we might want to insert certain MomentBlocks in the event of certain situations that occur throughout the experinence. (ex. coming near a certain object of interest)
* This can be done by use of the `ScaffoldingManager`
* Moments can be inserted inside a simple array of moments named `MomentBlockSimple`, along with the `requirement` needed to activate that MomentBlock

Usage) 
* Insert an `OpportunityPoller` within the experience.
* While playing the OpportunityPoller during the experience, the ScaffoldingManager shall continue to compare current conditions of the environment against the requirements of each of the MomentBlockSimples.
* If any of the requirements are met, then the MomentBlockSimple with the highest score is returned.
* The returned MomentBlockSimple has its moments inserted into the experience, delaying the remaining moments.   

### Moment Types

* `Moment`: base class for all moments
* `SilentMoment`: class for all moments requiring the app to continue to run in the background at all times. 
* `Interim`: a moment that runs for X amount of seconds. 
* `Sound`: plays an array of sound files
* `SynthVoiceMoment`: plays a string through a synthesized voice.
* `ConditionalMoment`: user defines a condition (function), if the condition is deemed true, the 'true moment' is played, if the condition is deemed false, the 'false moment' is played'
* `ContinuousMoment`: continues the moment while a user defined function keeps returning true.
* `FunctionMoment`: convenience moment that runs a user defined function and finishes. 
* `OpportunityPoller`: keeps polling the ScaffoldingManager every X seconds, for a certain total length. 

### Data collection, management, pushing to the database

* Managed by the DataManager, which is initialised inside the ExperienceManager
* Object pushing is currently heavily linked to Parse
* The current context (state of the environment saved in the DataManager) can be saved through the ExperienceManager's `saveCurrentContext()` function. This can be used to ex. compare locations at a certain point in time against the current location. 

### Internals

* Internally, the ExperienceKit heavily uses the Events.swift library for message passing.
* Each moment, when inserted inside the ExperienceManager, is made so that it triggers an event that gets relayed to the ExperienceManager when it is paused, played, finished, etc. 
* This allows the ExperienceManager to know the state of the current moment, playing the next moment upon receiveing the message that the current moment has finished. 
