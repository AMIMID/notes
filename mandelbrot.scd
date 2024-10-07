////mandelbrot set, z=0
(
var z=Complex(0,0),c=Complex(0.1,0.1);

20.do{
	z=(z.pow(2)+c);
	z.round(0.000000000000001).postln;
}


)


(
{
var z=Complex(0,0),c=Complex(0.1,0.1);

500.do{
	z=(z.pow(2)+c);
		Out.ar(0,SinOsc.ar(2500*z.round(0.000000001).real,mul:z.round(0.000000001).real.reciprocal)*0.0001);
		Out.ar(1,SinOsc.ar(2500*z.round(0.000000001).imag,phase:90.degrad,mul:z.round(0.000000001).imag.reciprocal)*0.0001);
}
}.play
)


//////////julia set with golen ratio array
(

var z1,z2,c=Complex(0.1,0.1),angle1=0,angle2=90,rea2,imag2,rea1,imag1;

~z = 100.collect{
	rea1=exp(Complex(0,1)*angle1.degrad).real;
	imag1=exp(Complex(0,1)*angle1.degrad).imag;
	angle1=(angle1+(360-(360/1.6180339887499))).wrap(0,360);
	z1=Complex(rea1,imag1);
};

~c = 100.collect{
 	rea2=exp(Complex(0,1)*angle2.degrad).real;
	imag2=exp(Complex(0,1)*angle2.degrad).imag;
 	angle2=(angle2+(360-(360/1.6180339887499))).wrap(0,360);
 	z2=Complex(rea2,imag2);
 };

 	z=(~z.pow(2)+~c);
 	z.imag.round(0.000001);

)


