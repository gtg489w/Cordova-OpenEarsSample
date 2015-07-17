var app = {
	initialize: function() {
		this.bindEvents();
	},
	bindEvents: function() {
		document.addEventListener('deviceready', this.onDeviceReady, false);
	},
	onDeviceReady: function() {
		console.log('Device Ready');
	}
};

app.initialize();


var openEars;

document.getElementById("oeButtonInitialize").addEventListener("click", function() {
	console.log('Open Ears: initialize');
	openEars = window.cordova.plugins.OpenEars.initialize();
});

document.getElementById("oeButtonStartListening").addEventListener("click", function() {
	console.log('Open Ears: startListening');
	openEars.startListening();
});
