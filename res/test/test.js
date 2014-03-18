var x = 0.0;
var y = 0.0;

var a = 1.4;
var b = -1.7;
var c = 1.7;
var d = 0.9;

var reset = false;

function animate(){
	var canvas = document.getElementById("can");
	var context = canvas.getContext("2d");

	if(reset){
		a = document.getElementById('inputa').value;
		b = document.getElementById('inputb').value;
		c = document.getElementById('inputc').value;
		d = document.getElementById('inputd').value;
		x = y = 0.0;

		context.fillStyle = "rgb(255,255,255)";
		context.fillRect (0, 0, 600, 600);

		reset = false;
	}

	context.fillStyle = "rgb(0,0,0)";
	for(var i = 0; i < 100; i++){ 
		context.fillRect (300+x*100, 300+y*100, 1, 1);
			
		var tmpX = Math.sin(a*y) + c*Math.cos(a*x);
		var tmpY = Math.sin(b*x) + d*Math.cos(b*y);

		x = tmpX;
		y = tmpY;
	}

	setTimeout("animate();",10); 
}

function set(){
	reset = true;
}

animate()
