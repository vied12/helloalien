# -----------------------------------------------------------------------------
# Project : Platinium records
# -----------------------------------------------------------------------------
# Author : Edouard Richard                                  <edou4rd@gmail.com>
# -----------------------------------------------------------------------------
# License : MIT licence
# -----------------------------------------------------------------------------
# Creation : 20-Apr-2013
# Last mod : 20-Apr-2013
# -----------------------------------------------------------------------------
window.nasa = {}

Widget   = window.serious.Widget
URL      = new window.serious.URL()
Format   = window.serious.format
Utils    = window.serious.Utils

start = ->
	$(window).load ()->
		Widget.bindAll()

class nasa.ContribForm extends Widget

	constructor: ->
		@UIS = {
			form	: "form"			
			imageZone 	: "#imageZone"
			imageFile 	: ".imageFile"
			soundZone	: "#soundZone"
			soundFile 	: ".soundFile"
			avatar	: "video"
		}
		@cache = {
			imageZone : null
			soundZone : null
		}
	bindUI: (ui) =>		
		super
		console.log "contrib"
		this.relayout()
		this.initForm()

	relayout:()=>
		console.log "relayout"

	initForm:() =>
		@cache.imageZone = new Dropzone("div#imageZone", { url: "/api/upload/image"})
		@cache.soundZone = new Dropzone("div#soundZone", { url: "/api/upload/sound"})
		#@uis.soundZone.dropzone({ url: "/api/upload/sound" })
		#@uis.imageZone.dropzone({ url: "/api/upload/image" })	

	webcamCapture:()=>
		video = document.querySelector('video')
		canvas = document.querySelector('canvas')
		ctx = canvas.getContext('2d')
		localMediaStream = null
		video.addEventListener('click', snapshot, false);
		#Not showing vendor prefixes or code that works cross-browser.
		navigator.getUserMedia({video: true}, (stream) =>
			video.src = window.URL.createObjectURL(stream)
			localMediaStream = stream
		, onFailSoHard)

	hasGetUserMedia: () =>
		return !!(navigator.getUserMedia || navigator.webkitGetUserMedia ||	navigator.mozGetUserMedia || navigator.msGetUserMedia)		

start()
# EOF