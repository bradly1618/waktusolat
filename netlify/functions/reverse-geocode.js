exports.handler = async function handler(event) {
  const lat = event.queryStringParameters?.lat;
  const lon = event.queryStringParameters?.lon;

  if (!lat || !lon) {
    return jsonResponse(400, { error: "Missing lat or lon parameter." });
  }

  const endpoint = new URL("https://nominatim.openstreetmap.org/reverse");
  endpoint.searchParams.set("format", "jsonv2");
  endpoint.searchParams.set("lat", lat);
  endpoint.searchParams.set("lon", lon);
  endpoint.searchParams.set("addressdetails", "1");
  endpoint.searchParams.set("zoom", "10");

  try {
    const response = await fetch(endpoint, {
      headers: {
        Accept: "application/json",
        "User-Agent": "WaktuSolatNetlifyDemo/1.0 (Netlify reverse geocoder)",
      },
    });

    if (!response.ok) {
      return jsonResponse(response.status, { error: "Reverse geocoding request failed." });
    }

    const data = await response.json();
    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Cache-Control": "public, max-age=86400",
      },
      body: JSON.stringify(data),
    };
  } catch (error) {
    return jsonResponse(500, { error: "Unable to reverse geocode coordinates.", detail: error.message });
  }
};

function jsonResponse(statusCode, body) {
  return {
    statusCode,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  };
}
