#
# JsfmtRunner - Runs jsfmt on your code. 
# This replaces jsfmt.coffee and doesn't rely on spawning a child process
#

ErrorView = require './errorView'
jsfmt = require 'jsfmt'
fs = require 'fs'
path = require 'path'

config = require './config'


module.exports = 
class JsfmtRunner
  
  @start: =>
    # Commands
    atom.workspaceView.command 'atom-jsfmt:format', => @formatCurrent()
    atom.workspaceView.command 'atom-jsfmt:format-all-open-files', => @formatAllOpen()
    
    # Special command to have another .jsfmtrc for view
    atom.workspaceView.command 'atom-jsfmt:format-for-view', => @formatCurrentForView()
    
    # Editor listeners
    atom.workspaceView.eachEditorView @registerEditor
    
    
  @registerEditor: (editorView) =>
    editor = editorView.getEditor()
    
    # Editor may be created before view
    if !editor._jsfmt?.errorView
      errorView = new ErrorView()
      editorView.append(errorView)
      editor._jsfmt = {errorView}    
    else
      editorView.append(editor._jsfmt.errorView);
    
    # hook .onWillSave save for 
    # see https://github.com/atom/text-buffer/blob/master/src/text-buffer.coffee#L202
    editor.getBuffer().onWillSave =>
      console.log('will save event')
      # hide the errorView
      editor._jsfmt.errorView.hide()

      # if formatOnSave and 
      return unless atom.config.get 'atom-jsfmt.formatOnSave'       
      return unless @editorIsJs editor
      @formatCurrent()
  
    # # hook .onDidSave - reformat for view once saved
    # editor.getBuffer().onDidSave =>
    #   console.log('did save event')
    #   # hide the errorView
    #   editor._jsfmt.errorView.hide()
    # 
    #   return unless atom.config.get 'atom-jsfmt.formatOnSave'       
    #   return unless @editorIsJs editor
    #   @formatCurrentForView()

    # # hook .onDidReload - reformat on load
    # editor.getBuffer().onDidReload =>
    #   return unless atom.config.get 'atom-jsfmt.formatOnSave'  
    #   return unless @editorIsJs editor
    #   @formatCurrentForView()

  @format: (editor, options) ->
    # May not be a view for the editor yet.
    if !editor._jsfmt
      errorView = new ErrorView()
      editor._jsfmt = {errorView}
      
    errorView = editor._jsfmt?.errorView
    buff = editor.getBuffer()
    oldJs = buff.getText()
    newJs = ''
    
    # if no options is provided, get the one for jsfmt
    if options? == false
      filePath = editor.getPath()
      dirName = require('path').dirname(filePath)
      options = config.loadConfig('jsfmt', dirName)
    
    # Attempt to format, log errors
    try
      newJs = jsfmt.format oldJs, options
    catch error
      console.log 'Jsfmt:', error.message, error
      errorView.setMessage(error.message)
      return
    
    # Apply diff only. 
    buff.setTextViaDiff newJs   
    buff.save() if atom.config.get 'atom-jsfmt.saveAfterFormat'

  @formatCurrentForView: () ->
    editor = atom.workspace.getActiveEditor()
    
    # Get the options for jsfmtview
    filePath = editor.getPath()
    dirName = require('path').dirname(filePath)
    options = config.loadConfig('jsfmtview', dirName)

    @format editor, options if @editorIsJs editor
  
  @formatCurrent: () ->
    editor = atom.workspace.getActiveEditor()
    @format editor if @editorIsJs editor
    
  @formatAllOpen: () ->
    editors = atom.workspace.getEditors()
    @format editor for editor in editors when @editorIsJs editor
    
  @editorIsJs: (editor) ->
    return editor.getGrammar().scopeName is 'source.js'
    
