
// Sound Synthesis in SuperCollider

// boot and start scope to view waveforms
(
s.boot;
Server.local.scope(2);  // view stereo output waveforms
)

// For convenience we will be using a shortcut construction for practicing sound synthesis. Later we will see another way of doing this that is more commonly used, but the Function.play notation below is good for sketching.

{
//some synthesis code
}.play

/* Unit Generators

SuperCollider follows the Unit Generator paradigm also used in other synthesis languages like Csound, Max/MSP, PD, Reaktor and others.

There are many primitive building blocks, like types of tone generators, filters or spatializers, that are the unit generators. These are connected together in a processing graph to make more complicated synthesizers and sound processors. These primitives are referred to as UGens.

Each UGen has some set of inputs and outputs. Most UGens have just one output, an audio stream or some sort of control signal. The inputs vary a lot depending on the function of the UGen.

Each UGen is defined to have specific named arguments, which might include audio or control signals (outputs of other UGens) that change continuously, or that have fixed values that can be 'set'.
*/


/*   Subtractive Synthesis

In subtractive synthesis, we start with a complex source, and we subtract parts from this raw sound to make a more sculpted sound. This is also termed a source+filter model. */

{WhiteNoise.ar(0.1)}.play //this line will make a pure white noise source, equal energy at all spectral frequencies. The first argument ('arg'), named 'mul', multiplies the output of the white noise, which sets its amplitude.  0.1 sets the amplitude at 0.1 of maximum volume.  To stop all sounds playing, type Cmd+period!

// Next, wrap a filter around the white noise to filter it --

{LPF.ar(WhiteNoise.ar(0.1),1000)}.play

/*  NESTING

The LPF is a Low Pass Filter which reduces more and more energy above its cutoff frequency, which is 1000Hz in this example.  The first arg of any filter is the input signal -- to plug the noise into the filter, you 'nest' it as the input argument of the filter.  The UGen's arguments are like a list of slots within the parenthesis, where the order of the argument in the list defines its function within the UGen:

LPF.ar(in,freq,mul,add), meaning
Low-Pass Filter at audio-rate (input signal, cutoff frequency, amplitude, signal-output center )
In the WhiteNoise filter example above, the input signal slot is filled with a white noise UGen;  the filter cutoff frequency is given by the 2nd argument, the fixed number 1000; and the last two arguments are not given so they are the default values:1 for amplitude and 0 for output center (which you can see in LPF's helpfile, by selecting LPF and typing cmd-D, or by typing 'LPF.ar( ', when the names and defaults pop up) .

Let's say that we now want a varying filter cutoff over time. One UGen we could use here is the line generator, Line:
*/

Line.kr(10000,1000,10) // this Line takes ten seconds to go from 10000 to 100.  Type this for yourself, and you will see the editor show you that names and positions of the args for Line are: (start, end, dur).  cmd-D will also give you plenty of info and examples on how to use it.  Also note the '.kr' method defines this Line object as operating at 'control rate', which requires a lot less cpu time to generate signals that don't need to be as fast as audio signals to perform their role.

// So to replace the fixed value 1000, the Line UGen goes in that second slot:

{LPF.ar(WhiteNoise.ar(0.1),Line.kr(10000,100,10))}.play

// The Line changes linearly, meaning the same amount with each second.  But we hear changes in pitch-change exponentially, so let's change Line to XLine, to produce the effect of an even change of pitch:

{LPF.ar(WhiteNoise.ar(0.1),XLine.kr(10000,100,10))}.play

// To use the mouse or trackpad to tune the filter, try this:

{LPF.ar(WhiteNoise.ar(0.1),MouseY.kr(10000,100,1))}.play  // check out the helpfile to learn about its 3rd and 4th arguments 'warp' and 'lag'

/*
There are lots of possible sources and filters, so select the ones below and try creating Synths using different combinations of them, or explore further in the Tour_of_UGens (select Browse menu in HelpBrowser, then choose UGens:

Oscillators: Saw, Blip, Pulse
Noise Sources: PinkNoise,LFNoise0
filters: HPF, BPF, RHPF, RLPF, Resonz, Ringz  -- check out the differences between resonant and non-resonant filters (resonant filters can produce gain in the passband
*/

// Example of plugging one source into a filter:

{Resonz.ar(LFNoise0.ar(400),1000,0.1)}.play

// now using the XLine generator to change the filter centre frequency over time

{Resonz.ar(LFNoise0.ar(400),XLine.kr(10000,1000,10),0.1)}.play

// Nesting can make things hard to read!  Here's a neater, but wordier way to write this - note that a semicolon marks the end of a defined action: the compiler parses each expression up to the semicolon, before moving to the next one:

(
{ var source, line, filter;  // these words are declared as variables, which can only be done at the beginning of the code to be compiled or of a Function within which it applies
source=LFNoise0.ar(400);  // the variables are equated to UGens with specific values
line=XLine.kr(10000,100,10);
filter=Resonz.ar(source,line,0.1);  //  variables are plugged into args of the filter
filter // last line in a {}.play (function.play), is the output of the Synth that it creates
}.play;
)

/*
Additive Synthesis

Rather than starting with something complex and taking energy away to sculpt a sound, we can start with simple building blocks and add many of them together to create more involved sounds.  The classic building block in computer music is the sine tone
*/

{SinOsc.ar}.play //defaults to a concert A (440Hz)

// Here is one way to get two sine tones at once:

{SinOsc.ar(400,0,0.1) + SinOsc.ar(660,0,0.1)}.play

// Multichannel sound is really easy to create in SC,  by using an array.

{SinOsc.ar([400,660],0,0.1)}.play

/*
This is called 'Multichannel Expansion': the square bracket created an Array, which is plugged into the 'freq' arg of SinOsc.  This results in two SinOsc ugens playing on adjacent audio busses (or channels) -- thus one on left and one on the right channel.  Arrays have special properties, but for now just think of them as lists of data.  An Array nested as an argument of a UGen creates an Array of the same number of UGens as it has elements.  More than one argument can be filled with an Array, where the nth element in the array is applied to the nth channel's argument -- if the Arrays are unequal in size, the smaller Arrays values wrap from the beginning
*/

[100,200,300,400,500] //5 numbers in a list

// Each successive element in the list will be placed on one channel:

{SinOsc.ar([400],0,0.1)}.play //one channel sound

{SinOsc.ar(400,0,0.1)}.play //also one channel sound- no array brackets are needed for a single number

{SinOsc.ar([400,660],0,0.1)}.play //two channel sound

{SinOsc.ar([400,660,870],0,0.1)}.play //three channel sound - you may only hear two, because you probably have a stereo output on your computer, not three channels

// We need a way to take multiple channels of sound and turn them into a mono or stereo signal. One method is to wrap the multichannel sound with a Mix UGen:

{Mix(SinOsc.ar([400,660,870],0,0.1))}.play //a three channel signal put through Mix turns into mono

// The Pan2 UGen controls the stereo spatialization of a UGen, where pan position goes from -1 (hard left) to 1 (hard right), which allows me to move this  mix in the stereo field:

{Pan2.ar(Mix(SinOsc.ar([400,660,870],0,0.1)),MouseX.kr(-1,1))}.play // pan the two mixed SinOsc's with the MouseX

// You are now equipped to explore additive synthesis via sine tones. In additive synthesis, if we know a recipe for the spectrum (frequency content) of a sound, we can synthesise it by adding up sine tones for each component frequency.

500*[0.5,1,1.19,1.56,2,2.51,2.66,3.01,4.1] //This is a spectral recipe for a minor third bell, at a base frequency of 500 -  multiplying a number by an Array of other numbers produces a new Array with products of the first number and every  number in the original Array

{Mix(SinOsc.ar(500*[0.5,1,1.19,1.56,2,2.51,2.66,3.01,4.1],0,0.1))}.play //bell spectra, all partials the same volume

// An Array of amplitudes provides an amplitude for each oscillator in the mix, rather than defaulting them all to 0.1

{Mix(SinOsc.ar(500*[0.5,1,1.19,1.56,2,2.51,2.66,3.01,4.1],0,0.1*[0.25,1,0.8,0.5,0.9,0.4,0.3,0.6,0.1]))}.play //bell spectra, different volumes for partials

// Here is a generalisable patch that uses the variable 'num' to hold the number of sine tones desired for each run of the code:
(
var num;	// the variable 'num' will be used to represent a given, or changeable, value throughout the program that follows (but not outside it!)
num=10;	// this is called an assignment statement:  it assigns the integer value 10 to the variable
{Mix(SinOsc.ar(250*(1..num),0,1/num))}.play;
)

// If you're unsure what something is in code, investigate it in isolation:
(1..10) //run this line and see what comes up in the post window -- it creates an Array!


/*
UGen Arguments

Mul and Add

These two arguments recur in many UGens, and they provide a way of keeping signals scaled appropriately to be used for listening, as well as for control or audio inputs to other UGens. The audio output of the computer expects amplitudes in the range -1.0 to 1.0, and  frequencies from 20 to 20000, and the mul and add arguments are used to scale and offset the outputs of UGens to these, or other, ranges.

'mul' and 'add' are often the final arguments of many signal generators -- check the SinOsc help file now:

[SinOsc] //cmd+d  after double clicking anywhere on SinOsc

Notice that 'mul' is the third and 'add' is the fourth - you set these arguments either by placing numbers in the set argument order, like this:
*/

{ SinOsc.ar(440,0,0.25,0)}.play  // mul = 0.25, add = 0

// ..or you can directly address any arguments to ugens  by using the keyword syntax (argname:value), in which the order doesn't matter:

{SinOsc.ar(mul:0.25, freq:880)}.play   // the other arguments revert to default values, which you can see while you type the above line in the editor, or in their help files

/*
'mul' is an amplitude multiplier, so it scales the signal on the y axis.  For audio outputs ( the 'ar' method specifies audio rate) the values must be kept between -1 and 1, otherwise they overshoot the sound driver and the waveform is clipped (made square).
*/

{SinOsc.ar(mul:MouseY.kr(4,0.1))}.play		//demo of amplitude scaling

// The 'add' argument is used to offset a waveform on the y axis.

{SinOsc.ar(mul:0.4, add:MouseY.kr(0.9,-0.9))}.play		//demo of offsetting

// 'add' is particularly useful for frequency modulation, where the output of one oscillator controls the frequency of another - the moulator's output should swing between 440 and 0 -- 'poll' is a method that sample the value of a UGen and sends it to the language -- its argument sets the sampling rate

(
{ var mfrq=MouseX.kr(1,440,1);
	SinOsc.ar(SinOsc.ar(mfrq,mul:mfrq*MouseY.kr(1,10).poll(10),add:440), mul: 0.1)
}.play
)

// There is a shortcut for the mul and add inputs given by using the * and + symbols.

{SinOsc.ar*0.1}.play

// is the same as

{SinOsc.ar(mul:0.1)}.play

// and

{0.1*SinOsc.ar+0.5}.play

// is the same as

{SinOsc.ar(mul:0.1,add:0.2)}.play

/*

SinOsc.ar(freq, phase, mul, add)

Using the SinOsc UGen in code you must provide appropriate values for its input arguments. These values can be fixed constants, or they could be other UGens, in which case they will probably be time varying values. If I don't specify a given input, a default value will be used.
*/

// Explicit use of constants in all inputs:

{SinOsc.ar(440, 0.0, 0.1, 0.0)}.play

// Plugging a UGen, a MouseX control, into the frequency input:

{SinOsc.ar(MouseX.kr(440,880), 0.0, 0.1, 0.0)}.play

//Having the frequency argument as before (it is the first input, remember), using the colon to refer to a particular input, and accepting defaults for the rest:

{SinOsc.ar(MouseX.kr(440,880), mul:0.1)}.play

// There are often many ways of accomplishing something. For instance, to limit the volume of a single SinOsc, we might write:

{SinOsc.ar(440,0.0,0.1)}.play			//provide freq and mul arguments directly

{SinOsc.ar(mul:0.1)}.play			//provide just the multiplier argument explicitly

{0.1*SinOsc.ar}.play					//multiply the SinOsc UGen by a constant

{SinOsc.ar(440, mul: -20.dbamp)}.play   //use dBs, since 'dbamp' converts to a 0-1 value just once at the initialisation of the UGen

/*
Envelopes

We have been making sounds so far that go on forever until we press a key to stop synthesis.  Most of the time, we'll want to make sounds that go on for a limited time, and stop of their own accord.  Here's one way:
*/

{SinOsc.ar(440,0,Line.kr(0.1,0.0,1.0))}.play	 	//One second for the sine amplitude to go from 0.1 to 0.0 -- but the Synth is still running even though it's not audible!

/*  An Envelope should create any type of shape to control any parameters of a sound (first of all volume and/or frequency) over time. It should also be able to turn off a sound when the volume envelope completes.

see help files for [Env] [EnvGen]
*/

Env.new([1,0,1],[1.0,0.5]).plot  //This makes and displays an Envelope with three control points at y positions given by the first array,  separated in x time axis by the two values in the second array (see the Env help file).  The .plot gives a quick way of seeing the envelope- we don't need it for synthesis but it helps for designing shapes


//various types of envelope demonstrated - see helpfile to learn about types of curves you can use:

Env.new([0,1,0],[1.0,0.5]).plot  //one second 0 to 1 then half a second 1 to 0
Env.new([0.001,1,0.001],[1.0,0.5],\exp).plot  //same with exponential curves (note that points can't be zero because an exponential function can never reach its target!

Env.linen(0.3,0.5,0.1,0.5,-2).plot  //linen has arguments attacktime, sustaintime, releasetime, sustainlevel, curve

Env.adsr(0.01, 0.5, 0.5, 0.1,0.5,-4).plot  //attacktime, decaytime, sustainlevel, releasetime, peaklevel, curve

Env.perc(0.05,0.5,1.0,-8).plot //arguments attack, release, level, curve - good for percussive envelopes

// The EnvGen UGen is used to play any desired Env. A simple sine tone at 440Hz  is multiplied by a 1 sec linear envelope

{SinOsc.ar(440,0,0.1)*EnvGen.kr(Env.new([1,0],[1.0]))}.play

// Design an envelope to control frequency:

Env.new([1000,20],[1.0]).plot

// The EnvGen that plays it is plugged into the frequency input of the Saw wave:

{Saw.ar(EnvGen.ar(Env.new([1000,20],[1.0])),0.1)}.play

// Next, change the frequency of Saw over 0.5 second and make its amplitude go to zero over 2 seconds:

{Saw.ar(EnvGen.ar(Env.new([10000,20],[0.5])),EnvGen.ar(Env.new([0.1,0],[2.0])))}.play

// Since the nesting makes it difficult to read, writing this way makes it clearer

(
{
	Saw.ar(
		EnvGen.kr(Env.new([10000,20],[0.5])),  //frequency input
		EnvGen.kr(Env.new([0.1,0],[1.0]))          //amplitude input
	)
}.play
)

//Note that the EnvGens in the first version are (.ar) audio rate and in the second are control rate (.kr), but there's no real difference to our ears. Use .kr when possible, because it means a lower CPU load and ultimately we can run many more oscillators at once.

// EnvGens can also cause a running Synth to end once an envelope has run its course.

//FM sound
({

SinOsc.ar(
	SinOsc.ar(10,0,100,440),  // add:440 offsets the output of this oscillator from 0 t0 440, so that it always provides an audio frequency to the oscillator we hear
	0.0,  // phase
	EnvGen.kr(Env.new([0.5,0.0],[1.0]), doneAction:2)
	)
}.play
)

// The 'doneAction' argument assigned the value 2 means that the envelope on completion causes its enclosing synthesizer to be 'freed', or ended.  The only thing that matters is how long the envelope lasts in time - it doesn't matter which parameter the EnvGen controls

{Saw.ar(EnvGen.kr(Env.new([500,100],[1.0]),doneAction:2),0.1)}.play

// Note how the server status display shows the Synths starting then ending. We already saw some UGens that can be used like Envelopes, without the two stage Env/EnvGen construction. They work with deallocation too - here are examples:

Line		//straight line generator
XLine		//exponential line generator

{Saw.ar(SinOsc.ar(1,0,10,440),Line.kr(0,1,1,doneAction:2))}.play

{Saw.ar(SinOsc.ar(1,0,10,440),XLine.kr(0.0001,1,1,doneAction:2))}.play

