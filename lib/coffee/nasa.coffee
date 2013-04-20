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

class nasa.Navigation extends Widget

	constructor: ->
		@UIS = {
			slides	: '.slide'
			nextButtons : '.next'		
		}

	bindUI: (ui) =>		
		super
		this.init()
		this.relayout()
		$(window).on('resize',this.relayout)
		@uis.nextButtons.each( (idx, el) => 
			$(el).click(=>
				console.log "click"
				nextPos = parseInt($(el).parents('.slide').attr('data-position')) + 1
				nextSlide = $('.slide[data-position='+nextPos+']')
				console.log "nextPos "+nextPos+" "+nextSlide.offset().top
				#$(window).scrollTop(nextSlide.offset().top)
				$("html, body").animate({ scrollTop: nextSlide.offset().top});
			)
		)

	init:() =>
		slideIdx=0
		for slide in @uis.slides
			slide = $(slide)
			slide.attr('data-position', slideIdx)
			slideIdx++


	relayout:()=>
		height = $(window).height()
		@uis.slides.height(height)
		@uis.slides.width($(window).width())
		for slide in @uis.slides
			slide = $(slide)
			slide.css("top",slide.attr('data-position') * height)
	
	goToNextSlide:()=>


start()
# EOF