export default {
    async fetch(request, env) {
        let url = new URL(request.url);
        
        // Chỉ proxy khi path kết thúc bằng .zip
        if (url.pathname.endsWith('.zip')) {
            let targetUrl = new URL(`https://github.com/bibicadotnet/microsoft-edge-multi-portable/releases/download${url.pathname}${url.search}`);
            
            let newRequest = new Request(targetUrl, {
                method: request.method,
                headers: request.headers,
                body: request.body
            });
            
            return fetch(newRequest);
        }
        
        // Tất cả path khác serve từ Cloudflare Pages
        return env.ASSETS.fetch(request);
    }
};
