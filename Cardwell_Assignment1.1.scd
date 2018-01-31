(
Ndef(\gong,{ arg dur=5;
	var bell = Mix(SinOsc.ar(80*[0.5,1,1.19,1.56,2,2.51,2.66,3.01,4.1],0,0.1*[0.25,1,0.8,0.5,0.9,0.4,0.3,0.6,0.1]));
	bell*EnvGen.kr(Env.new([0,1,0],[0.01,dur],-4,2,0, 0.1))
}).play;
)
(
SynthDef(\gong,{ arg dur=5, amp=0.5;
	var bell = Mix(SinOsc.ar(80*[0.5,1,1.19,1.56,2,2.51,2.66,3.01,4.1],0,0.1*[0.25,1,0.8,0.5,0.9,0.4,0.3,0.6,0.1]));
	bell=bell*EnvGen.kr(Env.new([0,1,0,0],[0.01,dur,0.01],-4,2,0), doneAction: 2)*amp;
	Out.ar(0,bell);
}).add;
)
(
Pdef(\a,
	Pbind(
		\instrument, \gong,
		\dur, 5,
		\amp, 0.5
));
)
---
(
Ndef(\boom,{  arg freq=60,dur=1,pan=0;
	var sig = Mix(SinOsc.ar([freq,freq*2],0,[1,0.5]));
	sig = sig*EnvGen.kr(Env.new([0,1,0,0],[0.01,dur,0.01],-4,2,0));
	Out.ar(0,Pan2.ar(sig,pan))
});
)
(
SynthDef(\boom,{ arg freq=60,dur=1,pan=0,amp=1.0;
	var sig = Mix(SinOsc.ar([freq,freq*2],0,[0.75,0.2]));
	sig=sig*EnvGen.kr(Env.perc(0.01, dur), doneAction: 2)*amp;
	Out.ar(0,sig);
}).add;
)
(
Pdef(\b,
	Pbind(
		\instrument, \boom,
		\dur, 1,
		\freq, 60,
		\amp,Pseq([1, 0.5, 0.5, 0.5, 0.5],inf)
	)
);
)
---
(
SynthDef(\monky,{arg freq=60,ffrq=600,rq=0.3,spd=5,dur=0.2,amp=0.2,att=0.1,rls=0.25,gate=1,pan=0,rng=0.01;
	var sig, modOsc, env;
	env = EnvGen.kr(Env.asr(att,1,rls),gate,doneAction:2);
	modOsc = SinOsc.kr(spd,0,rng,1);
	sig = RLPF.ar(LFSaw.ar(freq*modOsc, amp), ffrq, rq, amp);
	Out.ar(0,Pan2.ar(sig*env,pan))
}).add;
)
(
~filterfreak=[400, 600, 500, 800, 300, 250, 200];
Pdef(\c,
	Pbind(
		\instrument,\monky,
    	\ffrq,Pseq(~filterfreak++~filterfreak.reverse,inf),
		\freq, 60,
		\rq,0.2,
		\att, 0.1,
		\dur,Pseq([1,0.5,1.25,0.75,1.5],inf),
		\legato, 0.9,
		\amp,0.3
	)
);
)
---
(
Ndef(\fltSaw,{ arg freq=100,ffrq=300, spd=1.0, rng=0, rq=0.2,amp=0.5;
	var modOsc = SinOsc.kr(spd,0,rng,1);
	RLPF.ar(Saw.ar(freq*modOsc, amp),ffrq,rq,amp)
});
)
Ndef(\fltSaw).gui
(
SynthDef(\fltSaw,{ arg freq=100,ffrq=300,spd=6.19,rng=0.01,rq=0.3,amp=1,pan=0,dur=1,att=0.1,rls=0.25,gate=1;
	    var sig, modOsc,env;
	    env = EnvGen.kr(Env.asr(att,1,rls),gate,doneAction:2);
	    modOsc = SinOsc.kr(spd,0,rng,1);
	    sig = RLPF.ar(Saw.ar(freq*modOsc, amp), ffrq, rq, amp);
	    Out.ar(0,Pan2.ar(sig*env,pan))
        }
).add;
)
Synth(\fltSaw);
(
~freqRise=[300,600,900,1200,1500,1800,2100,2400];
Pdef(\d,
	Pbind(\instrument,\fltSaw,
		\ffrq,Pstutter(6,Pseq(~freqRise++~freqRise.reverse,inf)),
		\degree,Pseq([0,12,5,8],inf),
		\octave,3,
		\scale,Scale.hijaz,
		\att,0.01,
		\rls,0.3,
		\dur,0.25,
		\amp, 0.2
	)
);
)
---

Pdef.clear

---
Pdef(\a).play;
Pdef(\a).stop;

Pdef(\b).play;
Pdef(\b).stop;

Pdef(\c).play;
Pdef(\c).stop;

Pdef(\d).play
Pdef(\d).stop
