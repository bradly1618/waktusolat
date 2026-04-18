exports.handler = async function handler(event) {
  const zone = (event.queryStringParameters?.zone || "").toUpperCase();

  if (!zone) {
    return jsonResponse(400, { error: "Missing zone parameter." });
  }

  return jsonResponse(410, {
    error: "Live prayer-time fetching is disabled for now. The site is using bundled cached data.",
    zone,
  });
};

function jsonResponse(statusCode, body) {
  return {
    statusCode,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  };
}
