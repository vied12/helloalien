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

class nasa.ContribMap extends Widget
	constructor:() ->
		@UIS = {
			cMap: '#sphere'
		}
		@ACTIONS = []
		@MapAPI = null
		@locations = {}

	bindUI:() =>
		super
		console.log "bindUI"
		this.getLastContribs()
		@uis.cMap.earth3d {
			texture: '/static/images/earth1024x1024.jpg',
			dragElement: $('#locations') 
		}

	getLastContribs: () =>
		console.log "getLastContribs()"
		$.ajax
			url: '/api/map'
			type: 'GET'
			dataType: 'json'
			success: @onContribReceived
			error: console.log


	onContribReceived: (data) => 
		console.log "Received last contribs : ", data 
		
	onMapInitError: (data) =>
		console.error "An error occured while initliazing google earth: ", data

	onMapInitSuccess: () =>


class nasa.ContribForm extends Widget

	constructor: ->
		@UIS = {
			form	: "form"			
			imageZone 	: "#imageZone"
			imageFile 	: ".imageFile"
			soundZone	: "#soundZone"
			soundFile 	: ".soundFile"
			video	    : "video"
			canvas	    : "canvas"
			image	    : "img.avatar"
		}
		@cache = {
			imageZone : null
			soundZone : null
		}
		@ACTIONS = ['snapshot']

	bindUI: (ui) =>		
		super
		this.relayout()
		this.initForm()

	relayout:()=>
		console.log "relayout"

	initForm:() =>
		@initVideo()

	hasGetUserMedia: =>
		return !!(navigator.getUserMedia || navigator.webkitGetUserMedia ||
			navigator.mozGetUserMedia || navigator.msGetUserMedia)

	onFailSoHard: (e) =>
		console.log('Reeeejected!')

	initVideo: =>
		if not @hasGetUserMedia()
			alert('no')
		window.URL = window.URL || window.webkitURL;
		navigator.getUserMedia  = navigator.getUserMedia || navigator.webkitGetUserMedia ||
			navigator.mozGetUserMedia || navigator.msGetUserMedia;
		if navigator.getUserMedia
			navigator.getUserMedia({video: true}, ((localMediaStream) =>
				my_url = window.webkitURL || window.URL
				@uis.video.attr('src', my_url.createObjectURL(localMediaStream))
				@localMediaStream = localMediaStream
				# // Note: onloadedmetadata doesn't fire in Chrome when using it with getUserMedia.
				# // See crbug.com/110938.
				@uis.video.get().onloadedmetadata = console.log
				)
			, @onFailSoHard)
		else
			@uis.video.attr('src', 'somevideo.webm')

	snapshot: =>
		console.log('pouet')
		ctx = @uis.canvas[0].getContext('2d')
		if @localMediaStream
			ctx.drawImage(@uis.video[0], 0, 0)
			# // "image/webp" works in Chrome 18. In other browsers, this will fall back to image/png.
			@uis.image.attr('src', @uis.canvas[0].toDataURL('image/webp'))


			# we create a local form
			$form = $("<form enctype=\"multipart/form-data\"></form>")
			# $form.append @uis.fileInputField.clone(true, true)
			form =  new FormData $form[0]
			form.append "avatar", @uis.canvas[0].toDataURL('image/webp')

			# We send the data throw ajax
			$.ajax
				url         : "/api/upload/avatar"
				type        : 'POST'
				success     : console.log
				error       : not console or console.log
				data        : form
				cache       : false
				contentType : false
				processData : false
				xhr         : -> $.ajaxSettings.xhr()
		# $.ajax
		# 	type: "POST"
		# 	url: "/api/upload/avatar"
		# 	data:
		# 		imgBase64: @uis.canvas[0].toDataURL('image/webp')

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
				nextPos = parseInt($(el).parents('.slide').attr('data-position')) + 1
				nextSlide = $('.slide[data-position='+nextPos+']')
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

start = ->
	$(window).load ()->
		Widget.bindAll()
# EOF