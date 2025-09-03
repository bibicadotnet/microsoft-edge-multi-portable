export async function onRequest(context) {
  const { request } = context;
  const url = new URL(request.url);
  
  // Kiểm tra nếu URL kết thúc bằng .zip
  if (url.pathname.endsWith(".zip")) {
    const target = `https://github.com/bibicadotnet/microsoft-edge-multi-portable/releases/download${url.pathname}${url.search}`;
    
    try {
      return await fetch(target, {
        method: request.method,
        headers: request.headers,
        redirect: "follow",
      });
    } catch (error) {
      return new Response(`Error fetching file: ${error.message}`, { 
        status: 500,
        headers: {
          'Content-Type': 'text/plain'
        }
      });
    }
  }
  
  return new Response("Not found", { 
    status: 404,
    headers: {
      'Content-Type': 'text/plain'
    }
  });
}
