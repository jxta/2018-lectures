var roxik = (function() {

var polySize = 1.3, polyCenter = 1 / 3;
var canvas, ctx, loading, logo, linkbtn, fpstxt, fpsN, mcursor, evGetter;
var stageW, stageH, stageCx, stageCy;
var cam, camx, camy, camz;
var oldTime, startTime,  totalFrame;
var mdl, models, isOpeningFinish;
var loadImgs, zindex;
var mouseX, mouseXo, mouseY, mouseYo, mouseX2, mouseY2;
var isMouseDown, isDrag, taptype = -1;
var isMouse, isPC, isSafari, isIE, isCanvasRender,  isCanvasFace;

var addListener = function( e, str, func ) {
	if( e.addEventListener ) {
		e.addEventListener( str, func, false );
	}else if( e.attachEvent ) {
		e.attachEvent( "on" + str, func );
	}else {
		
	}
};
addListener( window, "load", init );

//init
function init() {
	var chk = true;
	var ua = navigator.userAgent.toUpperCase();
	isIE = ua.indexOf( "MSIE" ) > -1;
	isMouse = !( "ontouchstart" in window );
	isCanvasFace = false;
	
	if ( ua.indexOf( "ANDROID" )  > -1 || ua.indexOf( "IPHONE" ) > -1 || ua.indexOf( "IPAD" ) > -1 || ua.indexOf( "IPOD" )  > -1 ) {
		isPC = false;
	}else {
		isPC = true;
	}
	if ( ua.indexOf( "SAFARI" ) > -1 && ua.indexOf( "CHROME" ) == -1 && ua.indexOf( "ANDROID" )  == -1 ) {
		isSafari = true;
		isCanvasRender = false;
		var idx0 = ua.indexOf( "VERSION" ) + 8;
		var idx1 = ua.indexOf( " ", idx0 );
		var versions = (ua.substring( idx0, idx1)).split(".");
		var version = versions[0];
		if ( versions.length > 1 ) version += "." + versions[1] + ( versions.length > 2 ? versions[2] : "" );
		version = Number( version );
		if ( Number( version ) > 5.1 ) {
			isCanvasFace = true;
		}
	}else {
		isCanvasRender = true;
		isSafari = false;
	}
	
	if ( isCanvasRender ) {
		canvas = document.createElement("canvas");
		if ( !canvas || !canvas.getContext ) {
			chk = false;
		}
	}
	
	if ( !chk ) {
		var el = document.getElementById("message"); 
		el.style.display = "block";
		return;
	}else {
		setTimeout( init2 , 100 );
	}
}

function init2() {	
	zindex = 150;
	cam = new Camera( isPC );
	
	cursorDots = [];
	var dotSize = 6;
	var cvs = document.createElement( "canvas" );
	cvs.width = dotSize;
	cvs.height = dotSize;
	var ct = cvs.getContext( "2d" );
	ct.strokeStyle = "#FFF";
	ct.lineWidth = 2;
	ct.beginPath();
	dotSize *= 0.5;
	ct.arc( dotSize, dotSize, dotSize - 1, 0, Math.PI * 2, true );
	ct.closePath();
	ct.stroke();
	var dotSrc = cvs.toDataURL();
	for ( var i = 0; i < 5; ++i ) {
		var dot = new Image();
		cursorDots[i] = dot;
		document.body.appendChild( dot );
		dot.src = dotSrc;
		dot.style.position = "absolute";
		dot.style.visibility = "hidden";
		dot.style.zIndex = ++zindex;
	}
	
	mcursor = new mouseCursor();
	
	if( isCanvasRender ){
		ctx = canvas.getContext("2d");
		document.body.appendChild( canvas ); 
		canvas.style.position = "absolute";
	}else{
		evGetter = document.createElement("div");
		document.body.appendChild( evGetter );
		evGetter.style.position = "absolute";
		evGetter.style.zIndex = ++zindex
	}
	
	loading = document.createElement("div");
	loading.innerHTML = "LOADING";
	loading.style.width = "100%";
	loading.style.height = "15px";
	document.body.appendChild( loading );
	loading.style.textAlign = "center";
	loading.style.position = "absolute";
	loading.style.fontSize = "7pt";
	loading.style.letterSpacing = "1px";
	loading.style.zIndex = ++zindex
	loading.style.fontWeight = "bold";
	loading.style.color = "#999";
	
	fpstxt = document.createElement("div");
	fpstxt.innerHTML = "FPS average:";
	fpstxt.style.width = "70px";
	fpstxt.style.height = "15px";
	document.body.appendChild( fpstxt ); 
	fpstxt.style.position = "absolute";
	fpstxt.style.fontSize = "8pt";
	fpstxt.style.zIndex = ++zindex
	fpstxt.style.fontWeight = "bold";
	fpstxt.style.overflow = "hidden";
	
	fpsN = document.createElement("div");
	fpsN.innerHTML = "00.0";
	fpsN.style.width = "26px";
	fpsN.style.height = "12px";
	document.body.appendChild( fpsN ); 
	fpsN.style.position = "absolute";
	fpsN.style.fontSize = "8pt";
	fpsN.style.zIndex = ++zindex
	fpsN.style.fontWeight = "bold";
	fpsN.style.overflow = "hidden";
	fpstxt.style.color = fpsN.style.color = "#777";
	
	linkbtn = document.createElement("a");
	document.body.appendChild( linkbtn ); 
	linkbtn.href = "source.zip";
	linkbtn.innerHTML = "Download - source(zip)";
	linkbtn.style.position = "absolute";
	linkbtn.style.fontSize = ( isPC ? 8 : 7 ) + "pt";
	linkbtn.style.zIndex = ++zindex
	linkbtn.style.fontWeight = "bold";
	linkbtn.normalColor = "#C30";
	linkbtn.overColor = "#F86";
	setBtnEvent( linkbtn );
	
	logo = document.createElement("a");
	logo.href = "http://roxik.com";
	document.body.appendChild( logo ); 
	logo.style.position = "absolute";
	logo.style.zIndex = ++zindex
	logo.innerHTML = "ROXIK";
	logo.style.fontSize = "16pt";
	logo.style.letterSpacing = "2px";
	logo.style.fontWeight = "bold";
	logo.normalColor = "#FFF";
	logo.overColor = "#999";
	setBtnEvent( logo );
	
	zindex = 0;
	loadImgs = 0;
	models = [ monalisa(), nimaime() ];
	mdl = models[0];
	
	mouseX = mouseXo = mouseY = mouseYo = mouseX2 = mouseY2 = 0;
	addListener( window, "resize", resize );
	resize();
	eventSet();
}

function setBtnEvent( bt ) {
	bt.style.color = bt.normalColor;
	if( isMouse ){
		bt.addEventListener( "mouseover", function() { bt.style.color = bt.overColor; } , false );
		bt.addEventListener( "mouseout", function() { bt.style.color = bt.normalColor; } , false );
	}
}

function loadImgCount() {
	if ( ++loadImgs == 2 ) { setTimeout( start , 200 ); }
}

function start() {
	document.body.removeChild( loading );
	mdl.opening();
	var FPS = 30;
	var interval = 1000 / FPS >> 0;
	totalFrame = 0;
	var timer = setInterval( update, interval );
}

//---

function update() {
	if ( mdl.isChange ) {
		mdl.isChange = false;
		mdl.show( false );
		mdl = ( mdl == models[0] ) ? models[1] : models[0];
		mdl.show( true );
	}
	if( isCanvasRender ){
		ctx.clearRect( 0, 0, canvas.width, canvas.height );
	}
	
	cam.update();
	mdl.update();
	mcursor.update();
	cursorDotUpdate();
	
	if ( ++totalFrame > 15 && totalFrame % 5 == 0 ) {
		var now = new Date().getTime();
		var aveFps = 1000 / (( now - startTime ) / ( totalFrame - 15 ));
		fpsN.innerHTML = aveFps.toFixed(1);
	}else if( totalFrame == 15 ){
		oldTime = new Date().getTime();
		startTime = oldTime;
	}
}

//Cursor
function mouseCursor() {
	var cvs = document.createElement( "canvas" );
	var ct = cvs.getContext( "2d" );
	cvs.width = 10;
	cvs.height = 17;
	ct.fillStyle = "#000";
	ct.strokeStyle = "#FFF";
	ct.lineWidth = 2;
	ct.beginPath();
	ct.moveTo( 2,2 );
	ct.lineTo( 2,12 );
	ct.lineTo( 4,10 );
	ct.lineTo( 7,16 );
	ct.lineTo( 9,15 );
	ct.lineTo( 6,9 );
	ct.lineTo( 9,9 );
	ct.closePath();
	ct.stroke();
	ct.fill();
	var img = new Image();
	document.body.appendChild( img );
	img.src = cvs.toDataURL();
	img.style.position = "absolute";
	img.style.visibility = "hidden";
	img.style.zIndex = ++zindex;
	this.mybody = img;
	this.dx = 0;
	this.dy = 0;
	this.gx = 0;
	this.gy = 0;
	this.s = 0;
	this.gper = 0;
	this.count = 130;
	this.update = this.wait;
}

mouseCursor.prototype.wait = function() {
	if ( ++this.count > 190 && !isMouseDown ) {
		this.mybody.style.visibility = "visible";
		this.s = 0;
		this.gper = 1.5;
		this.count = 0;
		this.dx = ( Math.random() > 0.5 ) ? stageW : 0;
		var h = stageH >> 1;
		this.dy = h * Math.random() + h * 0.5;
		this.mybody.style.top = "-20px";
		var l = Math.min( stageCx, stageCy );
		var r = Math.random() * 1.2 - 0.6;
		if ( this.dx < stageCx ) r += 3.14;
		this.gx = Math.cos( r ) * l + stageCx;
		this.gy = Math.sin( r ) * l + stageCy;
		this.update = this.goFace;
	}
};

mouseCursor.prototype.goFace = function() {
	var v = mdl.centerV;
	var gx = v.sx;
	var gy = v.sy * this.gper;
	if ( this.s < 0.8 ) this.s += 0.016;
	this.gper += ( 1 - this.gper ) * this.s;
	var ddx = gx - this.dx;
	var ddy = gy - this.dy;
	this.dx += ddx * this.s;
	this.dy += ddy * this.s;
	this.mybody.style.left = this.dx.toFixed(0) + "px";
	this.mybody.style.top = this.dy.toFixed(0) + "px";
	if ( Math.abs( ddx ) < 10 && Math.abs( ddx ) < 10 && ++this.count > 5 ) {
		this.count = 0;
		this.s = 0;
		this.update = this.drag;
		isDrag = true;
		showCursorDot( true );
	}
};

mouseCursor.prototype.drag = function() {
	if ( this.s < 0.8 ) this.s += 0.01;
	var ddx = this.gx - this.dx;
	var ddy = this.gy * this.gper - this.dy;
	this.dx += ddx * this.s;
	this.dy += ddy * this.s;
	this.mybody.style.left = this.dx.toFixed(0) + "px";
	this.mybody.style.top = this.dy.toFixed(0) + "px";
	var b = mdl.bones[1];
	b.grx = -( this.dy - stageCy ) / stageCy * 1.4;
	b.gry = -( this.dx - stageCx ) / stageCx * 2.2;
	if ( ++this.count > 25 ) {
		this.killDrag();
	}
};

mouseCursor.prototype.killDrag = function() {
	isDrag = false;
	this.count = 0;
	showCursorDot( false );
	this.mybody.style.visibility = "hidden";
	this.update = this.wait;
};

//Cursor Dots
var cursorDots;
var dotspeed = 0;
function showCursorDot( bool ) {
	for ( var i = 0; i < cursorDots.length; ++i ) { cursorDots[i].style.visibility = bool ? "visible" : "hidden"; }
	if ( bool ) cursorDotUpdate();
};

function cursorDotUpdate() {
	if( isDrag || ( isPC && isMouseDown ) ){
		var len = cursorDots.length;
		var lper = 1 / len;
		var stx = isMouseDown ? mouseX : mcursor.dx;
		var sty = isMouseDown ? mouseY : mcursor.dy;
		var v = mdl.centerV;
		var lx = ( v.sx - stx ) * lper;
		var ly = ( v.sy - sty ) * lper;
		if ( ( dotspeed -= 0.13 ) < -1 ) dotspeed = 0;
		stx += lx * dotspeed;
		sty += ly * dotspeed;
		for ( var i = 0; i < len; ++i ) {
			stx += lx;
			sty += ly;
			var dot = cursorDots[i];
			dot.style.left = stx.toFixed(2) + "px";
			dot.style.top = sty.toFixed(2) + "px";
		}
	}
};

//Event
function eventSet() {
	var evtg = ( isCanvasRender ) ? document : evGetter;
	evtg.addEventListener( ( isMouse ? "mousedown" : "touchstart" ), touchStartHandler, false );
	evtg.addEventListener( ( isMouse ? "mousemove" : "touchmove" ), touchMoveHandler, false );
	evtg.addEventListener( ( isMouse ? "mouseup" : "touchend" ), touchEndHandler, false );
	if( isSafari ) evtg.addEventListener( ( isMouse ? "mouseout" : "touchcancel" ), touchEndHandler, false );
	if ( window.addEventListener ) addListener( window, "DOMMouseScroll", wheelHandler );
	addListener( window, "mousewheel", wheelHandler );
}

var touchStartHandler = function( e ) {
	e.preventDefault();
	
	if ( isOpeningFinish && !isMouseDown ) {
		mcursor.killDrag();
		isMouseDown = true;
		isDrag = true;
		mouseX = e.pageX;
		mouseY = e.pageY;
		if( isPC ){ showCursorDot( true ); }
		touchMoveHandler( e );
	}
};

var touchMoveHandler = function( e ) {
	if ( isMouseDown ) {
		mouseXo = mouseX;
		mouseYo = mouseY;
		if ( isMouse ) {
			taptype = 0;
			if (e) {
				mouseX = e.pageX;
				mouseY = e.pageY;
			}else {
				mouseX = event.x + document.body.scrollLeft;
				mouseY = event.y + document.body.scrollTop;
			}
		}else{
			var ot = taptype;
			if ( ot != 1 ) {
				taptype = ( event.changedTouches.length == 1 ) ? 0 : 1;
				if( taptype != ot ) mdl.faceScale2 = 0;
			}
			var pt = event.changedTouches[0];
			mouseX = pt.pageX;
			mouseY = pt.pageY;
		}
		
		if ( taptype == 0 ) {
			var b = mdl.bones[1];
			b.grx = -( mouseY - stageCy ) / stageCy * 1.4;
			b.gry = -( mouseX - stageCx ) / stageCx * 2.2;
			if ( b.grx < -0.8 ) b.grx = -0.8;
			else if ( b.grx > 0.8 ) b.grx = 0.8;
			if ( b.gry < -1.3 ) b.gry = -1.3;
			else if ( b.gry > 1.3 ) b.gry = 1.3;
		}else {
			pt = event.changedTouches[1];
			mouseX2 = pt.pageX;
			mouseY2 = pt.pageY;
			var l0 = mouseX - mouseX2;
			var l1 = mouseY - mouseY2;
			var l = Math.sqrt( l0 * l0 + l1 * l1 );
			var scl = l / ( stageCx + stageCy >> 1 );
			if ( mdl.faceScale2 == 0 ) {
				mdl.faceScale2 = scl;
			}else{
				mdl.faceScale += scl - mdl.faceScale2;
				mdl.faceScale2 = scl;
			}
		}
	}
}

var touchEndHandler = function( e ) {
	if( isMouseDown ){
		isMouseDown = false;
		isDrag = false;
		taptype = -1;
		showCursorDot( false );
	}
}

var wheelHandler = function( e ) {
	if( isOpeningFinish ){
		var s = ( e.detail ) ? -e.detail : e.wheelDelta;
		var sp = 0.08;
		mdl.faceScaleS = ( s > 0 ) ? -sp : sp;
	}
};

function resize() {
	stageW = window.innerWidth;
	stageH = window.innerHeight;
	stageCx = stageW >> 1;
	stageCy = stageH >> 1;
	if ( isCanvasRender ) {
		if( canvas ){
			canvas.width = stageW;
			canvas.height = stageH;
		}
	}else {
		if( evGetter ){
			evGetter.style.width = stageW + "px";
			evGetter.style.height = stageH + "px";
		}
	}
	cam.resize( isPC );
	
	var logoPos = Math.min( stageW, stageH ) * 0.02 + 6 >> 0;
	logo.style.top = logoPos + "px";
	logo.style.left = logoPos + "px";
	linkbtn.style.top = logoPos + 29 + "px";
	linkbtn.style.left = logoPos + "px";
	fpstxt.style.top = fpsN.style.top = logoPos + 43 + "px";
	fpstxt.style.left = logoPos + 1 + "px";
	fpsN.style.left = logoPos + 70 + "px";
	
	if ( loading ) { loading.style.top = stageCy - 8 + "px"; }
};

//---

function monalisa() {
	var mat_Default = {};
	var verticesrc = [[786,960,0],[79,960,0],[-530,960,0],[353,655,-229],[-15,705,-322],[-182,630,-285],[446,370,-247],[210,353,-352],[131,392,-370],[131,315,-370],[-115,379,-370],[-200,346,-352],[-36,340,-381],[-123,304,-370],[37,342,-381],[-308,290,-256],[-173,-10,-217],[-110,140,-387],[-90,66,-381],[-30,111,-421],[95,71,-375],[-38,160,-479],[80,145,-387],[786,-82,0],[309,-60,-261],[-5,-190,-289],[-41,-74,-387],[57,-74,-387],[-530,-174,0],[786,-1015,0],[-530,-1015,0],[-43,67,-419],[15,63,-419],[-43,54,-419],[15,54,-419]];
	var polysrc = [[4,2,1],[10,9,8],[10,15,9],[23,15,10],[23,22,15],[21,20,23],[33,20,21],[28,35,21],[27,35,28],[27,34,35],[27,19,34],[33,32,20],[32,19,20],[19,18,20],[27,17,19],[19,16,18],[18,16,14],[18,14,13],[14,12,11],[16,12,14],[31,29,17],[17,16,19],[30,25,24],[24,7,1],[29,3,16],[12,6,11],[14,11,13],[26,27,28],[26,17,27],[18,13,22],[22,13,15],[20,18,22],[20,22,23],[8,4,7],[8,9,4],[9,5,4],[11,6,5],[29,16,17],[26,28,25],[11,5,9],[25,23,7],[23,10,8],[23,8,7],[15,11,9],[13,11,15],[6,3,2],[6,2,5],[4,5,2],[28,21,25],[25,21,23],[31,26,30],[31,17,26],[30,26,25],[7,4,1],[24,25,7],[16,6,12],[16,3,6]];
	var matsrc = [{material:mat_Default,vIDs:[1,2,3]},{material:mat_Default,vIDs:[4,5,6]},{material:mat_Default,vIDs:[7,8,9]},{material:mat_Default,vIDs:[10,11,12]},{material:mat_Default,vIDs:[13,14,15]},{material:mat_Default,vIDs:[16,17,18]},{material:mat_Default,vIDs:[19,20,21]},{material:mat_Default,vIDs:[22,23,24]},{material:mat_Default,vIDs:[25,26,27]},{material:mat_Default,vIDs:[28,29,30]},{material:mat_Default,vIDs:[31,32,33]},{material:mat_Default,vIDs:[34,35,36]},{material:mat_Default,vIDs:[37,38,39]},{material:mat_Default,vIDs:[40,41,42]},{material:mat_Default,vIDs:[43,44,45]},{material:mat_Default,vIDs:[46,47,48]},{material:mat_Default,vIDs:[49,50,51]},{material:mat_Default,vIDs:[52,53,54]},{material:mat_Default,vIDs:[55,56,57]},{material:mat_Default,vIDs:[58,59,60]},{material:mat_Default,vIDs:[61,62,63]},{material:mat_Default,vIDs:[64,65,66]},{material:mat_Default,vIDs:[67,68,69]},{material:mat_Default,vIDs:[70,71,72]},{material:mat_Default,vIDs:[73,74,75]},{material:mat_Default,vIDs:[76,77,78]},{material:mat_Default,vIDs:[79,80,81]},{material:mat_Default,vIDs:[82,83,84]},{material:mat_Default,vIDs:[85,86,87]},{material:mat_Default,vIDs:[88,89,90]},{material:mat_Default,vIDs:[91,92,93]},{material:mat_Default,vIDs:[94,95,96]},{material:mat_Default,vIDs:[97,98,99]},{material:mat_Default,vIDs:[100,101,102]},{material:mat_Default,vIDs:[103,104,105]},{material:mat_Default,vIDs:[106,107,108]},{material:mat_Default,vIDs:[109,110,111]},{material:mat_Default,vIDs:[112,113,114]},{material:mat_Default,vIDs:[115,116,117]},{material:mat_Default,vIDs:[118,119,120]},{material:mat_Default,vIDs:[121,122,123]},{material:mat_Default,vIDs:[124,125,126]},{material:mat_Default,vIDs:[127,128,129]},{material:mat_Default,vIDs:[130,131,132]},{material:mat_Default,vIDs:[133,134,135]},{material:mat_Default,vIDs:[136,137,138]},{material:mat_Default,vIDs:[139,140,141]},{material:mat_Default,vIDs:[142,143,144]},{material:mat_Default,vIDs:[145,146,147]},{material:mat_Default,vIDs:[148,149,150]},{material:mat_Default,vIDs:[151,152,153]},{material:mat_Default,vIDs:[154,155,156]},{material:mat_Default,vIDs:[157,158,159]},{material:mat_Default,vIDs:[160,161,162]},{material:mat_Default,vIDs:[163,164,165]},{material:mat_Default,vIDs:[166,167,168]},{material:mat_Default,vIDs:[169,170,171]}];
	var uvsrc = [[0.6711,0.8456],[0.4627,1],[1,1],[0.5022,0.6733],[0.5022,0.7122],[0.5623,0.6928],[0.5022,0.6733],[0.4309,0.6869],[0.5022,0.7122],[0.4637,0.5875],[0.4309,0.6869],[0.5022,0.6733],[0.4637,0.5875],[0.3745,0.595],[0.4309,0.6869],[0.4711,0.5479],[0.3802,0.57],[0.4637,0.5875],[0.4144,0.5479],[0.3802,0.57],[0.4711,0.5479],[0.446,0.4766],[0.4166,0.5374],[0.4711,0.5479],[0.3716,0.4766],[0.4166,0.5374],[0.446,0.4766],[0.3716,0.4766],[0.3723,0.5374],[0.4166,0.5374],[0.3716,0.4766],[0.3376,0.5484],[0.3723,0.5374],[0.4144,0.5479],[0.3703,0.5499],[0.3802,0.57],[0.3703,0.5499],[0.3376,0.5484],[0.3802,0.57],[0.3376,0.5484],[0.3194,0.585],[0.3802,0.57],[0.3716,0.4766],[0.2717,0.5089],[0.3376,0.5484],[0.3376,0.5484],[0.1689,0.6608],[0.3194,0.585],[0.3194,0.585],[0.1689,0.6608],[0.3097,0.6681],[0.3194,0.585],[0.3097,0.6681],[0.3755,0.6862],[0.3097,0.6681],[0.2512,0.6893],[0.3155,0.7061],[0.1689,0.6608],[0.2512,0.6893],[0.3097,0.6681],[0,0],[0,0.4258],[0.2717,0.5089],[0.2717,0.5089],[0.1689,0.6608],[0.3376,0.5484],[1,0],[0.6378,0.4835],[1,0.4726],[1,0.4726],[0.7418,0.7013],[1,1],[0,0.4258],[0,1],[0.1689,0.6608],[0.2512,0.6893],[0.2648,0.8329],[0.3155,0.7061],[0.3097,0.6681],[0.3155,0.7061],[0.3755,0.6862],[0.3992,0.4177],[0.3716,0.4766],[0.446,0.4766],[0.3992,0.4177],[0.2717,0.5089],[0.3716,0.4766],[0.3194,0.585],[0.3755,0.6862],[0.3745,0.595],[0.3745,0.595],[0.3755,0.6862],[0.4309,0.6869],[0.3802,0.57],[0.3194,0.585],[0.3745,0.595],[0.3802,0.57],[0.3745,0.595],[0.4637,0.5875],[0.5623,0.6928],[0.6711,0.8456],[0.7418,0.7013],[0.5623,0.6928],[0.5022,0.7122],[0.6711,0.8456],[0.5022,0.7122],[0.3916,0.8709],[0.6711,0.8456],[0.3155,0.7061],[0.2648,0.8329],[0.3916,0.8709],[0,0.4258],[0.1689,0.6608],[0.2717,0.5089],[0.3992,0.4177],[0.446,0.4766],[0.6378,0.4835],[0.3155,0.7061],[0.3916,0.8709],[0.5022,0.7122],[0.6378,0.4835],[0.4637,0.5875],[0.7418,0.7013],[0.4637,0.5875],[0.5022,0.6733],[0.5623,0.6928],[0.4637,0.5875],[0.5623,0.6928],[0.7418,0.7013],[0.4309,0.6869],[0.3155,0.7061],[0.5022,0.7122],[0.3755,0.6862],[0.3155,0.7061],[0.4309,0.6869],[0.2648,0.8329],[0,1],[0.4627,1],[0.2648,0.8329],[0.4627,1],[0.3916,0.8709],[0.6711,0.8456],[0.3916,0.8709],[0.4627,1],[0.446,0.4766],[0.4711,0.5479],[0.6378,0.4835],[0.6378,0.4835],[0.4711,0.5479],[0.4637,0.5875],[0,0],[0.3992,0.4177],[1,0],[0,0],[0.2717,0.5089],[0.3992,0.4177],[1,0],[0.3992,0.4177],[0.6378,0.4835],[0.7418,0.7013],[0.6711,0.8456],[1,1],[1,0.4726],[0.6378,0.4835],[0.7418,0.7013],[0.1689,0.6608],[0.2648,0.8329],[0.2512,0.6893],[0.1689,0.6608],[0,1],[0.2648,0.8329]];
	if( isCanvasRender ){
		for (var i = 0; i < uvsrc.length; ++i ) {
			if ( uvsrc[i][0] == 0.3703 || uvsrc[i][0] == 0.4144 ) { uvsrc[i][1] -= 0.007; }
			else if ( uvsrc[i][0] == 0.3723 || uvsrc[i][0] == 0.4166 ) { uvsrc[i][1] += 0.002; }
		}
	}
	var weightsrc = [
	 {name:"chin",vertices:[17,19,21,25,26,27,28,34,35]},
	 {name:"head",vertices:[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,29,32,33]},
	 {name:"neck",vertices:[1,3,24,25,26,29,30,31]}
	];
	var bonesrc = [
	 ["neck",-1,1,0,-0.85,-0.05,0,0,0,0.27,1,0], //0
	 ["head",0,1,0,0.91,-0.01,0,0,0,0.27,1,0], //1
	 ["chin",1,1,0,0.02,-0.05,0,0,0,0.27,1,0] //2
	];
	for ( var i = 0; i < verticesrc.length; ++i ) { verticesrc[i][0] -= 130; }
	for ( i = 0; i < bonesrc.length; ++i ) { bonesrc[i][3] -= 0.13; }
	return new mesh( 0, "monalisa.jpg", verticesrc, polysrc, weightsrc, matsrc, uvsrc, bonesrc );
}

function nimaime() {
	var mat_Default = {};
	var verticesrc = [[786,960,0],[199,960,0],[-530,960,0],[613,545,-256],[330,590,-306],[676,260,-176],[497,236,-351],[526,236,-351],[617,261,-326],[576,294,-341],[138,410,-286],[424,291,-361],[365,260,-346],[480,75,-385],[471,-13,-384],[471,-16,-384],[557,-13,-384],[557,-10,-384],[533,18,-385],[595,-20,-345],[632,20,-461],[619,26,-355],[576,216,-341],[434,214,-361],[82,55,-271],[786,-82,0],[649,-170,-273],[512,-216,-356],[370,-50,-350],[419,-226,-356],[107,-235,-310],[-530,-174,0],[415,-335,-258],[786,-1010,0],[-530,-1015,0]];
	var polysrc = [[4,2,1],[23,10,9],[23,8,10],[22,8,23],[21,8,22],[20,19,22],[20,18,19],[28,17,20],[30,17,28],[30,16,17],[30,29,16],[15,19,18],[29,19,15],[29,14,19],[30,31,29],[29,25,14],[14,25,24],[14,24,7],[24,13,12],[25,13,24],[35,32,31],[31,25,29],[34,27,26],[26,6,1],[32,3,25],[13,11,12],[24,12,7],[33,30,28],[33,31,30],[21,14,7],[21,7,8],[19,14,21],[19,21,22],[6,9,4],[9,10,4],[10,5,4],[12,11,5],[31,32,25],[33,28,27],[12,5,10],[27,22,6],[22,23,9],[22,9,6],[8,12,10],[7,12,8],[11,3,2],[11,2,5],[4,5,2],[28,20,27],[27,20,22],[35,31,33],[34,33,27],[6,4,1],[27,6,26],[25,11,13],[25,3,11],[35,33,34]];
	var matsrc = [{material:mat_Default,vIDs:[1,2,3]},{material:mat_Default,vIDs:[4,5,6]},{material:mat_Default,vIDs:[7,8,9]},{material:mat_Default,vIDs:[10,11,12]},{material:mat_Default,vIDs:[13,14,15]},{material:mat_Default,vIDs:[16,17,18]},{material:mat_Default,vIDs:[19,20,21]},{material:mat_Default,vIDs:[22,23,24]},{material:mat_Default,vIDs:[25,26,27]},{material:mat_Default,vIDs:[28,29,30]},{material:mat_Default,vIDs:[31,32,33]},{material:mat_Default,vIDs:[34,35,36]},{material:mat_Default,vIDs:[37,38,39]},{material:mat_Default,vIDs:[40,41,42]},{material:mat_Default,vIDs:[43,44,45]},{material:mat_Default,vIDs:[46,47,48]},{material:mat_Default,vIDs:[49,50,51]},{material:mat_Default,vIDs:[52,53,54]},{material:mat_Default,vIDs:[55,56,57]},{material:mat_Default,vIDs:[58,59,60]},{material:mat_Default,vIDs:[61,62,63]},{material:mat_Default,vIDs:[64,65,66]},{material:mat_Default,vIDs:[67,68,69]},{material:mat_Default,vIDs:[70,71,72]},{material:mat_Default,vIDs:[73,74,75]},{material:mat_Default,vIDs:[76,77,78]},{material:mat_Default,vIDs:[79,80,81]},{material:mat_Default,vIDs:[82,83,84]},{material:mat_Default,vIDs:[85,86,87]},{material:mat_Default,vIDs:[88,89,90]},{material:mat_Default,vIDs:[91,92,93]},{material:mat_Default,vIDs:[94,95,96]},{material:mat_Default,vIDs:[97,98,99]},{material:mat_Default,vIDs:[100,101,102]},{material:mat_Default,vIDs:[103,104,105]},{material:mat_Default,vIDs:[106,107,108]},{material:mat_Default,vIDs:[109,110,111]},{material:mat_Default,vIDs:[112,113,114]},{material:mat_Default,vIDs:[115,116,117]},{material:mat_Default,vIDs:[118,119,120]},{material:mat_Default,vIDs:[121,122,123]},{material:mat_Default,vIDs:[124,125,126]},{material:mat_Default,vIDs:[127,128,129]},{material:mat_Default,vIDs:[130,131,132]},{material:mat_Default,vIDs:[133,134,135]},{material:mat_Default,vIDs:[136,137,138]},{material:mat_Default,vIDs:[139,140,141]},{material:mat_Default,vIDs:[142,143,144]},{material:mat_Default,vIDs:[145,146,147]},{material:mat_Default,vIDs:[148,149,150]},{material:mat_Default,vIDs:[151,152,153]},{material:mat_Default,vIDs:[154,155,156]},{material:mat_Default,vIDs:[157,158,159]},{material:mat_Default,vIDs:[160,161,162]},{material:mat_Default,vIDs:[163,164,165]},{material:mat_Default,vIDs:[166,167,168]},{material:mat_Default,vIDs:[169,170,171]}];
	var uvsrc = [[0.8686,0.7899],[0.5538,1],[1,1],[0.8402,0.6234],[0.8402,0.6627],[0.8714,0.6461],[0.8402,0.6234],[0.8024,0.6336],[0.8402,0.6627],[0.8731,0.5271],[0.8024,0.6336],[0.8402,0.6234],[0.8826,0.5241],[0.8024,0.6336],[0.8731,0.5271],[0.8499,0.5058],[0.8078,0.523],[0.8731,0.5271],[0.8499,0.5058],[0.8156,0.5111],[0.8078,0.523],[0.7916,0.4045],[0.8241,0.5031],[0.8499,0.5058],[0.721,0.3994],[0.8241,0.5031],[0.7916,0.4045],[0.721,0.3994],[0.7598,0.5006],[0.8241,0.5031],[0.721,0.3994],[0.686,0.4911],[0.7598,0.5006],[0.7598,0.5066],[0.8078,0.523],[0.8156,0.5111],[0.686,0.4911],[0.8078,0.523],[0.7598,0.5066],[0.686,0.4911],[0.7676,0.5519],[0.8078,0.523],[0.721,0.3994],[0.4844,0.3949],[0.686,0.4911],[0.686,0.4911],[0.4651,0.5418],[0.7676,0.5519],[0.7676,0.5519],[0.4651,0.5418],[0.7328,0.6221],[0.7676,0.5519],[0.7328,0.6221],[0.7804,0.6333],[0.7328,0.6221],[0.6804,0.6456],[0.7249,0.6615],[0.4651,0.5418],[0.6804,0.6456],[0.7328,0.6221],[0,0],[0,0.4258],[0.4844,0.3949],[0.4844,0.3949],[0.4651,0.5418],[0.686,0.4911],[1,0.0028],[0.8961,0.4278],[1,0.4726],[1,0.4726],[0.9165,0.6456],[1,1],[0,0.4258],[0,1],[0.4651,0.5418],[0.6804,0.6456],[0.5079,0.7215],[0.7249,0.6615],[0.7328,0.6221],[0.7249,0.6615],[0.7804,0.6333],[0.7182,0.3443],[0.721,0.3994],[0.7916,0.4045],[0.7182,0.3443],[0.4844,0.3949],[0.721,0.3994],[0.8826,0.5241],[0.7676,0.5519],[0.7804,0.6333],[0.8826,0.5241],[0.7804,0.6333],[0.8024,0.6336],[0.8078,0.523],[0.7676,0.5519],[0.8826,0.5241],[0.8078,0.523],[0.8826,0.5241],[0.8731,0.5271],[0.9165,0.6456],[0.8714,0.6461],[0.8686,0.7899],[0.8714,0.6461],[0.8402,0.6627],[0.8686,0.7899],[0.8402,0.6627],[0.6536,0.8127],[0.8686,0.7899],[0.7249,0.6615],[0.5079,0.7215],[0.6536,0.8127],[0.4844,0.3949],[0,0.4258],[0.4651,0.5418],[0.7182,0.3443],[0.7916,0.4045],[0.8961,0.4278],[0.7249,0.6615],[0.6536,0.8127],[0.8402,0.6627],[0.8961,0.4278],[0.8731,0.5271],[0.9165,0.6456],[0.8731,0.5271],[0.8402,0.6234],[0.8714,0.6461],[0.8731,0.5271],[0.8714,0.6461],[0.9165,0.6456],[0.8024,0.6336],[0.7249,0.6615],[0.8402,0.6627],[0.7804,0.6333],[0.7249,0.6615],[0.8024,0.6336],[0.5079,0.7215],[0,1],[0.5538,1],[0.5079,0.7215],[0.5538,1],[0.6536,0.8127],[0.8686,0.7899],[0.6536,0.8127],[0.5538,1],[0.7916,0.4045],[0.8499,0.5058],[0.8961,0.4278],[0.8961,0.4278],[0.8499,0.5058],[0.8731,0.5271],[0,0],[0.4844,0.3949],[0.7182,0.3443],[1,0.0028],[0.7182,0.3443],[0.8961,0.4278],[0.9165,0.6456],[0.8686,0.7899],[1,1],[0.8961,0.4278],[0.9165,0.6456],[1,0.4726],[0.4651,0.5418],[0.5079,0.7215],[0.6804,0.6456],[0.4651,0.5418],[0,1],[0.5079,0.7215],[0,0],[0.7182,0.3443],[1,0.0028]];
	var weightsrc = [
	 {name:"chin",vertices:[16,17,20,27,28,29,30,31,33]},
	 {name:"head",vertices:[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,18,19,20,21,22,23,24,25,26,29,31,32]},
	 {name:"neck",vertices:[1,3,26,27,32,33,34,35]}
	];
	var bonesrc = [
	 ["neck",-1,1,0,-0.85,-0.05,0,0,0,0.27,1,0], //0
	 ["head",0,1,0.05,0.73,-0.01,0,0,0,0.27,1,0], //1
	 ["chin",1,1,0.45,0.1,-0.05,0,0,0,0.27,1,0] //2
	];
	for ( var i = 0; i < verticesrc.length; ++i ) { verticesrc[i][0] -= 125; }
	for ( i = 0; i < bonesrc.length; ++i ) { bonesrc[i][3] -= 0.125; }
	return new mesh( 1, "nimaime.jpg", verticesrc, polysrc, weightsrc, matsrc, uvsrc, bonesrc );
}

function mesh( n, texurl, verticesrc, polysrc, weightsrc, matsrc, uvsrc, bonesrc ) {
	this.id = n;
	this.vertices = [];
	this.faces = [];
	this.bones = [];
	
	this.eyev = ( this.id == 0 ) ? [ 8, 9, 10, 13 ] : [ 11, 23, 9, 22 ];
	this.blinkT = -70;
	this.blinkS = 0;
	this.blinkSs = 0;
	this.faceScale = 1;
	this.faceScale2 = 1;
	this.faceScaleS = 0;
	this.count = 0;
	this.mopen = true;
	this.isChange = false;
	this.releaseCC = 0;
	
	this.texture = new Image();
	this.texture.src = texurl;
	var me = this;
	this.texture.onload = function() { me.makeBody( verticesrc, polysrc, weightsrc, matsrc, uvsrc, bonesrc ); };
}

mesh.prototype.makeBody = function( verticesrc, polysrc, weightsrc, matsrc, uvsrc, bonesrc ) {
	makeVertices( this.vertices, verticesrc );
	makeFaces( this.faces, this.vertices, polysrc, matsrc, uvsrc, this.texture );
	makeBone( this.bones, bonesrc, weightsrc, this.vertices );
	this.faces.sort( compZ );
	if( !isCanvasRender ){
		for ( var i = 0; i < this.faces.length; ++i ) {
			this.faces[i].faceImg.style.zIndex = ++zindex;
		}
	}
	
	this.centerV = ( this.id == 0 ) ? this.vertices[21] : this.vertices[24];
	loadImgCount();
	
	this.bones[0].rz = 0.01;
	this.animate = this.sing;
};

mesh.prototype.show = function( bool ) {
	this.count = 0;
	this.releaseCC = 0;
	this.starttime = new Date().getTime();
	for ( var i = 0; i < this.faces.length; ++i ) {
		this.faces[i].show( bool );
	}
};

mesh.prototype.update = function() {
	this.animate();
	this.updateBone();
	this.blink();
	this.render();
};

mesh.prototype.opening = function() {
	var bones = this.bones;
	b = bones[1];
	b.by = 0;
	b.scale = 0.5;
	b.ry = b.gry = 0.5;
	b.rz = b.grz = -1.7;
	b.s0 = 0;
	b.s1 = 1;
	b.ryr = 0;
	b.xsa = b.ysa = b.xsa = 0;
	
	b = bones[0];
	b.s0 = 0;
	b.s1 = 1;
	b.ry = b.gry = 1.5;
	b.rz = b.grz = -1.2;
	b.dy = -1800;
	b.scale = 0.5;
	b.xsa = b.ysa = b.xsa = 0;
	
	b = bones[2];
	b.rx = b.ry = 0;
	b.rxr = 0;
	b.ryr = Math.PI * 0.5;
	
	this.count = 0;
	this.animate = this.openingMotion;
};

mesh.prototype.openingMotion = function() {
	var bones = this.bones;
	++this.count;
	var b;
	var faceBone = bones[1];
	
	b = bones[1];
	b.by += ( b.iniby - b.by ) * 0.1;
	if ( this.count > 5 ) {
		b.s0 += 0.0005;
		b.s1 -= 0.0025;
		b.gry += b.ysa = ( 0 - b.gry ) * b.s0 + b.ysa * b.s1;
		b.grz += b.zsa = ( 0 - b.grz ) * b.s0 + b.zsa * b.s1;
		b.scale += ( 1 - b.scale ) * 0.1;
	}
	b.ry += ( b.gry - b.ry ) * 0.8;
	b.rz += ( b.grz - b.rz ) * 0.8;
	
	b = bones[0];
	b.s0 += 0.001;
	b.s1 -= 0.005;
	b.gry += b.ysa = ( 0 - b.gry ) * b.s0 + b.ysa * b.s1;
	b.grz += b.zsa = ( 0 - b.grz ) * b.s0 + b.zsa * b.s1;
	b.ry += ( b.gry - b.ry ) * 0.4;
	b.rz += ( b.grz - b.rz ) * 0.4;
	
	if ( this.count > 10 ) {
		b.dy += ( b.iniy - b.dy ) * 0.1;
	}
	b.scale += ( 1 - b.scale ) * 0.25;
	
	if ( this.count > 60 ) {
		isOpeningFinish = true;
		this.bones[0].s0 = 0;
		this.bones[0].s1 = 0;
		this.bones[1].s0 = 0;
		this.bones[1].s1 = 0;
		this.starttime = new Date().getTime();
		this.count = 0;
		this.animate = this.sing;
	}
};

mesh.prototype.sing = function() {
	var bones = this.bones;
	var b = bones[1];
	var b1 = b;
	if ( isDrag ) {
		b.s0 = 0.07;
		b.s1 = 1;
		this.releaseCC = 0;
	}else {
		if ( b.s0 < 0.7 ) b.s0 += 0.06;
		b.grx += b.xsa = ( 0 - b.grx ) * b.s0 + b.xsa * b.s1;
		b.gry += b.ysa = ( 0 - b.gry ) * b.s0 + b.ysa * b.s1;
		b.s1 *= 0.98;
		++this.releaseCC;
	}
	
	if ( b.vrx < 0.4 ) b.vrx += 0.01;
	b.rx += ( b.grx - b.rx ) * b.vrx;
	b.ry += ( b.gry - b.ry ) * b.vrx;
	b.ry += Math.sin( b.ryr ) * 0.07;
	b.ryr -= 0.09;
	if ( b.vrz < 0.9 ) b.vrz += 0.015;
	b.rz += ( -b.ry * 0.25 + Math.sin( b.rzr ) * 0.17 - b.rz ) * b.vrz;
	b.rzr += 0.13;
	
	this.faceScale += this.faceScaleS;
	this.faceScaleS *= 0.7;
	b.scale += ( this.faceScale - b.scale ) * 0.4;
	if ( this.faceScale < 1 ) this.faceScale += ( 1 - this.faceScale ) * 0.4;
	else if ( this.faceScale > 1.45 ) this.faceScale += ( 1.45 - this.faceScale ) * 0.4;
	
	b = bones[0];
	b.rx += ( b1.rx * 0.15 - b.rx ) * 0.1;
	b.ry += ( b1.ry * 0.15 - b.ry ) * 0.1;
	b.rz += ( b1.rz * -0.25 - b.rz ) * 0.1;
	
	b1 = b = bones[2];
	
	if( this.count > 40 ){
		b.grx = Math.cos( b.rxr ) * 0.12 - 0.12;
		b.rxr += 0.25;
		b.gry = Math.cos( b.ryr ) * 0.1;
		b.ryr += 0.1;
	}else {
		b.grx = 0.03;
		b.gry = 0;
	}
	b.rx += ( b.grx - b.rx ) * 0.3;
	b.ry += ( b.gry - b.ry ) * 0.3;
	
	if ( !this.mopen && b.rx < -0.05 ) {
		this.mopen = true;
	}
	else if ( this.mopen && b.rx > -0.04 ) {
		this.mopen = false;
		if ( this.releaseCC > 10 && new Date().getTime() - this.starttime > 7000 ) {
			this.isChange = true;
		}
		if ( Math.random() > 0.8 ) this.count = 0;
	}
	
	++this.count;
};

mesh.prototype.blink = function() {
	if ( ++this.blinkT > 0 ) {
		this.blinkSs += 0.2;
		this.blinkS += ( 1 - this.blinkS ) * this.blinkSs;
		if ( this.blinkS > 0.98 ) { this.blinkSs = 0;  this.blinkT = Math.random() * -120 - 6; }
	}else {
		this.blinkS += ( 0 - this.blinkS ) * this.blinkSs;
		if( this.blinkSs < 0.8 ) this.blinkSs += 0.15;
	}
	var eyeT = this.vertices[ this.eyev[0] ];
	var eyeB = this.vertices[ this.eyev[1] ];
	var eyeCenterX = eyeT.dx + eyeB.dx >> 1;
	var eyeCenterY = eyeT.dy + eyeB.dy >> 1;
	eyeT.dx += ( eyeCenterX - eyeT.dx ) * this.blinkS;
	eyeT.dy += ( eyeCenterY - eyeT.dy ) * this.blinkS;
	eyeB.dx += ( eyeCenterX - eyeB.dx ) * this.blinkS;
	eyeB.dy += ( eyeCenterY - eyeB.dy ) * this.blinkS;
	eyeT = this.vertices[ this.eyev[2] ];
	eyeB = this.vertices[ this.eyev[3] ];
	eyeCenterX = eyeT.dx + eyeB.dx >> 1;
	eyeCenterY = eyeT.dy + eyeB.dy >> 1;
	eyeT.dx += ( eyeCenterX - eyeT.dx ) * this.blinkS;
	eyeT.dy += ( eyeCenterY - eyeT.dy ) * this.blinkS;
	eyeB.dx += ( eyeCenterX - eyeB.dx ) * this.blinkS;
	eyeB.dy += ( eyeCenterY - eyeB.dy ) * this.blinkS;
};

mesh.prototype.updateBone = function() {
	var bones = this.bones;
	var vertices = this.vertices;
	var len = bones.length;
	bones[0].updateMtx();
	for ( i = 1; i < len; ++i ) {
		bones[i].updateLocalMtx();
	}
	len = vertices.length;
	for ( i = 0; i < len; ++i ) {
		vertices[i].tBone();
	}
};

mesh.prototype.render = function() {
	var vtxs = this.vertices;
	var len =vtxs.length;
	for ( i = 0; i < len; ++i ) {
		vtxs[i].update();
	}
	var faces = this.faces;
	var arr = [];
	var len2 = 0;
	len = faces.length;
	for ( i = 0; i < len; ++i ) {
		v = faces[i];
		if ( v.chkin() ) {
			arr[ len2++ ] = v;
		}
	}
	if( isCanvasRender ){
		arr.sort( compZ );
		for ( i = 0; i < len2; ++i ) { arr[i].renderCvs( ctx ); }
	}else {
		for ( i = 0; i < len2; ++i ) { arr[i].renderImg(); }
	}
};

var compZ = function( a, b ) {	return b.sz - a.sz; };

//Vertex
function makeVertices( res, src ) {
	var len = src.length;
	for ( var i = 0; i < len; ++i ) {
		res[i] = new Vertex( src[i][0], src[i][1], src[i][2] );
	}
}

function Vertex( x, y, z ) {
	this.dx = x; this.dy = y; this.dz = z;
	this.bx = 0; this.by = 0; this.bz = 0;
	this.bx1 = 0; this.by1 = 0; this.bz1 = 0;
	this.sx = 0; this.sy = 0; this.sz = 0;
	this.tBone = null;
	this.boneMtx0 = null;
	this.boneMtx1 = null;
};

Vertex.prototype.addBone = function( b ) {
	with ( this ) {
		if( boneMtx0 == null ){
			boneMtx0 = b.mtx;
			bx = dx - b.dx;
			by = dy - b.dy;
			bz = dz - b.dz;
			tBone = tBone1;
		}else if( boneMtx1 == null ){
			boneMtx1 = b.mtx;
			bx1 = dx - b.dx;
			by1 = dy - b.dy;
			bz1 = dz - b.dz;
			tBone = tBone2;
		}
	}
};

Vertex.prototype.update = function() {
	var ssx = this.dx + camx;
	var ssy = this.dy + camy;
	var ssz = this.dz + camz;
	this.sz = cam.m8 * ssx + cam.m9 * ssy + cam.m10 * ssz;
	if( this.sz < 1 ) this.sz = 1;
	var zs = cam.wscale / this.sz;
	this.sx = stageCx + ( cam.m0 * ssx + cam.m1 * ssy + cam.m2 * ssz ) * zs;
	this.sy = stageCy + ( cam.m4 * ssx + cam.m5 * ssy + cam.m6 * ssz ) * zs;
};

Vertex.prototype.tBone1 = function() {
	var b = this.boneMtx0;
	this.dx = b.m0 * this.bx + b.m1 * this.by + b.m2 * this.bz + b.m3;
	this.dy = b.m4 * this.bx + b.m5 * this.by + b.m6 * this.bz + b.m7;
	this.dz = b.m8 * this.bx + b.m9 * this.by + b.m10 * this.bz + b.m11;
};

Vertex.prototype.tBone2 = function() {
	var b0 = this.boneMtx0;
	var b1 = this.boneMtx1;
	this.dx = ( b0.m0 * this.bx + b0.m1 * this.by + b0.m2 * this.bz + b0.m3 + b1.m0 * this.bx1 + b1.m1 * this.by1 + b1.m2 * this.bz1 + b1.m3 ) * 0.5;
	this.dy = ( b0.m4 * this.bx + b0.m5 * this.by + b0.m6 * this.bz + b0.m7 + b1.m4 * this.bx1 + b1.m5 * this.by1 + b1.m6 * this.bz1 + b1.m7 ) * 0.5;
	this.dz = ( b0.m8 * this.bx + b0.m9 * this.by + b0.m10 * this.bz + b0.m11 + b1.m8 * this.bx1 + b1.m9 * this.by1 + b1.m10 * this.bz1 + b1.m11 ) * 0.5;
};

//Face
function makeFaces( res, vtxs, src, mat, uvsrc, tex ) {
	var len = src.length;
	var w, h, f, arr;
	for ( var i = 0; i < len; ++i ) {
		arr = src[i];
		res[i] = f = new Face( i, vtxs[  arr[0] - 1 ], vtxs[  arr[1] - 1 ], vtxs[  arr[2] - 1 ] );
	}
	
	for ( i = 0; i < len; ++i ) {
		res[i].setUV( mat[i].material, uvsrc, [ mat[i].vIDs[0] - 1, mat[i].vIDs[1] - 1, mat[i].vIDs[2] - 1 ], tex );
	}
}

function Face( id, v0, v1, v2 ) {
	this.id = id;
	this.v0 = v0;
	this.v1 = v1;
	this.v2 = v2;
	this.sz = v0.dz + v1.dz + v2.dz;
	this.visible = false;
}

Face.prototype.renderCvs = function( tg ) {
	var x0 = this.v0.sx, y0 = this.v0.sy;
	var ma = this.uva * this.a + this.uvb * this.c;
	var mc = this.uvc * this.a + this.uvd * this.c;
	var mb = this.uva * this.b + this.uvb * this.d;
	var md = this.uvc * this.b + this.uvd * this.d;
	var mtx = this.uvtx * this.a + this.uvty * this.c;
	var mty = this.uvtx * this.b + this.uvty * this.d;
	
	var x1 = this.v1.sx, x2 = this.v2.sx, y1 = this.v1.sy, y2 = this.v2.sy;
	var cx = ( x0 + x1 + x2 ) * polyCenter;
	var cy = ( y0 + y1 + y2 ) * polyCenter;
	var xd = x0 - cx;
	var yd = y0 - cy;
	var l = polySize / Math.sqrt( xd * xd + yd * yd );
	x0 += xd * l;
	y0 += yd * l;
	xd = x1 - cx; yd = y1 - cy;
	l = polySize / Math.sqrt( xd * xd + yd * yd );
	x1 += xd * l;
	y1 += yd * l;
	xd = x2 - cx; yd = y2 - cy;
	l = polySize / Math.sqrt( xd * xd + yd * yd );
	x2 += xd * l;
	y2 += yd * l;
	
	tg.beginPath();
	tg.moveTo( x0, y0 );
	tg.lineTo( x1, y1 );
	tg.lineTo( x2, y2 );
	tg.closePath();
	
	tg.fillStyle = this.style;
	tg.save();
	tg.transform( ma, mb, mc, md, mtx + x0, mty + y0 );
	tg.fill();
	tg.restore();
};

Face.prototype.renderImg = function() {
	var x0 = this.v0.sx, y0 = this.v0.sy;
	var ma = this.uva * this.a + this.uvb * this.c;
	var mc = this.uvc * this.a + this.uvd * this.c;
	var mb = this.uva * this.b + this.uvb * this.d;
	var md = this.uvc * this.b + this.uvd * this.d;
	var mtx = this.uvtx * this.a + this.uvty * this.c;
	var mty = this.uvtx * this.b + this.uvty * this.d;
	this.faceImg.style.webkitTransform = "matrix(" + ma + ", " + mb + ", " + mc + ", " + md + ", " + ( mtx + x0 ) + ", " + ( mty + y0 ) + ")";
};

Face.prototype.setUV = function( mat, uv, uvID, tex ) {
	var w = tex.width;
	var h = tex.height;
	var t = uv[ uvID[0] ];
	u0 = w * t[0];
	v0 = h * ( 1 - t[1] );
	t = uv[ uvID[1] ];
	u1 = w * t[0];
	v1 = h * ( 1 - t[1] );
	t = uv[ uvID[2] ];
	u2 = w * t[0];
	v2 = h * ( 1 - t[1] );
	
	var a = u1 - u0;
	var b = v1 - v0;
	var c = u2 - u0;
	var d = v2 - v0;
	var tx = u0;
	var ty = v0;
	var a2 = ( a == 0 ) ? 1 : 1 / a;
	var tmpb = ( a == 0 ) ? b : b / a;
	var tmpd = d - c * tmpb;
	var c2 = -( c * a2 ) / ( tmpd == 0 ? 1 : tmpd );
	var d2 = 1 / ( tmpd == 0 ? 1 : tmpd );
	var tmpty = ty - tx * tmpb;
	this.uva = a2 - tmpb * c2;
	this.uvb = -tmpb * d2;
	this.uvc = c2;
	this.uvd = d2;
	this.uvtx = ( -tx * a2 ) - tmpty * c2;
	this.uvty = -tmpty * d2;
	
	var uvxd0 = u1 - u0;
	var uvyd0 = v1 - v0;
	var l0 = uvxd0 * uvxd0 + uvyd0 * uvyd0;
	var uvxd1 = u2 - u1;
	var uvyd1 = v2 - v1;
	var l1 = uvxd1 * uvxd1 + uvyd1 * uvyd1;
	var uvxd2 = u0 - u2;
	var uvyd2 = v0 - v2;
	var l2 = uvxd2 * uvxd2 + uvyd2 * uvyd2;
	var r, pivx, pivy;
	
	if ( l0 >= l1 && l0 >= l2 ) {
		r = Math.atan2( uvyd0, uvxd0 );
		pivx = u0;
		pivy = v0;
		w = Math.sqrt( l0 );
	}else if ( l1 >= l2 ) {
		r = Math.atan2( uvyd1, uvxd1 );
		pivx = u1;
		pivy = v1;
		w = Math.sqrt( l1 );
	}else {
		r = Math.atan2( uvyd2, uvxd2 );
		pivx = u2;
		pivy = v2;
		w = Math.sqrt( l2 );
	}
	
	u0 -= pivx;
	v0 -= pivy;
	u1 -= pivx;
	v1 -= pivy;
	u2 -= pivx;
	v2 -= pivy;
	r = -r;
	var tmpu = Math.cos( r ) * u0 - Math.sin( r ) * v0;
	v0 = Math.sin( r ) * u0 + Math.cos( r ) * v0;
	u0 = tmpu;
	tmpu = Math.cos( r ) * u1 - Math.sin( r ) * v1;
	v1 = Math.sin( r ) * u1 + Math.cos( r ) * v1;
	u1 = tmpu;
	tmpu = Math.cos( r ) * u2 - Math.sin( r ) * v2;
	v2 = Math.sin( r ) * u2 + Math.cos( r ) * v2;
	u2 = tmpu;
	
	if ( v0 < 1 && v1 < 1 && v2 < 1 ) {
		if ( v0 > v1 && v0 > v2 ) {
			v0 = 1;
		}else if ( v1 > v2 ) {
			v1 = 1;
		}else {
			v2 = 1;
		}
	}
	
	h = ( v0 > v1 ) ? ( v0 > v2 ? v0 : v2 ) : ( v1 > v2 ? v1 : v2 );
	
	var margin = isCanvasRender ? 1 : 1;
	u0 += margin;
	v0 += margin;
	u1 += margin;
	v1 += margin;
	u2 += margin;
	v2 += margin;
	w += margin + margin;
	h += margin + margin;
	
	var canvas = document.createElement( "canvas" );
	canvas.width = Math.ceil( w );
	canvas.height = Math.ceil( h );
	var ctx = canvas.getContext( "2d" );
	
	a = u1 - u0;
	b = v1 - v0;
	c = u2 - u0;
	d = v2 - v0;
	var ma = this.uva * a + this.uvb * c;
	var mc = this.uvc * a + this.uvd * c;
	var mb = this.uva * b + this.uvb * d;
	var md = this.uvc * b + this.uvd * d;
	var mtx = this.uvtx * a + this.uvty * c + u0;
	var mty = this.uvtx * b + this.uvty * d + v0;
	
	if ( isCanvasRender ) {
		ctx.save();
		ctx.setTransform( ma, mb, mc, md, mtx, mty );
		ctx.drawImage( tex, 0, 0 );
		ctx.restore();
		this.style = ctx.createPattern( canvas, "no-repeat" );
	}else {
		ctx.fillStyle = "rgba(0,0,0,0)";
		ctx.fillRect( 0, 0, canvas.width, canvas.height );
		
		var x0 = u0, x1 = u1, x2 = u2, y0 = v0, y1 = v1, y2 = v2;
		var cx = ( x0 + x1 + x2 ) * polyCenter;
		var cy = ( y0 + y1 + y2 ) * polyCenter;
		var xd = x0 - cx;
		var yd = y0 - cy;
		margin = 3;
		var l = margin / Math.sqrt( xd * xd + yd * yd );
		x0 += xd * l;
		y0 += yd * l;
		xd = x1 - cx; yd = y1 - cy;
		l = margin / Math.sqrt( xd * xd + yd * yd );
		x1 += xd * l;
		y1 += yd * l;
		xd = x2 - cx; yd = y2 - cy;
		l = margin / Math.sqrt( xd * xd + yd * yd );
		x2 += xd * l;
		y2 += yd * l;
		
		ctx.beginPath();
		ctx.moveTo( x0, y0  );
		ctx.lineTo( x1, y1 );
		ctx.lineTo( x2, y2 );
		ctx.closePath();
		ctx.clip();
		ctx.setTransform( ma, mb, mc, md, mtx, mty );
		ctx.drawImage( tex, 0, 0 );
		
		if ( isCanvasFace ) {
			this.faceImg = canvas;
		}else {
			this.faceImg = new Image();
			this.faceImg.src = canvas.toDataURL();
		}
		this.faceImg.style.position = "absolute";
		this.faceImg.style.visibility = "hidden";
		this.faceImg.style.webkitTransformOrigin = "0 0";
		document.body.appendChild( this.faceImg );
	}
	
	a = u1 - u0;
	b = v1 - v0;
	c = u2 - u0;
	d = v2 - v0;
	tx = u0;
	ty = v0;
	a2 = ( a == 0 ) ? 1 : 1 / a;
	tmpb = ( a == 0 ) ? b : b / a;
	tmpd = d - c * tmpb;
	c2 = -( c * a2 ) / ( tmpd == 0 ? 1 : tmpd );
	d2 = 1 / ( tmpd == 0 ? 1 : tmpd );
	tmpty = ty - tx * tmpb;
	this.uva = a2 - tmpb * c2;
	this.uvb = -tmpb * d2;
	this.uvc = c2;
	this.uvd = d2;
	this.uvtx = ( -tx * a2 ) - tmpty * c2;
	this.uvty = -tmpty * d2;
	this.chkin = isCanvasRender ? this.chkin1 : this.chkin2;
};

Face.prototype.chkin1 = function() {
	var v0 = this.v0, v1 = this.v1,  v2 = this.v2;
	if ( ( this.a = v1.sx - v0.sx ) * ( this.d = v2.sy - v0.sy ) - ( this.b = v1.sy - v0.sy ) * ( this.c = v2.sx - v0.sx ) > 0 ) {
		this.sz = v0.sz + v1.sz + v2.sz;
		return true;
	}else {
		return false;
	}
};

Face.prototype.chkin2 = function() {
	var v0 = this.v0, v1 = this.v1,  v2 = this.v2;
	if ( ( this.a = v1.sx - v0.sx ) * ( this.d = v2.sy - v0.sy ) - ( this.b = v1.sy - v0.sy ) * ( this.c = v2.sx - v0.sx ) > 0 ) {
		this.sz = v0.sz + v1.sz + v2.sz;
		if ( !this.visible ) {
			this.visible = true;
			this.faceImg.style.visibility = "visible";
		}
		return true;
	}else {
		if ( this.visible ) {
			this.visible = false;
			this.faceImg.style.visibility = "hidden";
		}
		return false;
	}
};

Face.prototype.show = function( bool ) {
	if ( this.faceImg ) {
		this.visible = bool;
		this.faceImg.style.visibility = bool ? "visible" : "hidden";
	}
};

//Bone
function makeBone( res, arr, weightsrc, _vertices ) {
	var len = arr.length;
	var dt, bn, iii, ii, vlen;
	
	for ( var i = 0; i < len; ++i ) { arr[i].id = i; }
	
	var sortarr = [];
	var parentID;
	var parentIDarr = [-1];
	var pcount = 0;
	while( pcount < len ){
		for( var m in parentIDarr ){
			parentID = parentIDarr.shift();
			for( var n in arr ){
				if ( arr[n][1] == parentID ) {
					sortarr.push( arr[n] );
					parentIDarr.push( arr[n].id );
					++pcount;
				}
			}
		}
	}
	
	arr = sortarr;
	
	for( i=0; i<len; ++i ){
		dt = arr[i];
		for( ii=0; ii<len; ++ii ){
			if( dt[1] == arr[ii].id ){
				dt[1] = ii >> 0;
				break;
			}
		}
	}
	
	for ( i = 0; i < len; ++i ) {
		res[i] = bn = new Bone( arr[i] );
	}
	
	for( i=0; i<len; ++i ){
		dt = arr[i];
		bn = res[i];
		var weightVtxs;
		for( var k in weightsrc ){
			if( weightsrc[k].name == dt[0] ){
				weightVtxs = weightsrc[k].vertices;
				break;
			}
		}
		var vtxs = [];
		if( weightVtxs ){
			vlen = weightVtxs.length;
			for ( iii = 0; iii < vlen; ++iii ) { vtxs[iii] = _vertices[ weightVtxs[iii]-1 ]; }
		}
		bn.setParent( res[dt[1]] );
		bn.setVertices( vtxs );
	}
}

function Bone( dt ) {
	var scl = 1000;
	this.inix =this.inibx =this.bx = this.dx = dt[3] * scl;
	this.iniy =this.iniby =this.by = this.dy = dt[4] * scl;
	this.iniz =this.inibz =this.bz = this.dz = dt[5] * scl;
	var pi = Math.PI / 180;
	this.rx = dt[7] * pi;
	this.ry = dt[6] * pi;
	this.rz = dt[8] * pi;
	this.mtx = new Matrix();
	this.localMtx = new Matrix();
	this.parent = null;
	this.grx = 0; this.gry = 0; this.grz = 0;
	this.rxr = 0; this.ryr = 0; this.rzr = 0;
	this.vrx = 0; this.vry = 0; this.vrz = 0;
	this.scale = 1;
	this.xsa = 0; this.ysa = 0; this.zsa = 0;
	this.s0 = 0;
	this.s1 = 0;
};

Bone.prototype.setParent = function( b ) {
	if ( b ) {
		with ( this ) {
			parent = b;
			inix = dx = b.dx + bx;
			iniy = dy = b.dy + by;
			iniz = dz = b.dz + bz;
		}
	}
};

Bone.prototype.setVertices = function( arr ) {
	var len = arr.length;
	for( var i=0; i<len; ++i ){ arr[i].addBone( this ); }
};

Bone.prototype.updateMtx = function() {
	var m = this.mtx;
	m.dx = this.dx; m.dy = this.dy; m.dz = this.dz;
	m.rx = this.rx; m.ry = this.ry; m.rz = this.rz;
	m.scale = this.scale;
	m.update();
};

Bone.prototype.updateLocalMtx = function() {
	var m = this.localMtx;
	m.dx = this.bx; m.dy = this.by; m.dz = this.bz;
	m.rx = this.rx; m.ry = this.ry; m.rz = this.rz;
	m.scale = this.scale;
	m.update();
	this.parent.mtx.mult2( this.mtx, this.localMtx );
};

//Matrix
function Matrix() {
	this.dx = 0; this.dy = 0; this.dz = 0;
	this.rx = 0; this.ry = 0; this.rz = 0;
	this.m0 = 0; this.m1 = 0; this.m2 = 0; this.m3 = 0;
	this.m4 = 0; this.m5 = 0; this.m6 = 0; this.m7 = 0;
	this.m8 = 0; this.m9 = 0; this.m10 = 0; this.m11 = 0;
	this.scale = 1;
}

Matrix.prototype.update = function() {
	var cos_x = Math.cos( this.rx );
	var sin_x = Math.sin( this.rx );
	var cos_y = Math.cos( this.ry );
	var sin_y = Math.sin( this.ry );
	var cos_z = Math.cos( this.rz );
	var sin_z = Math.sin( this.rz );
	var cc = sin_y * sin_x;
	var gg = cos_y * sin_x;
	this.m0 = ( cos_y * cos_z + cc * sin_z ) * this.scale;
	this.m1 = ( cos_y * -sin_z + cc * cos_z ) * this.scale;
	this.m2 = ( sin_y * cos_x ) * this.scale;
	this.m3 = this.dx;
	this.m4 = ( cos_x * sin_z ) * this.scale;
	this.m5 = ( cos_x * cos_z ) * this.scale;
	this.m6 = ( -sin_x ) * this.scale;
	this.m7 = this.dy;
	this.m8 = ( -sin_y * cos_z + gg * sin_z ) * this.scale;
	this.m9 = ( -sin_y * -sin_z + gg * cos_z ) * this.scale;
	this.m10 = ( cos_y * cos_x ) * this.scale;
	this.m11 = this.dz;
};

Matrix.prototype.mult2 = function( m, p ) {
	m.m0 = this.m0 * p.m0 + this.m1 * p.m4 + this.m2 * p.m8;
	m.m1 = this.m0 * p.m1 + this.m1 * p.m5 + this.m2 * p.m9;
	m.m2 = this.m0 * p.m2 + this.m1 * p.m6 + this.m2 * p.m10;
	m.m3 = this.m0 * p.m3 + this.m1 * p.m7 + this.m2 * p.m11 + this.m3;
	m.m4 = this.m4 * p.m0 + this.m5 * p.m4 + this.m6 * p.m8;
	m.m5 = this.m4 * p.m1 + this.m5 * p.m5 + this.m6 * p.m9;
	m.m6 = this.m4 * p.m2 + this.m5 * p.m6 + this.m6 * p.m10;
	m.m7 = this.m4 * p.m3 + this.m5 * p.m7 + this.m6 * p.m11 + this.m7;
	m.m8 = this.m8 * p.m0 + this.m9 * p.m4 + this.m10 * p.m8;
	m.m9 = this.m8 * p.m1 + this.m9 * p.m5 + this.m10 * p.m9;
	m.m10 = this.m8 * p.m2 + this.m9 * p.m6 + this.m10 * p.m10;
	m.m11 = this.m8 * p.m3 + this.m9 * p.m7 + this.m10 * p.m11 + this.m11;
};

//Camera
function Camera( pc ) {
	this.x = 0; this.y = 0; this.z = 0;
	this.l = 100;
	this.fov = 40;
	this.wscale = 1;
	
	this.rx = 0; this.ry = 0; this.rz = 0;
	this.grx = 0; this.gry = 0; this.grz = 0;
	
	this.tgx = 0; this.tgy = pc ? 230 : 350; this.tgz = 0;
	this.gx = 0; this.gy = 0; this.gz = 0;
	
	this.myL = 5700;
	this.myLg = this.myL;
	this.myLgR = 0;
	this.xr = 0; this.yr = 0; this.zr = 0;
	this.rxr = 0; this.ryr = 0; this.rzr = 0;
};

Camera.prototype.update = function() {
	this.myL += ( this.myLg - this.myL ) * 0.1;
	var sinX = Math.sin( this.rx );
	var cosX = Math.cos( this.rx );
	var sinY = Math.sin( this.ry );
	var cosY = Math.cos( this.ry );
	var sinZ = Math.sin( -this.rz );
	var cosZ = Math.cos( -this.rz );
	this.y = sinX * this.myL + this.tgy;
	var tz = cosX * -this.myL;
	this.x = sinY * tz + this.tgx;
	this.z = cosY * tz + this.tgz;
	camx = -this.x; camy = -this.y; camz = -this.z;
	this.m0 = cosY * cosZ + sinX * sinY * sinZ;
	this.m1 = cosX * sinZ;
	this.m2 = sinX * cosY * sinZ - sinY * cosZ;
	this.m4 = -( sinX * sinY * cosZ - cosY * sinZ );
	this.m5 = -cosX * cosZ;
	this.m6 = -( sinX * cosY * cosZ + sinY * sinZ );
	this.m8 = cosX * sinY;
	this.m9 = -sinX;
	this.m10 = cosX * cosY;
};

Camera.prototype.resize = function( pc ) {
	this.wscale = ( pc ? 1.7 : 1.5 ) * stageH / ( Math.tan( this.fov / 2 * Math.PI / 180 ) * 2 );
};

//-- zzz.
})();
