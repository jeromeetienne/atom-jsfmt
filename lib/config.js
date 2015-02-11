/**
 * @fileOverview forked from jsfmt/lib/config.js this one doesnt rely on ```rc``` npm
 * which seems buggy in how it d
 */


var defaultStyle = require('../node_modules/jsfmt/lib/defaultStyle.json');

exports.loadConfig = loadConfig
exports.findConfigFile = findConfigFile


/**
 * find a config
 * 
 * @param {String} appName     - the application name
 * @param {String} baseDirName - the base directory to start with
 * @return {Object} - the configuration 
 */
function loadConfig(appName, baseDirName) {

  // try to find the configFile
  var fileContent = findConfigFile(appName, baseDirName)

  // if no file is found, give it an empty object
  fileContent = fileContent || '{}'
  var config = JSON.parse(fileContent)
  console.log('config post file', config)

  // read default style and merge it witht
  var defaultConfig = require('../node_modules/jsfmt/lib/defaultStyle.json');
  var deepExtend = require('./node-deep-extend')
  config = deepExtend({}, defaultConfig, config)
  console.log('config post merge default', config)

  return config
}

/**
 * find a config file
 * 
 * @param {String} appName     - the application name
 * @param {String} baseDirName - the base directory to start with
 * @return {String|null} - the read content if the file has been found, null otherwise 
 */
function findConfigFile(appName, baseDirName) {
  // init variables
  var path = require('path')
  var baseName = '.' + appName + 'rc'
  var fileNames = []

  // push all the fileName
  var dirName = path.normalize(baseDirName)
  fileNames.push(path.join(dirName, baseName))
  // iterate on all parent directories
  while (dirName !== '/') {
    dirName = require('path').dirname(dirName)
    fileNames.push(path.join(dirName, baseName))
    // console.log('dirname', dirName)
  }

  // try to read all fileNames in order
  for (var i = 0; i < fileNames.length; i++) {
    var fileName = fileNames[i]
    // try to read this filename
    try {
      var content = require('fs').readFileSync(fileName, 'utf-8')
      return content
    } catch (err) {}
  }
  // if nothing is found, return null
  return null
}
