var FrameCamera = {
  getPicture: function(success, failure) {
    cordova.exec(success, failure, "FrameCamera", "openCamera", []);
  }
}
