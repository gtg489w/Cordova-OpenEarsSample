function log(msg) {
	var log = document.getElementById('log');
	log.innerHTML = log.innerHTML + '<br />' + msg;
}

function status(msg) {
	var el = document.getElementById('oeStatus');
	el.innerHTML = msg;
}

var openEars;

var app = {
	initialize: function() {
		this.bindEvents();
	},
	bindEvents: function() {
		document.addEventListener('deviceready', this.onDeviceReady, false);
	},
	onDeviceReady: function() {
		log('Device Ready');

		// Setup OpenEars and Listeners
		openEars = window.OpenEars;
		document.addEventListener("pocketsphinxDidReceiveHypothesis", function(e) {
			log('Hypothesis: ' + e.detail.hypothesis + ' (' + e.detail.recognitionScore + ')');
		}, false);

		document.addEventListener("audioSessionInterruptionDidBegin", function(e) {
			log('Interrupted');
		}, false);

		document.addEventListener("audioSessionInterruptionDidEnd", function(e) {
			log('Resumed');
		}, false);

		document.addEventListener("micPermissionCheckCompleted", function(e) {
			log('Mic check: ');
			console.log(e);
		}, false);

		document.addEventListener("fliteDidStartSpeaking", function(e) {
			statu('Started speaking');
		}, false);

		document.addEventListener("fliteDidFinishSpeaking", function(e) {
			status('Finished speaking');
		}, false);

		document.addEventListener("pocketsphinxDidDetectSpeech", function(e) {
			status('I hear you');
		}, false);

		document.addEventListener("pocketsphinxDidDetectFinishedSpeech", function(e) {
			status('You\'re done talking');
		}, false);
		
		



		// Buttons

		document.getElementById("oeButtonInitialize").addEventListener("click", function() {
			log('initializing');
			openEars.initialize();
		});

		document.getElementById("oeButtonStartListening").addEventListener("click", function() {
			log('Start listening');
			openEars.startListening();
		});

		document.getElementById("oeButtonSay").addEventListener("click", function() {
			log('Saying hello');
			openEars.say();
		});
	}
};

app.initialize();
