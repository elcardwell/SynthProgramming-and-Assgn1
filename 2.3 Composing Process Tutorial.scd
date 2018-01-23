/* This SC Composing Tutorial shows ...
1) how to start with Function.play to sketch a sound
2) then use that Function to define a SynthDef
3) edit the Function in an Ndef where you hear the sound while tweaking its argument parameters with a GUI
4) then save the Ndef Function as a newly refined version of the SynthDef
5) then use it in a using a Pdef EventPatternProxy where you can edit an algorithmic sequence while it plays
6) then combine multiple Pdefs and play them with Ppar
*/

// let's say we want to rock our car with a low-boom bass
// start with a sinewave function

{ SinOsc.ar([60,120],0,0.20) }.play  // an Array as the argument creates "multichannel expansion", two sinewaves on adjacent channels, one with 60 and one with 120 cps

// play it with an envelope, notice how the Server window shows a Synth is created, then stops itself -- this because of 'doneAction: 2', which means when the envelope completes, it kills the Synth that it's part of
{ SinOsc.ar([60,120],0,0.20)*EnvGen.kr(Env.perc,doneAction:2) }.play

// turn this into a SynthDef -- the first argument is its name, and the synthesis function requires an explicit output statement
(
SynthDef(\boom,{
	var sig = SinOsc.ar([60,120],0,0.2)*EnvGen.kr(Env.perc,doneAction: 2);  // variable 'sig' represents the synthesis graph
	Out.ar(0,sig)  // this is played on output 0 (left channel)
}).add;    // 'add' sends this definition to the Server, so that it can play it on command
)
// 'Synth' plays a named SynthDef
Synth(\boom);
// any number of them can be played at the same time -- here, we use a "do-loop" to play 100 Synths, starting each at a randomly chosen time ('defer')  within 10 seconds
100.do ({ {Synth(\boom) }.defer(10.0.rand) });

// an Ndef (Node definition) is really useful for designing a SynthDef, because we can edit it while it plays - so we'll first replace the percussion envelope with one that repeats without stopping itself -- An Env is just a shape -- it's first argument is an Array that specifies points, and the second specifies the time in seconds between each point --display it using 'plot'
Env.new([0,1,0,0],[0.01,0.5,0.01],-4,2,0).plot  // the last two arguments set a repeating loop -- see Env help-file to see how that works!
// compile the Ndef first
(
Ndef(\boom,{ arg freq=60,dur=0.5;  // provide arguments that can be edited
	var sig = SinOsc.ar([freq,freq*2],0,[0.2,0.1]);  // use variable to make code more readable
	sig*EnvGen.kr(Env.new([0,1,0,0],[0.01,dur,0.01],-4,2,0));
});
)
Ndef(\boom).play.gui;  // now play it, and create a gui with which to adjust values of arguments

// now lets compile some changes that will replace the old definition while it plays
(
Ndef(\boom,{|freq=60,dur=0.5,pan=0|
	var sig = Mix(SinOsc.ar([freq,freq*2],0,[0.2,0.1])); // mix both sinewaves into a mono signal
	sig = sig*EnvGen.kr(Env.new([0,1,0,0],[0.01,dur,0.01],-4,2,0)); // apply the envelope
	Out.ar(0,Pan2.ar(sig,pan))   // Pan2 places mono signal in stereo position
});
)
// let's thicken the sound with chorusing, and add a 'fold' distortion, and provide arguments to edit each while hearing what you're doing,
(
Ndef(\boom,{|freq=60,dur=0.5,phs=0.2,fold=0.6,pan=0,amp=0.2|
	var sig = Mix(SinOsc.ar([freq,freq*0.97],[0,2pi*phs])); // creates stereo chorus
	sig = sig*EnvGen.kr(Env.new([0,1,0,0],[0.01,dur,0.01],-4,2,0));
	sig = sig.fold2(fold);   // creates distortion
	Out.ar(0,Pan2.ar(sig,pan,amp))  // 'amp' argument is output volume control
})
)

// return the function to a SynthDef, once you've found settings that you like, making these the default values for the arguments, and and replace the percussion envelope
(
SynthDef(\boom,{|freq=60,dur=0.2,amp=0.2,fold=0.6|
	var sig = SinOsc.ar([freq,freq*0.97],[0,2pi*0.015]); // creates stereo chorus
	sig = sig*EnvGen.kr(Env.perc,doneAction: 2);
	sig = sig.fold2(fold);   // creates clip
	Out.ar(0,sig*amp)
}).add;
)
Synth(\boom);

// now you can  play 100  of them in 10 seconds, each with a different freq and fold
100.do ({ {Synth(\boom,[\freq,rrand(60,120),\fold,1.0.rand])}.defer(10.0.rand) });

// now create a Pbind  EventPattern to see how it sounds in rhythm
(
Pbind(\freq,40,    // a Pbind plays a sequence defined by pairs of arguments and values
	\instrument,\boom,   // this specifies the name of a SynthDef
	\amp,0.4,
	\fold,0.6,
	\dur,Pseq([0.4,0.1,0.25,0.25],inf),  // a list of values played some number of times
	\curve,Pstutter(4,Pseq([-4,-2,4,2,-8,-6,8,6],inf)),  // this algorithm  repeats each value from a list some number of times
	).play
)
(
Pdef(\x,   // a Pdef is a EventPatternProxy that allows you to edit the Pattern while playing
	Pbind(\freq,40,
		\instrument,\boom,
		\amp,0.4,
		\fold,Pstutter(4,Pseq([0.2,0.4,0.8,1.0,0.6],inf)),
		\dur,Pseq([0.4,0.1,0.25,0.25],inf)
	)
);
)
Pdef(\x).play  // play that pattern
// next, edit the Pdef code above while it plays, and compile it again while it plays, and you'll hear it change smoothly
Pdef(\x).stop

// next go ahead and change some parameters in the Pdef(\x) definition,

// here's another example:  we design a Sawtooth voice for melody -- let's start this time with an Ndef  including arguments so we can design while hearing
Ndef.clear; //  if a NdefGui gets confusing thru many edits, close its window and execute this
ControlSpec.specs[\rng]=[0,0.05].asSpec;  // this set a range for the slider of arg 'rng'
(
Ndef(\fltSaw,{ arg freq=100,ffrq=800, spd=1.0, rng=0, rq=0.2, amp=0.2;
	var modOsc = SinOsc.kr(spd,0,rng,1);  // output oscillates around 1 (var declarations only at top of def
	RLPF.ar(
		Saw.ar(freq*modOsc,  // its freq is modulated by an LFO
			amp),
		ffrq,rq,amp)})
)
Ndef(\fltSaw).gui   // click the 'play' button to start the sound

// past your Ndef function with preferred starting values of args into a SynthDef
(
SynthDef(\fltSaw,{ arg freq=130,ffrq=800, spd=5.0, rng=0.005, rq=0.02, amp=0.2,pan=0,
	dur=1,att=0.1,rls=0.2,gate=1;
	var sig, modOsc,env;
	env = EnvGen.kr(Env.asr(att,1,rls),gate,doneAction: 2);
	modOsc = SinOsc.kr(spd,0,rng,1);  // output oscillates around 1 (var declarations only at top of def
	sig = RLPF.ar(
		Saw.ar(freq*modOsc,  // its freq is modulated by an LFO
			amp),
		ffrq,rq,amp);  //  Lag smooths out abrupt changes to the filter
	Out.ar(0,Pan2.ar(sig*env,pan))
}).add;
)
(
~freqRise=[400,600,800,1200,1400,1600,1800,2000];
Pdef(\y,
	Pbind(\instrument,\fltSaw,
		\ffrq,Pstutter(6,Pseq(~freqRise++~freqRise.reverse,inf)),
		\degree,Pseq([0,3,5,-2],inf),  // freq given in terms of  degree of a scale
		\octave,3,        // octave of the scale
		\scale,Scale.minor,    // try other scales!  See Scale helpfile for options
		\att,0.01,
		\rls,0.3,
		\dur,0.25,
		// try adding changing \legato value to the Pbind
	)
);
)
Pdef(\y).play
// try editing the values of Pdef(y) and recompile while it plays
Pdef(\y).stop;

// now combine the patterns
Pdef(\z,Ppar([Pdef(\x),Pdef(\y)]));
Pdef(\z).play;
Pdef(\z).stop

Pdef.clear
