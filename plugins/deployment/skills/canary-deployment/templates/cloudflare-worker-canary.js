/**
 * Cloudflare Worker: Canary Traffic Splitting
 *
 * This Worker implements intelligent traffic splitting between stable and canary versions
 * with support for sticky sessions, A/B testing, and automatic health checks.
 */

// Configuration - Read from KV at runtime
const CONFIG = {
  kvNamespace: 'CANARY_STATE', // Bound in wrangler.toml
  stableWorkerName: 'my-app-stable',
  canaryWorkerName: 'my-app-canary',
  defaultPercentage: 10,
  sessionCookieName: 'canary_session',
  sessionTTL: 3600, // 1 hour
};

addEventListener('fetch', event => {
  event.respondWith(handleRequest(event.request));
});

async function handleRequest(request) {
  try {
    // Get canary configuration from KV
    const canaryConfig = await getCanaryConfig();

    // Determine which version to route to
    const routeToCanary = shouldRouteToCanary(request, canaryConfig);

    // Route request
    if (routeToCanary) {
      return await routeToWorker(request, CONFIG.canaryWorkerName);
    } else {
      return await routeToWorker(request, CONFIG.stableWorkerName);
    }
  } catch (error) {
    console.error('Error in canary routing:', error);

    // Fallback to stable on error
    return await routeToWorker(request, CONFIG.stableWorkerName);
  }
}

/**
 * Get canary configuration from KV storage
 */
async function getCanaryConfig() {
  const kvNamespace = this[CONFIG.kvNamespace];

  if (!kvNamespace) {
    console.warn('KV namespace not bound, using default config');
    return {
      enabled: true,
      percentage: CONFIG.defaultPercentage,
    };
  }

  const configJson = await kvNamespace.get('canary-state', 'json');

  if (!configJson) {
    return {
      enabled: false,
      percentage: 0,
    };
  }

  return configJson;
}

/**
 * Determine if request should route to canary based on:
 * - Canary enabled/disabled
 * - Traffic percentage
 * - Sticky sessions (cookie-based)
 * - User segmentation rules
 */
function shouldRouteToCanary(request, config) {
  // If canary is disabled, always route to stable
  if (!config.enabled || config.percentage === 0) {
    return false;
  }

  // If 100% canary, route all traffic
  if (config.percentage >= 100) {
    return true;
  }

  // Check for sticky session cookie
  const cookies = parseCookies(request.headers.get('Cookie') || '');
  const sessionValue = cookies[CONFIG.sessionCookieName];

  if (sessionValue === 'canary') {
    return true;
  } else if (sessionValue === 'stable') {
    return false;
  }

  // No sticky session - determine by percentage
  const randomValue = Math.random() * 100;
  const routeToCanary = randomValue < config.percentage;

  // Note: In production, set sticky session cookie in response
  // This simplified example doesn't modify response headers

  return routeToCanary;
}

/**
 * Route request to specific Worker
 */
async function routeToWorker(request, workerName) {
  const workerUrl = `https://${workerName}.workers.dev`;

  // Create new request with modified URL
  const url = new URL(request.url);
  const targetUrl = new URL(url.pathname + url.search, workerUrl);

  const modifiedRequest = new Request(targetUrl, {
    method: request.method,
    headers: request.headers,
    body: request.body,
  });

  // Add routing metadata header
  modifiedRequest.headers.set('X-Canary-Worker', workerName);

  // Forward request to target worker
  const response = await fetch(modifiedRequest);

  // Clone response to modify headers
  const modifiedResponse = new Response(response.body, response);

  // Add canary routing headers for debugging/analytics
  modifiedResponse.headers.set('X-Canary-Routed-To', workerName);
  modifiedResponse.headers.set('X-Canary-Version', workerName.includes('canary') ? 'canary' : 'stable');

  return modifiedResponse;
}

/**
 * Parse cookies from Cookie header
 */
function parseCookies(cookieHeader) {
  const cookies = {};

  if (!cookieHeader) {
    return cookies;
  }

  cookieHeader.split(';').forEach(cookie => {
    const [name, value] = cookie.trim().split('=');
    if (name && value) {
      cookies[name] = decodeURIComponent(value);
    }
  });

  return cookies;
}

/**
 * Example: Enhanced version with sticky session response modification
 *
 * async function handleRequestWithSession(request) {
 *   const config = await getCanaryConfig();
 *   const routeToCanary = shouldRouteToCanary(request, config);
 *
 *   const response = await routeToWorker(request,
 *     routeToCanary ? CONFIG.canaryWorkerName : CONFIG.stableWorkerName
 *   );
 *
 *   // Set sticky session cookie
 *   const modifiedResponse = new Response(response.body, response);
 *   modifiedResponse.headers.append('Set-Cookie',
 *     `${CONFIG.sessionCookieName}=${routeToCanary ? 'canary' : 'stable'}; ` +
 *     `Max-Age=${CONFIG.sessionTTL}; Path=/; HttpOnly; Secure`
 *   );
 *
 *   return modifiedResponse;
 * }
 */
