require("./index.scss");

var remote = require("electron").remote;
var ipcRenderer = require("electron").ipcRenderer;

var configuration = JSON.parse(remote.getGlobal("configuration"));
var archivedIssues = JSON.parse(remote.getGlobal("archived"));

var flags = {
  configuration: configuration,
  archivedIssues: archivedIssues
};

var Elm = require("./Main.elm");
var app = Elm.Main.fullscreen(flags);

app.ports.updateArchivedIssues.subscribe(function(obj) {
  ipcRenderer.send("writeArchivedIssues", obj[0]);
  ipcRenderer.send("updateBadgeCount", obj[1]);
});
