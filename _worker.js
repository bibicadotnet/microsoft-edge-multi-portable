export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname.endsWith(".zip") || url.pathname.endsWith(".json")) {
      const target = `https://github.com/bibicadotnet/microsoft-edge-multi-portable/releases/download${url.pathname}${url.search}`;

      return fetch(target, {
        method: request.method,
        headers: request.headers,
        redirect: "follow",
      });
    }

    return env.ASSETS.fetch(request);
  }
};
