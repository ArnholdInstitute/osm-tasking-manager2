# -*- coding: utf-8 -*-
<%
from geoalchemy2 import shape
geometry_as_shape = shape.to_shape(task.geometry)
bounds = geometry_as_shape.bounds
project = task.project
%>
<div id='map' style="position: absolute; top:0;left: 0; right: 0; bottom: 0">
  <button id="done-mapping" class="btn btn-default" style="position: absolute; z-index: 5000; top: 20; right:20; height:40; border-radius: 10px;background-color : #337AB7; color : white;">
    Done Mapping
  </button>
  <button hidden id="delete-feature" class="btn btn-default" style="position: absolute; z-index: 5000; top: 70; right:20; height:40; border-radius: 10px;background-color : red; color : white;">
    Delete Feature
  </button>

</div>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet.js"></script>
<link rel="stylesheet" href="${request.static_url('osmtm:static/js/lib/Leaflet.draw/dist/leaflet.draw.css')}"/>
<script src="${request.static_url('osmtm:static/js/lib/Leaflet.draw/dist/leaflet.draw.js')}"></script>
<script src="${request.static_url('osmtm:static/js/lib/Leaflet.Editable.js')}"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<script>
  var task_bounds = [[${bounds[1]}, ${bounds[0]}], [${bounds[3]}, ${bounds[2]}]];
  var map = L.map('map', {editable : true, scrollWheelZoom : false})
  map.fitBounds(task_bounds)
  L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {maxZoom: 18}).addTo(map);
  L.rectangle(task_bounds, {color: "#ff7800", fillOpacity : 0, weight: 1}).addTo(map);

  var polygons = {};
  var nextID = 0;
  var selectedPolygon = null;

  L.EditControl = L.Control.extend({
    options: {
      position: 'topleft',
      callback: null,
      kind: '',
      html: ''
    },
    onAdd: function (map) {
      var container = L.DomUtil.create('div', 'leaflet-control leaflet-bar');
      var link = L.DomUtil.create('a', '', container);
      link.href = '#';
      link.title = 'Create a new ' + this.options.kind;
      link.innerHTML = this.options.html;
      L.DomEvent.on(link, 'click', L.DomEvent.stop)
                .on(link, 'click', function () {
                  window.LAYER = this.options.callback.call(map.editTools);
                }, this);
      return container;
    }
  })
  L.NewPolygonControl = L.EditControl.extend({
    options: {
      position: 'topleft',
      callback: map.editTools.startPolygon,
      kind: 'polygon',
      html: '⬠'
    }
  });

  map.addControl(new L.NewPolygonControl())

  function _disableClickPropagation(element, polygon) {
    if (!L.Browser.touch || L.Browser.ie) {
      L.DomEvent.disableClickPropagation(element);
      L.DomEvent.on(element, 'mousewheel', L.DomEvent.stopPropagation);
    } else {
      L.DomEvent.on(element, 'click', function(e){
        selectedPolygon = polygon;
        $("#delete-feature").removeAttr("hidden");
        L.DomEvent.stopPropagation(e)
      });
    }
  }

  $("#delete-feature").click(function(e){
    delete polygons[selectedPolygon.id]
    map.removeLayer(selectedPolygon)
  })

  map.on('editable:drawing:end', e => {
    const polygon = e.layer;
    polygon.id = nextID;
    polygons[nextID] = polygon;
    nextID++;
    _disableClickPropagation(polygon.getElement(), polygon)
  })

  map.on('click', function(event){
    $("#delete-feature").attr('hidden', "true")
    selectedPolygon = null;
  })

  $(document).ready(function(){
    $("#done-mapping").click(function(e){
      e.preventDefault();
      e.stopPropagation();

      features = Object.keys(polygons).map(k => polygons[k].toGeoJSON());
      $.ajax({
        type : 'POST',
        url : "${request.route_path('features', task=task.id, project=task.project_id, user=user.id)}",
        data : JSON.stringify({features : features}),
        contentType: "application/json; charset=utf-8",
        dataType : "json",
        success : function(){
          console.log('Done posting!')
        }
      })
    })
  })

</script>

<p></p>
