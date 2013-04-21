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
        @obj1 = {
            alpha: Math.PI / 4,
            delta: 0,
            name: 'location 1'
        }
        @UIS = {
            cMap: '#sphere'
            locations: '#locations'
        }
        @ACTIONS = []
        @MapAPI = null
        @locations = {}

    bindUI:() =>
        super
        console.log "bindUI"
        this.getLastContribs()

    getLastContribs: () =>
        console.log "getLastContribs()"
        $.ajax
            url: '/api/map'
            type: 'GET'
            dataType: 'json'
            success: @onContribReceived
            error: console.log

    addLocation: (location, key) =>
        @map.options.locations[key] = location
        location.visible = true
        @map.options.onInitLocation(location, @map)

    onContribReceived: (data) => 
        locations = {
            obj2: {
              alpha: 1 * Math.PI / 4,
              delta: -2 * Math.PI / 4,
              name: 'location 2'
            },
            obj3: {
              alpha: 2 * Math.PI / 4,
              delta: 0,
              name: 'location 3'
            },
            obj4: {
              alpha: 3 * Math.PI / 4,
              delta: 3 * Math.PI / 4,
              name: 'location 4'
            }
        }
        ###
        for contrib in data
            do(self=this, locations, contrib) ->
                alpha = contrib.user.lnt
                delta = contrib.user.lat
                locations[contrib._id['$oid']] = {
                    alpha: (contrib.user.lng / 100) * Math.PI / 4
                    delta: (contrib.user.lat / 100) * Math.PI / 4
                    name: contrib._id['$oid']
                }
        console.log locations
        ###
        console.log locations
        console.log @uis.locations
        @uis.cMap.earth3d {
            texture: '/static/images/earth1024x1024.jpg',
            dragElement: @uis.locations 
            locations: locations
            locationsElement: @uis.locations
            onCreated: @onMapInitialized
        }
        console.log @uis.locations

        console.log "Received last contribs : ", data 

    onMapInitError: (data) =>
        console.error "An error occured while initliazing google earth: ", data

    onMapInitialized: (mapInstance) =>
        console.log "onMapInitialized(", mapInstance, ")"
        @map = mapInstance


class nasa.ContribForm extends Widget

	constructor: ->
		@UIS = {
			form	: "form"			
			imageZone 	: "#imageZone"
			imageFile 	: ".imageFile"
			soundZone	: "#soundZone"
			soundFile 	: ".soundFile"
			video	: "video"
			canvas	: "canvas"
			image	: "img"
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
		# @cache.imageZone = new Dropzone("div#imageZone", { url: "/api/upload/image"})
		# @cache.soundZone = new Dropzone("div#soundZone", { url: "/api/upload/sound"})
		#@uis.soundZone.dropzone({ url: "/api/upload/sound" })
		#@uis.imageZone.dropzone({ url: "/api/upload/image" })	
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
				# // Note: onloadedmetadata doesn't fire in Chrome when using it with getUserMedia.
				# // See crbug.com/110938.
				@uis.video.get().onloadedmetadata = console.log
				)
			, @onFailSoHard)
		else
			@uis.video.attr('src', 'somevideo.webm')

	snapshot: =>
		ctx = canvas.getContext('2d')
		if localMediaStream
			ctx.drawImage(video, 0, 0)
			# // "image/webp" works in Chrome 18. In other browsers, this will fall back to image/png.
			uis.image.attr('src', canvas.toDataURL('image/webp'))

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



start = ->
    $(window).load ()->
        Widget.bindAll()
# EOF