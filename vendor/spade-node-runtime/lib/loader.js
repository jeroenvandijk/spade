// ==========================================================================
// Project:   Spade - CommonJS Runtime
// Copyright: ©2010 Strobe Inc. All rights reserved.
// License:   Licened under MIT license (see __preamble__.js)
// ==========================================================================
/*globals process __filename __dirname */

var PATH = require('path'),
    SYS  = require('sys'),
    FS   = require('fs'),
    SPADE_DIR = '.spade', // Would be nice if we could share Spade::SPADE_DIR
    PACKAGE_DIR = PATH.join(process.env.HOME, SPADE_DIR, 'gems');

exports.Loader = function() {
  this.root = process.cwd();
};

var Lp = exports.Loader.prototype;

function addPackage(packages, dirname, filename) {
  if (filename[0] === '.') return ; // nothing to do
  var path = PATH.join(dirname, filename);
  if (!PATH.existsSync(path) || !FS.statSync(path).isDirectory()) return;

  var jsonPath = PATH.join(path, 'package.json');
  if (!PATH.existsSync(jsonPath)) return ; // not a pkg

  var json;
  try {
    json = JSON.parse(FS.readFileSync(jsonPath));
  } catch(e) {
    json = null;
  }

  if (!json) return; // nothing to do

  var directories = json.directories || { lib: 'lib' };
  if (!json.directories && json.lib) directories.lib = json.lib;
  var name = json.name || filename;
  packages[name] = {
    register: false,
    path:     path,
    directories: directories,
    json: json
};
}

function finishLoad(done) {
  if (done) done();
  return null;
}

function registerModule(spade, id, path, done) {
  spade.register(id, FS.readFileSync(path, 'utf8'));
  return finishLoad(done);
}

function registerNode(spade, id, loader, done) {

  // register a package the first time someone tries to load the module
  if (!loader._nodeRegistered) {
    loader._nodeRegistered = true;
    spade.register('node', { name: "node", version: process.version });
  }

  // when loading this module, just do a native node require...
  spade.register(id, function(r, e, m) { m.exports = require(id.slice(5)); });

}

Lp.packages = function() {
  if (this._packages) return this._packages;
  var packages = {};
  this._packages = packages;

  // add spade install dir
  if (PATH.existsSync(PACKAGE_DIR) && FS.statSync(PACKAGE_DIR).isDirectory()) {
    FS.readdirSync(PACKAGE_DIR).forEach(function(name){
      addPackage(packages, PACKAGE_DIR, name);
    });
  }

  // Add other dirs in reverse order of precedence
  var dirs = ['.spade/packages', 'node_modules', '.node_modules', 'vendor/cache', 'vendor/packages', 'packages'];
  var rootdir = PATH.normalize(this.root);

  dirs.forEach(function(dirname) {
    dirname = dirname.split('/');
    dirname.unshift(rootdir);
    dirname = PATH.join.apply(PATH, dirname);
    if (PATH.existsSync(dirname) && FS.statSync(dirname).isDirectory()) {
      FS.readdirSync(dirname).forEach(function(name) {
        addPackage(packages, dirname, name);
      });
    }
  });

  addPackage(packages, PATH.dirname(this.root), PATH.basename(this.root));

  return packages;
};

Lp.loadFactory = function(spade, id, formats, done) {
  if (!formats) { formats = []; }
  if (formats.length === 0) { formats.push('js'); }

  if (id.indexOf('(file)/')===0) {
    return registerModule(spade, id, id.slice(6), done);
  }

  if (id.indexOf('node/')===0) { return registerNode(spade, id, this, done); }

  var parts = id.split('/');
  var packageName = parts.shift();
  var packageInfo = this.packages()[packageName];

  if (!packageInfo) { return finishLoad(done); }

  if (parts.length>0 && (parts[0][0] === '~')) {
    var dirname = parts.shift().slice(1);
    dirname = packageInfo.directories[dirname] || dirname;
  } else {
    dirname = packageInfo.directories['lib'] || 'lib';
  }

  // register package first if needed
  if (!packageInfo.registered) {
    packageInfo.registered = true;
    spade.register(packageName, packageInfo.json);
  }

  parts.unshift(dirname);
  parts.unshift(packageInfo.path);

  var path = PATH.join.apply(PATH,parts), loadPath;
  for (var i=0, len=formats.length; i < len; i++) {
    loadPath = path+'.'+formats[i];
    if (PATH.existsSync(loadPath)) { return registerModule(spade, id, loadPath, done); }
  }

  return this._factories[id];
};

Lp.scheduleReady = function(callback) {
  callback();
};
