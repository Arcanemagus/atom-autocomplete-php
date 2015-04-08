exec = require "child_process"

data =
  statics: []

printError = (error) ->
  console.log error

  data.error = true
  message = error.message

  if error.file? and error.line?
    message = message + ' [from file ' + error.file + ' - Line ' + error.line + ']';

  window.alert message

# -------------------------------------- CLASSES ----------------------------------------
# Parse --classes response
parseClasses = (error, stdout, stderr) ->
  res = JSON.parse(stdout)

  if res.error?
    printError(res.error)

  data.classes = res

# Fetch --classes
fetchClasses = () ->
  for directory in atom.project.getDirectories()
    exec.exec("php " + __dirname + "/../php/parser.php " + directory.path + " --classes", parseClasses)

# -------------------------------------- STATICS ----------------------------------------
parseStatics = (error, stdout, stderr) ->
  res = JSON.parse(stdout)

  if res.error?
    printError(res.error)

  data.statics[res.class] = res

fetchStatics = (className) ->
  for directory in atom.project.getDirectories()
    exec.exec("php " + __dirname + "/../php/parser.php " + directory.path + " --statics " + className, parseStatics)

module.exports =
  classes: () ->
    if not data.classes? and not data.error?
      fetchClasses()

    return data.classes

  statics: (className) ->
    if not data.statics[className]? and not data.error?
      fetchStatics(className)

    return data.statics[className]