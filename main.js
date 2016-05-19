var electron = require("electron");
var app = electron.app;
var shell = electron.shell;
var BrowserWindow = electron.BrowserWindow;
var ipcMain = require("electron").ipcMain;
var fs = require("fs");
var os = require("os");

// Read the configuration file from disk
var configurationPath = os.homedir() + "/.config/rhubarb/rhubarb.json";
global.configuration = fs.readFileSync(configurationPath, "utf8");

ipcMain.on("updateBadgeCount", function(_, badgeCounter) {
  var value = (badgeCounter > 0) ? badgeCounter.toString() : "";
  app.dock.setBadge(value);
});

app.on("window-all-closed", function() {
  if (process.platform != "darwin") {
    app.quit();
  }
});

var mainWindow = null;

app.commandLine.appendSwitch("--disable-http-cache");

app.on("ready", function() {
  mainWindow = new BrowserWindow({width: 450, height: 800, titleBarStyle: "hidden-inset"});

  // Always open external links in the real browser
  mainWindow.webContents.on("new-window", function(event, url) {
    event.preventDefault();
    shell.openExternal(url);
  });

  mainWindow.loadURL("file://" + __dirname + "/public/index.html");

  mainWindow.on("closed", function() {
    mainWindow = null;
  });
});
