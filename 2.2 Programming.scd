
/*  Syntax for SuperCollider as a Programming Language

SuperCollider is an object-oriented language based on Smalltalk.
It has standard facilities of computer languages outlined here.

Comments:

//this is a comment
/* this is also a comment */

Brackets:

We usually group related bits of code together with parentheses, which allows selecting the entire code by double-clicking on one of the parentheses
*/

(
//my patch goes in here
)

// but we also use brackets for other reasons

(  )  // parentheses for grouping expressions together, or for passing arguments to methods, ie

SinOsc.ar(440,0,0.1)

{  }  //function, like:
{arg a; a*a}

[  ]  //array (list of data), like:
[1,2,3,4]

/* Nested expressions - double-click to select within brackets to reveal the scope (level of nesting) of code fragments.  The IDE text editor automatically creates correct indentation when you hit Return while typing your code.  Try double clicking around any of the brackets to show selections in the following code:
*/

(
//first block of code
	(
		//first nested block starts
		(
			//second nested block
		)
	)
)

/* Variables and Assignment - In programming, we need to store our data somewhere, even if it's just data telling us the initial conditions for our calculations. Variables can have arbitrary or meaningful names, but always begin with a lower-case letter
*/

(
var a,b,c;			//variables must be defined first in a block of code

a=1;				//assign some values to our variables
b=a;
c= b*5;

[a,b,c].postln;

a=4;				//assign some new values to our variables
b=a+9;
c= c*5;			//this is OK because c has a value already by now

[a,b,c].postln;
)

// This is fine:
(
var dave;
dave= 5;
dave.postln;
)

//This is wrong and SuperCollider will complain, because 'dave' has not been declared as a variable
(
dave=5;
dave.postln;
)

/*  However, as a convenience for fast, interactive coding, SuperCollider automatically recognizes lower-case letters a-z as 'global variables'.(One of these is set automatically at startup:  s = Server.local).  So entering each line at a time of the following is ok:
*/

a = \dogs	// a single slash in front of a word creates a Symbol
"People love ".post; a.postln;  // 'a ' represents 'dogs', even outside of the scope of a program

/* Yet another feature is that we can place a ~ in front of any word, and it becomes an 'environment variable', which can also be used between different compilations and without being declared, but that is associated with an Environment, by default the 'currentEnvironment';  by changing Environments you can save different sets of values for the same variables. */

~dog = \poodle; // Until reassigned, or until the Environment changes, ~dog represents 'poodle'

"Take your ".post; ~dog.post; " for a walk...".postln;

/*
The currentEnvironment is in effect a special collection which can be used as a big storage space for name tagged data - see the [Environment] help file. */

currentEnvironment; //run this line to see contents of the current state of the currentEnvironment

// You use the currentEnvironment via the ~ sign

~myvar= 0.9;

// The ~ and = is a shortcut here for

currentEnvironment.put(\myvar, 0.9);

// You can access the variable wherever you need it by

~myvar

// Which is the same as

currentEnvironment.at(\myvar);

// Another standard facility of programming languages is the ability to define your own functions, a process called "encapsulation".

(
var myfunction;
myfunction= {arg a; a*a};		//define my own squaring function
myfunction.value(8).postln; 	//'value' executes my function with the argument (8) given
)

// The advantage is that this function can be used again without repeating similar code all over the place.  Efficiency matters - Compare these two blocks of code that do the same thing.  (Don't worry about how the Array construction works for now)

(
var scale, current; 		//code for making a random scale

current=60;
//construct for making an Array to a recipe
scale= Array.fill(8, {var old; old=current;
	current=current+rrand(1,3);  old});
scale.postln;

current=60;
scale= Array.fill(8, {var old; old=current;
	current=current+rrand(1,3);  old});
scale.postln;

current=60;
scale= Array.fill(8, {var old; old=current;
	current=current+rrand(1,3);  old});
scale.postln;
)

(
var makescale;

makescale= {var current;
	current=60;
	Array.fill(8, {var old; old=current;
		current=current+rrand(1,3);  old });
};

3.do({makescale.value.postln;});
)

[Function]	//select the text within brackets then press cmd+D to learn more about Functions

// Looping - computers do tasks very rapidly over and over because  of looping.

(
20.do({"over and over".postln;})  //the function here is the thing to call each time round the loop
)

// a conditional 'while' loop
(
var n=0;  // you declare a variable and assign it a value in the same line
while({n<5}, {n=n+1; "keep going".postln;})
)

//  'for' and 'forBy' loops are used to input evenly changing values to a repeated function
(
for(1, 5, {arg i;  i.postln; });	//start at 1, step by 1 each time until you reach 5
)

(
forBy(1, 5, 2, {arg i;  i.postln; });	//start at 1, step by 2 each time until you reach 5
)
/*
// Be careful that you don't create an infinite loop, which can freeze the computer!!


Conditional Execution means to control program branching based on some logical condition. An 'if' statement is used like this:  */

if (logical test which returns true or false,  do this if true,  do this if false)

(
var a,b;
a=5;
b= if(a==6, 11, 7);  // double-equals == is a test operator that returns a Boolean (true or false) value
b.postln;
)

// or, using functions to do things
(
var a;
a=[6,7,8].choose.postln;  // randomly choose one item from the array
if(a==6,{"it's 6 ".postln },{"BEEP, since not 6, it's 7".postln });
)

// The control flow in SuperCollider is straight down the page:

(
"me first!".postln;
"now me!".postln;
"don't forget me!".postln;
)

(
"me first!".postln;
"now me!".postln;
//  flip a coin -- 50% chance of true or false outcome, if true then execute first funtion, if false execute the second one
if(0.5.coin, {"don't forget me!".postln;},{"you forgot me!".postln});
)

Control Structures		//search for Control Structures in the Help Browser -- especially useful is 'switch', which controls branching based on matching from a list of values or symbols


/*
INTRODUCTION TO 'CLASSES'

In SuperCollider you have the possibility of writing your own functions as classes within the language. This means they are always available to you in your code. Such writing of classes is really helpful once you get to the stage of otherwise having very big long confusing files. You can break up your code into many files using classes.

Classes are also a good conceptual tool for encapsulating functions and the data that function works with. This is part of good object oriented programming.

Some syntactical principles are:

1) Every word that begins with a capital letter is a class name.
2) A dot following a class or object is a method of that class or object.  Methods are functions that classes, or instances of classes know how to do.
*/

LFSaw.ar	//ar is the method

/*
Select the method and type Cmd+i to see any classes which respond to that method.
You can see derived classes of a superclass by using the .dumpClassSubtree method */

UGen.dumpClassSubtree

//Everything derives from the Object class, so do

Object.dumpClassSubtree  // to see the whole hierachy

/*
You can add your own extensions to SuperCollider by writing your own classes.
Classes are like molds from which replicas can be created -- for example, the SinOsc Class defines the behavior of different sine wave oscillators made from it.
Methods are predefined functions that the class and its instances can do.
Your code defines the class that they inherit their behaviors from, defaulting to Object.  Classes usually have class variables, declared as */

classVar mydata;

/*
which are associations of data to names for the class.
Instances have instance variables, declared as */

var data1, data2;

// which are associations of names with data for each new object, or instance, made from that class.

// Classes are saved as .sc files in the SCClassLibrary folder:

"/Applications/SuperCollider/SuperCollider.app/Contents/Resources/SCClassLibrary/"

// or in a user extensions folder

"/Users/yourname/Library/Application Support/Supercollider/Extensions/"

// After writing one, and storing it in the above location,  you recompile the class library using shift-Cmd+L.  If there are syntax errors in your code, the library won't compile, but you'll see error messages that can help you identify the problem.


// ARRAYS

//SuperCollider has lots of classes for collecting things, which provide plenty of specialized methods for manipulating data in lists, but for simple tasks you can often just define arrays of data within square brackets:

a= [5,6,7,8,9,10];

//To be more explicit about building a list of data,  write your own functions to generate data:


a= Array.fill(6, {arg i;  i+5});  // each time the function runs, i is incremented by 1

// Here are some different ways of making Arrays:

Array.series(10,1,1) //arguments to series are number of elements, start element, and add

(1..10) //this is a shortcut for the same thing

Array.series(10,1,2)

(1,3..20) //again a shortcut

Array.geom(10, 1, 1.1); //geometric rather than arithmetic series, with arguments: number of elements, start element, grow ratio

Array.rand(10, 0.7,2.4).sort; //make 10 random numbers drawn from a linear distribution between 0.7 and 2.4, then sort them from small to large

//Some different ways of manipulating arrays: just try each line out in turn and see what gets posted to the post window!

a = [1,3,5,6];

a+5

a*8

a**2 //take to power of 2

a.squared //same thing

a.sqrt

a.scramble //run me multiple times!

a.rotate(1)

a.rotate(-1)

a-10

(a-10).abs

a>4

a.reverse


// Indexing elements in arrays

b=[2,3,4,7]

b.at(3) //get the element at index 3 (meaning the fourth element)

b.at(4) //won't return anything because the array isn't big enough. 'nil' is a placeholder for 'no response possible' and can cause errors if not anticipated in your code!

b.put(2,50) //put 50 into the slot at index 2 (replace third element)

b //note that b itself has been changed

b.put(14,90) //crash- won't work, no space to put the 90 in, array only has four element slots

// You can also use Java array notation

b[0] //get first element

b[0]= 74 //set first element

b //was changed


// Browse the help files of some other classes for storing and manipulating lists:

[Collection]  // the root class for all the rest!
[SequenceableCollection]  // root of all integer indexable classes
[ArrayedCollection]  // as above, but with fixed maximum size
[Array]
[List]

// You will occasionally see

#[1,2,3] //makes a totally fixed (non-dynamic) Array and is slightly more efficient, especially where you're not going to change the Array once you make it

// rather than

[1,2,3] 	//a dynamic array

/* More about Mix and Arrays

Let's now use an Array with fill to prepare a UGen network -  the first case uses the automatic channel expansion method we saw already, while in the second the multiple voices are mixed to mono. Try expanding the number of oscillators radically (100 or more?), but realize that as the oscillators add up you will need to reduce the volume on each in order to prevent overload clipping that happens when the total amplitude exceeds the system limit of +-1.0 the number of voices.

First, startup the server, and scope:
*/

(
s.boot;
Server.local.scope;  // create a Stethoscope to view audio busses on the default Server
)

//you'll only hear the first two of four frequencies if you have just a stereo output, but you can see the last two playing on adjacent busses
(
{
var freqs,array;
freqs= [440,443,447,455.7];
array=Array.fill(4,			//4 elements will go into this array
	{arg i;			//this function is the recipe to make each element
		SinOsc.ar(freqs.at(i), 0, 0.1)
});
array
}.play
)

(	//We can use Mix to make this one channel
{
var freqs,array;
freqs= [440,443,447,455.7];
array=Array.fill(4,			//4 elements will go into this array
	{arg i;			//this function is the recipe to make each element
		SinOsc.ar(freqs.at(i), 0, 0.1)
	});
	Mix(array)
}.play
)

(	// or here's another stereo  variation
{
var freqs,array;
freqs= [440,443,447,455.7];
array=Array.fill(4,			//4 elements will go into this array
	{arg i;			//this function is the recipe to make each element
		SinOsc.ar(freqs.at(i), 0, 0.1)
	});
	[Mix(array[1,2]),Mix(array[3,4])]
}.play
)


// here's one of the examples from Chap. 1 of the SuperCollider book that is a variation on the theme:
(
play({          // alternative notation to {   }.play
	var sines = 100, speed = 6;
	Mix.fill(sines,   // create an array of this number of sines
		{arg x;    // this is a counter, starts as 0 and increments by 1 each time the function executes
			Pan2.ar(
				SinOsc.ar(x+1*100,
					mul: max(0,  // 'max' selects the largest of its two arguments
						LFNoise1.kr(speed) +
						Line.kr(1, -1, 30)
					)
				), rand2(1.0))})/sines})

)












