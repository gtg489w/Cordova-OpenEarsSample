// function log(msg) {
// 	var log = document.getElementById('log');
// 	log.innerHTML = log.innerHTML + '<br />' + msg;
// }

var app = {
	initialize: function() {
		this.bindEvents();
	},
	bindEvents: function() {
		document.addEventListener('deviceready', this.onDeviceReady, false);
	},
	onDeviceReady: function() {
		// log('Device Ready');

		alert('device ready!');
		
		//var openEars;
		document.getElementById("oeButtonInitialize").addEventListener("click", function() {
			alert('Open Ears: initialize');
			openEars = window.OpenEars.initialize();
		});

		document.getElementById("oeButtonStartListening").addEventListener("click", function() {
			alert('Open Ears: startListening');
			openEars.startListening();
		});
	}
};

app.initialize();
