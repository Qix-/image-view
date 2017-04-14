path = require 'path'
url = require 'url'
_ = require 'underscore-plus'
ImageEditor = require './image-editor'
{CompositeDisposable} = require 'atom'

module.exports =
  activate: ->
    @statusViewAttached = null
    @disposables = new CompositeDisposable
    @disposables.add atom.workspace.addOpener(openURI)
    @disposables.add atom.workspace.onDidChangeActivePaneItem => @attachImageEditorStatusView()

  deactivate: ->
    @statusViewAttached?.destroy()
    @disposables.dispose()

  consumeStatusBar: (@statusBar) -> @attachImageEditorStatusView()

  attachImageEditorStatusView: ->
    return if @statusViewAttached
    return unless @statusBar?
    return unless atom.workspace.getActivePaneItem() instanceof ImageEditor

    ImageEditorStatusView = require './image-editor-status-view'
    @statusViewAttached = new ImageEditorStatusView(@statusBar)
    @statusViewAttached.attach()

  deserialize: (state) ->
    ImageEditor.deserialize(state)

# Files with these extensions will be opened as images
imageExtensions = ['.bmp', '.gif', '.ico', '.jpeg', '.jpg', '.png', '.webp']
openURI = (uriToOpen) ->
  parsedUrl = url.parse(uriToOpen)
  return if parsedUrl.protocol? and parsedUrl.protocol isnt 'file:'
  uriToOpen = parsedUrl.path

  uriExtension = path.extname(uriToOpen).toLowerCase()
  if _.include(imageExtensions, uriExtension)
    new ImageEditor(uriToOpen)
