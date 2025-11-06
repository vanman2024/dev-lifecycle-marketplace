/**
 * Next.js Middleware: Canary Traffic Splitting for Vercel
 *
 * This middleware uses Vercel Edge Config to implement canary deployments
 * with traffic splitting, sticky sessions, and A/B testing support.
 *
 * Setup:
 * 1. Create Edge Config: https://vercel.com/dashboard/stores
 * 2. Add EDGE_CONFIG environment variable to your project
 * 3. Deploy this middleware to your Next.js app
 */

import { NextRequest, NextResponse } from 'next/server';
import { get } from '@vercel/edge-config';

// Configuration
const CANARY_COOKIE_NAME = 'vercel_canary_session';
const COOKIE_MAX_AGE = 3600; // 1 hour

/**
 * Middleware function - runs on every request at the edge
 */
export async function middleware(request: NextRequest) {
  try {
    // Get canary configuration from Edge Config
    const canaryConfig = await getCanaryConfig();

    // If canary is disabled, continue to production
    if (!canaryConfig || !canaryConfig.enabled || canaryConfig.percentage === 0) {
      return NextResponse.next();
    }

    // Determine if request should route to canary
    const shouldUseCanary = shouldRouteToCanary(request, canaryConfig);

    if (!shouldUseCanary) {
      return NextResponse.next();
    }

    // Route to canary deployment
    const response = await routeToCanary(request, canaryConfig);

    return response;
  } catch (error) {
    console.error('Canary routing error:', error);

    // Fallback to production on error
    return NextResponse.next();
  }
}

/**
 * Get canary configuration from Vercel Edge Config
 */
async function getCanaryConfig() {
  try {
    const config = await get<CanaryConfig>('canary');

    if (!config) {
      console.warn('No canary config found in Edge Config');
      return null;
    }

    return config;
  } catch (error) {
    console.error('Error fetching Edge Config:', error);
    return null;
  }
}

/**
 * Determine if request should route to canary
 */
function shouldRouteToCanary(request: NextRequest, config: CanaryConfig): boolean {
  // Check for sticky session cookie
  const sessionCookie = request.cookies.get(CANARY_COOKIE_NAME);

  if (sessionCookie?.value === 'canary') {
    return true;
  } else if (sessionCookie?.value === 'stable') {
    return false;
  }

  // No sticky session - use percentage-based routing
  const randomValue = Math.random() * 100;

  return randomValue < config.percentage;
}

/**
 * Route request to canary deployment
 */
async function routeToCanary(request: NextRequest, config: CanaryConfig): Promise<NextResponse> {
  // Rewrite to canary URL
  const url = request.nextUrl.clone();
  url.hostname = new URL(config.canaryUrl).hostname;

  const response = NextResponse.rewrite(url);

  // Set sticky session cookie
  response.cookies.set({
    name: CANARY_COOKIE_NAME,
    value: 'canary',
    maxAge: COOKIE_MAX_AGE,
    httpOnly: true,
    secure: true,
    sameSite: 'lax',
    path: '/',
  });

  // Add debugging headers
  response.headers.set('X-Canary-Version', 'canary');
  response.headers.set('X-Canary-Percentage', String(config.percentage));

  return response;
}

/**
 * Type definition for canary configuration
 */
interface CanaryConfig {
  enabled: boolean;
  percentage: number;
  canaryUrl: string;
  productionUrl: string;
  deployedAt?: string;
  stage?: string;
  features?: {
    stickySession?: boolean;
    geoRouting?: boolean;
    abTesting?: boolean;
  };
}

/**
 * Specify which routes this middleware applies to
 */
export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public files (public folder)
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};

/**
 * Example: Enhanced version with A/B testing support
 *
 * async function shouldRouteToCanaryWithABTesting(
 *   request: NextRequest,
 *   config: CanaryConfig
 * ): Promise<boolean> {
 *   // Check user segment (e.g., beta users)
 *   const userId = request.cookies.get('user_id')?.value;
 *
 *   if (userId && config.features?.abTesting) {
 *     // Route specific users to canary for A/B testing
 *     const userSegment = await getUserSegment(userId);
 *
 *     if (userSegment === 'beta') {
 *       return true;
 *     }
 *   }
 *
 *   // Standard percentage-based routing
 *   return Math.random() * 100 < config.percentage;
 * }
 */

/**
 * Example: Geographic routing support
 *
 * function shouldRouteToCanaryByGeo(
 *   request: NextRequest,
 *   config: CanaryConfig
 * ): boolean {
 *   if (!config.features?.geoRouting) {
 *     return shouldRouteToCanary(request, config);
 *   }
 *
 *   // Get user's country from Vercel geolocation
 *   const country = request.geo?.country;
 *
 *   // Route specific countries to canary first (staged rollout)
 *   const canaryCountries = ['US', 'CA']; // Start with US/Canada
 *
 *   if (country && canaryCountries.includes(country)) {
 *     return Math.random() * 100 < config.percentage;
 *   }
 *
 *   // Other countries stay on stable
 *   return false;
 * }
 */
