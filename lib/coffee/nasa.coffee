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

    bindUI:() =>
        super
        $('#sphere').earth3d {
            texture: '/static/images/earth1024x1024.jpg',
            dragElement: @ui.find('#locations') 
        }
    onMapInitError: (data) =>
        console.error "An error occured while initliazing google earth: ", data

    onMapInitSuccess: () =>


start = ->
	$(window).load ()->
        Widget.bindAll()
# EOF