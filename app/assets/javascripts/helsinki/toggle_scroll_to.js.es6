(($, Decidim, window) => {
  const toggleScrollTo = ($self) => {
    $self.on('click', (ev) => {
      ev.preventDefault();

      $self.toggleClass('showing-map');

      if ($self.is('.showing-map')) {
        const $target = $('#' + $self.data('toggle'));

        // Wait for the element to appear
        setTimeout(() => {
          // Make sure leaflet is properly loaded
          const $map = $('#map', $target);
          if ($map.length > 0 && Decidim.currentMap) {
            // See:
            // https://leafletjs.com/reference-1.3.4.html#map-invalidatesize
            Decidim.currentMap.invalidateSize(false);

            const markersData = $map.data("markers-data");

            if (markersData.length == 1) {
              // Center to the marker with a sensible default zoom level
              const marker = markersData[0];
              Decidim.currentMap.setView([marker.latitude, marker.longitude], 12);
            } else {
              // Re-center the map as done in `decidim/map.js.es6`
              let bounds = null;
              if (markersData.length > 0) {
                bounds = new window.L.LatLngBounds(markersData.map(
                  (markerData) => [markerData.latitude, markerData.longitude]
                ));
              } else {
                // In case no markers are available, center Helsiki city bounds
                bounds = new window.L.LatLngBounds([
                  [60.142327,24.854767],
                  [60.142327,24.854081],
                  [60.214377,25.147842],
                  [60.214377,25.147842]
                ]);
              }
              Decidim.currentMap.fitBounds(bounds, { padding: [100, 100] });
            }
          }

          // Scroll to the element
          $target.scrollTo();
        }, 100);
      }
    });
  };

  $(() => {
    $('[data-toggle-scrollto]').each((i, el) => {
      toggleScrollTo($(el));
    });
  });
})(jQuery, window.Decidim, window);
