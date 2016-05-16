var electron = require("electron");
var app = electron.app;
var shell = electron.shell;
var BrowserWindow = electron.BrowserWindow;
var fs = require("fs");
var os = require("os");

// Read the configuration file from disk
var configurationPath = os.homedir() + "/.config/rhubarb/rhubarb.json";
global.configuration = fs.readFileSync(configurationPath, "utf8");

// Create the `~/.config/rhubarb/archived.json` file if it doesn't exist
var archivedIssuesPath = os.homedir() + "/.config/rhubarb/archived.json";

if (!fs.existsSync(archivedIssuesPath)) {
  fs.writeFileSync(archivedIssuesPath, "[]", { flag: "wx" }, function () {});
}

// Read all archived issues from `~/.config/rhubarb/github_archived.json`
global.archived = fs.readFileSync(archivedIssuesPath, "utf8");

// Use `electron.ipcMain` so we can publish an event for saving all archived
// issues
var ipcMain = require("electron").ipcMain;
ipcMain.on("writeArchivedIssues", function(_, archivedIssues) {
  fs.writeFileSync(archivedIssuesPath, JSON.stringify(archivedIssues));
});

ipcMain.on("updateBadgeCount", function(_, badgeCounter) {
  app.dock.setBadge(badgeCounter.toString());
});

app.on("window-all-closed", function() {
  if (process.platform != "darwin") {
    app.quit();
  }
});

var mainWindow = null;

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
