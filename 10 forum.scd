s.options.numWireBufs = 1024;

s.options.device_("USB Sound Device");
s.options.numOutputBusChannels=16;
TempoClock.default.tempo_(120/60);
s.options.memSize = 8192*8;
s.options.sampleRate = 44100;
s.options.numBuffers = 1024*1;
s.options.numRGens=64*1;
s.options.numWireBufs=64*1;
s.options.numInputBusChannels=0;
s.options.outputStreamsEnabled.postln
s.record(numChannels:6) ;


(
SynthDef.new(\id1, { arg dur = 1, interval = 1, pr, y = 1;

	var aToW = NamedControl.kr(\aToW, 0 ! 23);
	var wx8 = NamedControl.kr(\w, 0 ! 8);
	var panx8 = NamedControl.kr(\pan, 0 ! 8);

	var sig1, sig2, sig3, sig4, x = 0, amp = 1, fund = (1026 * 8);
	var enva, envb, envd1, envd2, envf;
	var under = 1, over = 1, attack = 0.01;
	var an = 0, pan = an.wrap(0, 360);
	var xc = 0, yc = 0, zc = 0;
	var aToWNeg = aToW.neg;

	// you have amp1, so you don't need to recalculate twice
	var amp1 = 2.pow(interval/12);
	var i = fund * amp1, ii = fund / amp1;

	// "x1 x2 x3" etc. means: use arrays!
	// var aud1, aud2, aud3, aud4, aud5, aud6, aud7, aud8;
	// var env1, env2, env3, env4, env5, env6, env7, env8;
	var aud;
	var env;

	var sph;

	var decay = 8*((sqrt(5)+1)/2), el1 = 1, el2 = 1;
	var pos_over = 0, pos_under = 1;
	var s1, s2, s3, s4, ww;

	var trig = Impulse.ar(0);

	envd1 = EnvGen.ar(Env.sine((decay), amp/amp1), doneAction: 2);
	envd2 = EnvGen.ar(Env.sine((decay), amp*amp1), doneAction: 2);
	//envd1 = EnvGen.ar(Env.perc(attack,(decay), amp/amp1), doneAction: 2);
	//envd2 = EnvGen.ar(Env.perc(attack,(decay), amp*amp1), doneAction: 2);
	// repeated structures can be simplified

	env = wx8.collect { |w|
		EnvGen.ar(Env.perc(attack, decay, w), doneAction: 2)
	};

	23.do {
		enva = EnvGen.ar(Env.perc(attack,decay, amp/under, [-4, -4]), trig);
		envb = EnvGen.ar(Env.perc(attack,decay, amp/over, [-4, -4]), trig);

		envf = EnvGen.ar(Env(
			// aToW.collect(_.rand2),  // actually this isn't doing what you think
			aToW.collect { |letter, i|
				Rand(aToWNeg[i], letter)
			},
			Array.fill(aToW.size - 1, { decay.rand }),
			[-4]
		), trig);

		s1 = Pan2.ar(BPF.ar(BrownNoise.ar(mul: enva), (i*under+envf), 0.003), pos: pos_under);
		s2 = Pan2.ar(BPF.ar(BrownNoise.ar(mul: enva), (i*under+envf), 0.003), pos: pos_under.neg);
		s3 = Pan2.ar(BPF.ar(BrownNoise.ar(mul: envb), (ii*over+envf), 0.003), pos: pos_over);
		s4 = Pan2.ar(BPF.ar(BrownNoise.ar(mul: envb), (ii*over+envf), 0.003), pos: pos_over.neg);

		x = x+1;
		over = (x+1)/1;
		under = 1/(x+1);
		pos_over = over.linlin(2/1, 24/1, 1/2, 1).postln;
		pos_under = under.wrap(1, 0);

		Out.ar(0, s1*envd1*pr);
		Out.ar(0, s2*envd1*pr);
		Out.ar(0, s3*envd2*pr);
		Out.ar(0, s4*envd2*pr);

		aud.do { |channel| Out.ar(0, channel) };

		// 1.wait;  instead, delay the trigger
		trig = TDelay.ar(trig, 0.99.rand);
	};
}).add;
)



(
var aPattern = Pexprand(1, 40, inf);

Pdef(\1, Pbind(\instrument, \id1,
	\dur, Pexprand(4, 8, inf),

	// all 23 will make separate streams
	// but there's a subtle thing about array args
	// in events (the 'collect')
	\aToW, Ptuple(Array.fill(23, aPattern))
	.collect { |array| [array] },

	\interval, Pxrand( [12,16,19,24,28,31,36,40,43,48,52,55,60,64,67,72,76,79,84], inf),
	\pr, Pexprand(0.1, 0.2, inf),

)).play(quant:1)
)

Pdef(\1).stop