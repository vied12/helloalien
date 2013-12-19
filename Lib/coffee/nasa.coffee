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
# URL      = new window.serious.URL()
Format   = window.serious.format
Utils    = window.serious.Utils

# -----------------------------------------------------------------------------
#
#    NAVIGATION
#
# -----------------------------------------------------------------------------
class nasa.Navigation extends Widget

	constructor: ->
		@UIS = {
			wrapper : '.wrapper'
			slides	: '.slide'
			nextButtons : '.next'		
		}
		@cache = {
			activeSlide : 3
		}

	bindUI: (ui) =>		
		super
		this.initPositions()
		this.relayout()
		$(window).on('resize',this.relayout)
		@uis.nextButtons.each( (idx, el) => 
			$(el).click(=>
				nextPos = parseInt($(el).parents('.slide').attr('data-position')) + 1
				nextSlide = $('.slide[data-position='+nextPos+']')
				$('html,body').animate({ scrollTop: nextSlide.offset().top})
				@cache.activeSlide  = parseInt(nextPos)
			)
		)
		$('.back').click =>
			@cache.activeSlide  = 0
			this.init() 

	init:()=>
		$('html,body').scrollTop(0)

	initPositions:() =>
		for slide, i in @uis.slides
			$(slide).attr('data-position', i)

	relayout:()=>
		height = $(window).height()
		@uis.slides.height(height)
		@ui.find('.autoHeight').height(height)
		@uis.slides.width($(window).width())		
		for slide in @uis.slides
			slide = $(slide)
			slide.css("top",slide.attr('data-position') * height)
		activeSlide = @ui.find('.slide[data-position='+@cache.activeSlide+']')
		$('html,body').scrollTop(@cache.activeSlide * height)

# -----------------------------------------------------------------------------
#
#    CONTRIB FORM
#
# -----------------------------------------------------------------------------
class nasa.ContribForm extends Widget

	constructor: ->
		@UIS = {
			form	: "form"			
			okZone      : '.next'
			imageZone 	: "#imageZone"
			imageFile 	: "#id_image"
			soundZone	: "#soundZone"
			soundFile 	: "#id_sound"
			video	    : "video"
			canvas	    : "canvas"
			image	    : "img.avatar"
			formHolder  : '.contrib-form-background'

		}
		@cache = {
			imageZone : null
			soundZone : null
			uploadedImage: false
			uploadedSound: false
		}
		@ACTIONS = ['snapshot', 'sendImage', 'sendSound']

	bindUI: (ui) =>
		super
		this.initForm()
		# NOTE: $.browser.mozilla doesn't work with jquery2.0
		# @ffTweak()
	
	ffTweak: () =>
		if $.browser.mozilla
			@ui.find('.uploadField label').bind 'click', (e) -> 
				elem = e.target()
				e.stopPropagation()
				id = $(elem).attr('for')
				$("input##{id}").click()

	initForm: =>
		@initVideo()
		@bindFields()

	bindFields: =>
		@uis.imageZone.hover(@imageHovered, @imageUnhovered) 
		@uis.soundZone.hover(@soundHovered, @soundUnhovered) 
		@uis.okZone.hover(@okHovered, @okUnhovered) 

		@uis.imageFile.change @sendImage
		@uis.soundFile.change @sendSound

	imageHovered: =>
		@uis.formHolder.addClass 'image-hovered'

	imageUnhovered: =>
		@uis.formHolder.removeClass 'image-hovered'

	soundHovered: =>
		@uis.formHolder.addClass 'sound-hovered'

	soundUnhovered: =>
		@uis.formHolder.removeClass 'sound-hovered'

	okHovered: =>
		@uis.formHolder.addClass 'ok-hovered'

	okUnhovered: =>
		@uis.formHolder.removeClass 'ok-hovered'

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
		ctx = @uis.canvas[0].getContext('2d')
		if @localMediaStream
			ctx.drawImage(@uis.video[0], 0, 0)
			# // "image/webp" works in Chrome 18. In other browsers, this will fall back to image/png.
			@uis.image.attr('src', @uis.canvas[0].toDataURL('image/webp'))
			@uis.image.removeClass "hidden"
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

	hasGetUserMedia: =>
		return !!(navigator.getUserMedia || navigator.webkitGetUserMedia ||	navigator.mozGetUserMedia || navigator.msGetUserMedia)		

	sendImage: =>
		@sendMedia('picture', @uis.imageFile)

	sendSound: =>
		@sendMedia('audio', @uis.soundFile)

	sendMedia: (type, value) =>
		# we create a local form
		$form = $("<form enctype=\"multipart/form-data\"></form>")
		form =  new FormData $form[0]
		file = value.prop("files")[0]
		form.append 'key'                    , "uploaded/${filename}"
		form.append 'AWSAccessKeyId'         , "AKIAINPPUWMRYEPIO6CQ"
		form.append 'acl'                    , "public-read"
		form.append 'success_action_redirect', "http://localhost:5000/uploaded/#{type}/"
		form.append 'policy'                 , "eyJleHBpcmF0aW9uIjogIjIwMTUtMDEtMDFUMDA6MDA6MDBaIiwKCSJjb25kaXRpb25zIjogWwoJCXsiYnVja2V0IjogImhlbGxvYWxpZW4yIn0sIAoJCVsic3RhcnRzLXdpdGgiLCAiJGtleSIsICJ1cGxvYWRlZC8iXSwKCQl7ImFjbCI6ICJwdWJsaWMtcmVhZCJ9LAoJCVsic3RhcnRzLXdpdGgiLCAiJHN1Y2Nlc3NfYWN0aW9uX3JlZGlyZWN0IiwgImh0dHA6Ly9sb2NhbGhvc3Q6NTAwMC91cGxvYWRlZC8iXSwKCQlbInN0YXJ0cy13aXRoIiwgIiRjb250ZW50LXR5cGUiLCAiIl0sCgkJWyJzdGFydHMtd2l0aCIsICIkeC1hbXotbWV0YS10eXBlIiwgIiJdLAoJCVsiY29udGVudC1sZW5ndGgtcmFuZ2UiLCAwLCAxNTA0ODU3Nl0KCV0KfQ=="
		form.append 'signature'              , "bznZKwc2LLY7IxjCZfEIXjucLT4="
		form.append 'x-amz-meta-type'        , type
		form.append 'Content-Type'           , file.type
		form.append 'file'                   , file
		$.ajax
			url     : "https://helloalien2.s3.amazonaws.com/"
			type    : "POST"
			success :(a) =>
				console.log(a)
			data    : form
			cache   : false
			dataType: "json"
			contentType: false
			processData: false
			xhr : -> $.ajaxSettings.xhr()

	onMediaSent: (data) =>
		response = JSON.parse(JSON.parse(data)) #DA FUK IZ DAT ? LOL@!?
		for media in response.medias
			if media.type = 'picture'
				@cache.imageUploaded = true
			if media.type = 'audio'
				@cache.soundUploaded = true

# -----------------------------------------------------------------------------
#
#    GLOBE
#
# -----------------------------------------------------------------------------
class nasa.ContribMap extends Widget

	constructor: ->

		@UIS = 
			wrapper : "#contrib-map"
		@path
		@λ
		@φ
		@svg
		@projection

	bindUI: (ui) =>
		super
		width  = 400
		height = 400
		@revolution = 40000
		that = @
		@projection = d3.geo.orthographic()
			.scale(200)
			.translate([width / 2, height / 2])
			.clipAngle(90)
		@path = d3.geo.path()
			.projection(@projection)

		@λ = d3.scale.linear()
			.domain([0, @revolution])
			.range([-180, 180])

		@φ = d3.scale.linear()
			.domain([0, @revolution])
			.range([90, -90])

		@svg = d3.select(@uis.wrapper[0]).append("svg")
			.attr("width", width)
			.attr("height", height)

		
		@groupPaths = @svg.append("g").attr("class", "all-path")
		
		@loadGraticule()

		# @svg.on "click", ->
		# 	p = d3.mouse(this)
		# 	console.log([that.λ(p[0]), that.φ(p[1])])
		# 	that.projection.rotate([that.λ(p[0]), that.φ(p[1])])
		# 	that.svg.selectAll("path").attr("d", that.path)

		d3.json("/static/images/map.json", @onMapLoaded)

		@startAnimation()

	loadGraticule: =>
		graticule   = d3.geo.graticule()
		@groupPaths.append("path")
			.datum(graticule)
			.attr("class", "graticule")
			.attr("d", @path)
	onMapLoaded : (error, world) =>
		@groupPaths.append("path")
			.datum(topojson.feature(world, world.objects.land))
			.attr("class", "land")
			.attr("d", @path)

	startAnimation: =>
		requestAnimationFrame @rotate()

	rotate : =>
		return (timestamp) =>
			if not @start?
				@start = timestamp
			progress = timestamp - @start
			@projection.rotate([@λ(progress), -20])
			@groupPaths.selectAll('path').attr("d", @path)
			if progress < @revolution
				requestAnimationFrame @rotate()
			else
				@start = undefined
				requestAnimationFrame @rotate()
			

# -----------------------------------------------------------------------------
#
#    Image slider
#
# -----------------------------------------------------------------------------
class nasa.ImageSlider extends Widget
	constructor: ->
		@UIS = {
			image : 'img'
		}
		@images = []
		@currentImageIndex = 0

	bindUI: =>
		super
		$.getJSON '/api/pictures', (data) =>
			@images = data
			@start()

	setImage: (img) =>
		@uis.image.attr('src', img)

	start: =>
		if @images.length <= @currentImageIndex + 1
			@currentImageIndex = 0
		url_img = @images[@currentImageIndex]
		$("<img/>").attr('src', url_img).load =>
			@setImage(url_img)
			@currentImageIndex += 1
			setTimeout(@start, 1000)

start = ->
	$(window).load ()->
		Widget.bindAll()

start()

# EOF