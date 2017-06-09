# -*- coding: utf-8 -*-
<%
from geoalchemy2 import shape
geometry_as_shape = shape.to_shape(task.geometry)
bounds = geometry_as_shape.bounds
project = task.project
%>
<div id='map' style="position: absolute; top:0;left: 0; right: 0; bottom: 0">

</div>

<link rel="stylesheet" href="https://unpkg.com/leaflet@1.0.3/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.0.3/dist/leaflet.js"></script>
<link rel="stylesheet" href="${request.static_url('osmtm:static/js/lib/Leaflet.draw/dist/leaflet.draw.css')}"/>
<script src="${request.static_url('osmtm:static/js/lib/Leaflet.draw/dist/leaflet.draw.js')}"></script>
<script src="${request.static_url('osmtm:static/js/lib/Leaflet.Editable.js')}"></script>

<script>
  console.log(L)
  var task_bounds = [[${bounds[1]}, ${bounds[0]}], [${bounds[3]}, ${bounds[2]}]];
  var map = L.map('map', {editable : true, scrollWheelZoom : false})
  map.fitBounds(task_bounds)
  L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {maxZoom: 18}).addTo(map);
  L.rectangle(task_bounds, {color: "#ff7800", fillOpacity : 0, weight: 1}).addTo(map);

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

  map.on('editable:drawing:end', e => {
    const polygon = e.layer.toGeoJSON()
    console.log('Done with polygon')
    console.log(polygon)
  })


</script>

<p></p>
