// = require leaflet
// = require leaflet-tilelayer-here
// = require leaflet-svg-icon
// = require leaflet.markercluster
// = require jquery-tmpl
// = require_self

L.DivIcon.SVGIcon.DecidimIcon = L.DivIcon.SVGIcon.extend({
  options: {
    fillColor: "#009246",
    opacity: 0,
    iconSize: L.point(40,58),
  },
  _createPathDescription: function() {
    return "M 20.826882,1.1699996 A 18.511882,19.428915 0 0 0 2.315,20.598915 c 0,18.705632 16.206808,34.268718 16.895954,34.917181 a 2.3763648,2.4940842 0 0 0 3.208092,0 C 23.108192,54.79281 39.315,39.204785 39.315,20.598915 A 18.511882,19.428915 0 0 0 20.826882,1.1699996 Z m 0,28.9563174 a 8.0558767,8.4549456 0 1 1 8.055877,-8.454945 8.0558767,8.4549456 0 0 1 -8.055877,8.454945 z";
  },
  _createCircle: function() {
    return ""
  }
});

const popupTemplateId = "marker-popup";
$.template(popupTemplateId, $(`#${popupTemplateId}`).html());

const addMarkers = (markersData, markerClusters, map) => {
  const bounds = new L.LatLngBounds(markersData.map((markerData) => [markerData.latitude, markerData.longitude]));

  markersData.forEach((markerData) => {
    let marker = L.marker([markerData.latitude, markerData.longitude], {
      icon: new L.DivIcon.SVGIcon.DecidimIcon()
    });
    let node = document.createElement("div");

    $.tmpl(popupTemplateId, markerData).appendTo(node);

    marker.bindPopup(node, {
      maxwidth: 640,
      minWidth: 500,
      keepInView: true,
      className: "map-info"
    }).openPopup();

    markerClusters.addLayer(marker);
  });

  map.addLayer(markerClusters);
  map.fitBounds(bounds, { padding: [100, 100] });
};

const loadMap = (mapId, markersData) => {
  let markerClusters = L.markerClusterGroup();
  const { hereAppId, hereAppCode } = window.Decidim.mapConfiguration;

  if (window.Decidim.currentMap) {
    window.Decidim.currentMap.remove();
    window.Decidim.currentMap = null;
  }

  const map = L.map(mapId);

  L.tileLayer.here({
    appId: hereAppId,
    appCode: hereAppCode
  }).addTo(map);

  if (markersData.length > 0) {
    addMarkers(markersData, markerClusters, map);
  } else {
    map.fitWorld();
  }

  map.scrollWheelZoom.disable();

  return map;
};

window.Decidim = window.Decidim || {};

window.Decidim.loadMap = loadMap;
window.Decidim.currentMap =  null;
window.Decidim.mapConfiguration = {};

$(() => {
  const mapId = "map";
  const $map = $(`#${mapId}`);

  const markersData = $map.data("markers-data");
  const hereAppId = $map.data("here-app-id");
  const hereAppCode = $map.data("here-app-code");

  window.Decidim.mapConfiguration = { hereAppId, hereAppCode };

  if ($map.length > 0) {
    window.Decidim.currentMap = loadMap(mapId, markersData);
  }
});
