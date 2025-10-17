export interface Env {
  ASSETS: {
    fetch: (request: Request) => Promise<Response>;
  };
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    try {
      const assetResponse = await env.ASSETS.fetch(request);

      if (
        assetResponse.status === 404 &&
        request.method === 'GET' &&
        (request.headers.get('accept') ?? '').includes('text/html')
      ) {
        const fallback = await env.ASSETS.fetch(
          new Request(`${url.origin}/index.html`, request),
        );
        if (fallback.status < 400) {
          return fallback;
        }
      }

      return assetResponse;
    } catch (error) {
      return new Response(
        JSON.stringify({
          error: 'Asset fetch failed',
          message: error instanceof Error ? error.message : String(error),
        }),
        {
          status: 500,
          headers: { 'content-type': 'application/json' },
        },
      );
    }
  },
};
