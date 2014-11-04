var customCamera = {
    getPicture: function(frame, filename, success, failure, options) {
        options = options || {};
        var quality = options.quality || 80;
        cordova.exec(success, failure, "CustomCamera", "takePicture", [frame, filename, quality]);
    }
};

module.exports = customCamera;
