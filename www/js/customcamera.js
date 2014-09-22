var customCamera = {
    getPicture: function(frame, filename, success, onPhoto, failure, options) {
        options = options || {};
        var quality = options.quality || 100;
        cordova.exec(function(msg) {
	    if(msg == "success") {
		success();
	    } else {
		onPhoto(msg);
	    }
	}, failure, "CustomCamera", "takePicture", [frame, filename, quality]);
    }
};

module.exports = customCamera;
