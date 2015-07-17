function log(msg) {
	var log = document.getElementById('log');
	log.innerHTML = log.innerHTML + '<br />' + msg;
}

var app = {
	initialize: function() {
		this.bindEvents();
	},
	bindEvents: function() {
		document.addEventListener('deviceready', this.onDeviceReady, false);
	},
	onDeviceReady: function() {
		log('Device Ready');
		
		//var openEars;
		document.getElementById("oeButtonInitialize").addEventListener("click", function() {
			log('Open Ears: initialize');
			openEars = window.OpenEars.initialize();
		});

		document.getElementById("oeButtonStartListening").addEventListener("click", function() {
			log('Open Ears: startListening');
			openEars.startListening();
		});
	}
};

app.initialize();
