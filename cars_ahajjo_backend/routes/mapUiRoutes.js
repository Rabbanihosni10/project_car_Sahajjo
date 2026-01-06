const express = require('express');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

router.get('/', authenticateToken, (req, res) => {
  const userRole = req.user.role || 'visitor';
  
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.send(`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Car Sahajjo - Interactive Map</title>
  <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBxNVXGr6cHB4YCVC9KxsKzPPVWfXtfzP8&libraries=places,geometry"></script>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; background: #f3f4f6; }
    .container { display: flex; height: 100vh; }
    #map { flex: 1; }
    .sidebar { width: 320px; background: #fff; border-left: 1px solid #e5e7eb; overflow-y: auto; }
    .panel { padding: 16px; }
    .panel h3 { margin: 12px 0 8px; font-size: 14px; color: #111827; }
    .toggle-btn { width: 100%; padding: 8px; margin: 4px 0; background: #f3f4f6; border: 1px solid #d1d5db; border-radius: 6px; cursor: pointer; font-size: 13px; }
    .toggle-btn.active { background: #111827; color: #fff; }
    .list-item { padding: 10px; margin: 4px 0; background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 6px; font-size: 12px; }
    .list-item .name { font-weight: 600; color: #111827; }
    .list-item .info { color: #6b7280; font-size: 11px; margin-top: 4px; }
    .legend { padding: 8px; background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 6px; font-size: 11px; margin: 8px 0; }
    .badge { display: inline-block; padding: 2px 6px; border-radius: 4px; font-size: 10px; margin-right: 4px; }
    .badge.heavy { background: #fecaca; color: #991b1b; }
    .badge.moderate { background: #fed7aa; color: #92400e; }
    .badge.light { background: #bbf7d0; color: #065f46; }
  </style>
</head>
<body>
  <div class="container">
    <div id="map"></div>
    <div class="sidebar">
      <div class="panel">
        <h3>User Location</h3>
        <div id="userLocation" class="list-item">Loading...</div>
        
        <h3>Map Layers</h3>
        <button class="toggle-btn active" id="toggleGarages">🏢 Garages</button>
        <button class="toggle-btn" id="toggleTraffic">🚦 Traffic</button>
        ${userRole === 'driver' ? '<button class="toggle-btn" id="toggleRoute">🛣️ Route Directions</button>' : ''}
        ${userRole === 'owner' ? '<button class="toggle-btn" id="toggleDrivers">🚗 Driver Locations</button>' : ''}
        
        <h3 id="garagesTitle">Nearby Garages</h3>
        <div id="garagesList"></div>
        
        <h3 id="trafficTitle" style="display:none;">Traffic Conditions</h3>
        <div id="trafficList"></div>
        
        ${userRole === 'driver' ? '<h3 id="routeTitle" style="display:none;">Route Info</h3><div id="routeInfo" style="display:none;"></div>' : ''}
        ${userRole === 'owner' ? '<h3 id="driversTitle" style="display:none;">Nearby Drivers</h3><div id="driversList"></div>' : ''}
      </div>
    </div>
  </div>

  <script>
    let map;
    let userLocation = { lat: 23.8103, lng: 90.4125 };
    let userMarker;
    let garageMarkers = [];
    let trafficMarkers = [];
    let driverMarkers = [];
    let routePath = null;
    let userRole = '${userRole}';

    function initMap() {
      map = new google.maps.Map(document.getElementById('map'), {
        zoom: 13,
        center: userLocation,
        styles: [
          { featureType: 'water', elementType: 'geometry', stylers: [{ color: '#e9e9e9' }, { lightness: 17 }] },
          { featureType: 'road.highway', elementType: 'geometry.fill', stylers: [{ color: '#f7f7f7' }, { lightness: 17 }] },
        ]
      });

      loadUserLocation();
      loadNearbyGarages();
      
      // Event listeners for toggles
      document.getElementById('toggleGarages').addEventListener('click', toggleGarages);
      document.getElementById('toggleTraffic').addEventListener('click', toggleTraffic);
      
      if (userRole === 'driver') {
        document.getElementById('toggleRoute').addEventListener('click', toggleRoute);
      }
      if (userRole === 'owner') {
        document.getElementById('toggleDrivers').addEventListener('click', toggleDrivers);
      }
    }

    async function loadUserLocation() {
      try {
        const res = await fetch('/api/map/my-location', {
          headers: { Authorization: 'Bearer ' + localStorage.getItem('token') }
        });
        const data = await res.json();
        if (data.success) {
          const user = data.data;
          userLocation = { lat: user.latitude, lng: user.longitude };
          map.setCenter(userLocation);
          
          // Add user marker
          userMarker = new google.maps.Marker({
            position: userLocation,
            map: map,
            title: user.name,
            icon: 'http://maps.google.com/mapfiles/ms/icons/blue-dot.png'
          });

          document.getElementById('userLocation').innerHTML = \`
            <div class="name">\${user.name}</div>
            <div class="info">Role: \${user.role}</div>
            <div class="info">Lat: \${user.latitude.toFixed(4)}, Lng: \${user.longitude.toFixed(4)}</div>
          \`;
        }
      } catch (e) {
        console.error('Error loading user location:', e);
      }
    }

    async function loadNearbyGarages() {
      try {
        const res = await fetch(\`/api/map/nearby-garages?lat=\${userLocation.lat}&lng=\${userLocation.lng}&radiusKm=5\`, {
          headers: { Authorization: 'Bearer ' + localStorage.getItem('token') }
        });
        const data = await res.json();
        if (data.success) {
          const list = document.getElementById('garagesList');
          list.innerHTML = '';
          data.garages.forEach((garage, i) => {
            // Add marker
            const marker = new google.maps.Marker({
              position: { lat: garage.latitude, lng: garage.longitude },
              map: map,
              title: garage.name,
              icon: 'http://maps.google.com/mapfiles/ms/icons/red-dot.png'
            });
            garageMarkers.push(marker);

            // Add to sidebar list
            const item = document.createElement('div');
            item.className = 'list-item';
            item.innerHTML = \`
              <div class="name">\${garage.name}</div>
              <div class="info">⭐ \${garage.rating.toFixed(1)} | \${garage.distanceKm} km away</div>
              <div class="info">📍 \${garage.address}</div>
              <div class="info">📞 \${garage.phone}</div>
            \`;
            list.appendChild(item);
          });
        }
      } catch (e) {
        console.error('Error loading garages:', e);
      }
    }

    async function loadTraffic() {
      try {
        const res = await fetch(\`/api/map/traffic?lat=\${userLocation.lat}&lng=\${userLocation.lng}\`, {
          headers: { Authorization: 'Bearer ' + localStorage.getItem('token') }
        });
        const data = await res.json();
        if (data.success) {
          const list = document.getElementById('trafficList');
          list.innerHTML = '';
          data.traffic.forEach(area => {
            const item = document.createElement('div');
            item.className = 'list-item';
            item.innerHTML = \`
              <span class="badge \${area.level}">\${area.level.toUpperCase()}</span>
              <strong>\${area.area}</strong><br/>
              <div class="info">Vehicles: \${area.vehicles} | Speed: Check legend</div>
            \`;
            list.appendChild(item);
          });
        }
      } catch (e) {
        console.error('Error loading traffic:', e);
      }
    }

    async function loadDrivers() {
      try {
        const res = await fetch(\`/api/map/driver-locations?ownerLat=\${userLocation.lat}&ownerLng=\${userLocation.lng}\`, {
          headers: { Authorization: 'Bearer ' + localStorage.getItem('token') }
        });
        const data = await res.json();
        if (data.success) {
          const list = document.getElementById('driversList');
          list.innerHTML = '';
          data.drivers.forEach(driver => {
            // Add marker
            const marker = new google.maps.Marker({
              position: { lat: driver.latitude, lng: driver.longitude },
              map: map,
              title: driver.driverName,
              icon: 'http://maps.google.com/mapfiles/ms/icons/yellow-dot.png'
            });
            driverMarkers.push(marker);

            // Add to sidebar
            const item = document.createElement('div');
            item.className = 'list-item';
            item.innerHTML = \`
              <div class="name">\${driver.driverName}</div>
              <div class="info">Vehicle: \${driver.vehicle}</div>
              <div class="info">Status: <span class="badge">\${driver.status}</span></div>
              <div class="info">⭐ \${driver.rating} | \${driver.distanceKm} km away</div>
            \`;
            list.appendChild(item);
          });
        }
      } catch (e) {
        console.error('Error loading drivers:', e);
      }
    }

    async function loadRouteDirections() {
      const destination = prompt('Enter destination (lat,lng) or use default nearby location');
      const [destLat, destLng] = destination ? destination.split(',').map(Number) : [23.82, 90.42];
      
      try {
        const res = await fetch('/api/map/route-directions', {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            Authorization: 'Bearer ' + localStorage.getItem('token')
          },
          body: JSON.stringify({ startLat: userLocation.lat, startLng: userLocation.lng, endLat: destLat, endLng: destLng })
        });
        const data = await res.json();
        if (data.success) {
          const route = data.route;
          
          // Draw route on map
          const waypoints = route.waypoints.map(w => new google.maps.LatLng(w.lat, w.lng));
          routePath = new google.maps.Polyline({
            path: waypoints,
            geodesic: true,
            strokeColor: '#4f46e5',
            strokeOpacity: 0.8,
            strokeWeight: 3,
            map: map
          });

          // Show route info
          const info = document.getElementById('routeInfo');
          info.style.display = 'block';
          document.getElementById('routeTitle').style.display = 'block';
          info.innerHTML = \`
            <div class="list-item">
              <div class="name">Route Details</div>
              <div class="info">📏 Distance: \${route.distanceKm} km</div>
              <div class="info">⏱️ Duration: \${route.durationMinutes} mins</div>
              <div class="info">🚦 Traffic Delay: \${route.trafficDelay} mins</div>
              <div class="info">🕐 Arrival: \${new Date(route.estimatedArrival).toLocaleTimeString()}</div>
            </div>
          \`;
        }
      } catch (e) {
        console.error('Error loading route:', e);
      }
    }

    function toggleGarages() {
      const btn = document.getElementById('toggleGarages');
      const list = document.getElementById('garagesList');
      const title = document.getElementById('garagesTitle');
      
      btn.classList.toggle('active');
      list.style.display = list.style.display === 'none' ? 'block' : 'none';
      title.style.display = title.style.display === 'none' ? 'block' : 'none';
      garageMarkers.forEach(m => m.setVisible(!m.getVisible()));
    }

    function toggleTraffic() {
      const btn = document.getElementById('toggleTraffic');
      const list = document.getElementById('trafficList');
      const title = document.getElementById('trafficTitle');
      
      btn.classList.toggle('active');
      if (btn.classList.contains('active')) {
        loadTraffic();
        list.style.display = 'block';
        title.style.display = 'block';
      } else {
        list.style.display = 'none';
        title.style.display = 'none';
      }
    }

    function toggleRoute() {
      const btn = document.getElementById('toggleRoute');
      btn.classList.toggle('active');
      if (btn.classList.contains('active')) {
        loadRouteDirections();
      } else {
        if (routePath) routePath.setMap(null);
        document.getElementById('routeInfo').style.display = 'none';
        document.getElementById('routeTitle').style.display = 'none';
      }
    }

    function toggleDrivers() {
      const btn = document.getElementById('toggleDrivers');
      const list = document.getElementById('driversList');
      const title = document.getElementById('driversTitle');
      
      btn.classList.toggle('active');
      if (btn.classList.contains('active')) {
        loadDrivers();
        list.style.display = 'block';
        title.style.display = 'block';
      } else {
        list.style.display = 'none';
        title.style.display = 'none';
        driverMarkers.forEach(m => m.setMap(null));
        driverMarkers = [];
      }
    }

    // Initialize map on load
    window.addEventListener('load', initMap);
  </script>
</body>
</html>
  `);
});

module.exports = router;
