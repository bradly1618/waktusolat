exports.handler = async function handler(event) {
  const zone = (event.queryStringParameters?.zone || "").toUpperCase();

  if (!zone) {
    return jsonResponse(400, { error: "Missing zone parameter." });
  }

  const endpoint = `https://www.e-solat.gov.my/index.php?r=esolatApi/takwimsolat&zone=${encodeURIComponent(zone)}&period=today`;

  try {
    const response = await fetch(endpoint, {
      headers: {
        Accept: "application/json",
        "User-Agent": "WaktuSolatNetlifyDemo/1.0",
      },
    });

    if (!response.ok) {
      return jsonResponse(response.status, { error: "JAKIM request failed." });
    }

    const data = await response.json();
    return {
      statusCode: 200,
      headers: {
        "Content-Type": "application/json",
        "Cache-Control": "public, max-age=300",
      },
      body: JSON.stringify(data),
    };
  } catch (error) {
    return jsonResponse(500, { error: "Unable to reach JAKIM.", detail: error.message });
  }
};

function jsonResponse(statusCode, body) {
  return {
    statusCode,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  };
}
