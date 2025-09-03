export async function onRequest(context) {
  const { request } = context;
  const url = new URL(request.url);
  
  if (url.pathname.endsWith(".zip")) {
    const target = `https://github.com/bibicadotnet/microsoft-edge-multi-portable/releases/download${url.pathname}${url.search}`;
    
    return fetch(target, {
      method: request.method,
      headers: request.headers,
      redirect: "follow",
    });
  }
  
  return new Response("Not found", { status: 404 });
}
