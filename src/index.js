require("./index.scss");

var remote = require("electron").remote;
var ipcRenderer = require("electron").ipcRenderer;

var configuration = JSON.parse(remote.getGlobal("configuration"));

var Elm = require("./Main.elm");
var app = Elm.Main.fullscreen(configuration);

app.ports.updateBadgeCount.subscribe(function(badgeCount) {
  ipcRenderer.send("updateBadgeCount", badgeCount);
});
