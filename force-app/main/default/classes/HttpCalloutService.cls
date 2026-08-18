public with sharing class HttpCalloutService {
    // Envia uma requisição HTTP genérica e devolve a resposta.
    public static HttpResponse send(String endpoint, String method, String body, Map<String, String> headers) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);

        // Cabeçalhos são opcionais.
        if (headers != null) {
            for (String key : headers.keySet()) {
                req.setHeader(key, headers.get(key));
            }
        }

        // Só envia corpo quando existe conteúdo.
        if (String.isNotBlank(body)) {
            req.setBody(body);
        }

        req.setTimeout(120000);
        return new Http().send(req);
    }

    // Atalho para GET.
    public static HttpResponse get(String endpoint) {
        return send(endpoint, 'GET', null, null);
    }

    // Atalho para POST com corpo JSON.
    public static HttpResponse postJson(String endpoint, String jsonBody) {
        return send(endpoint, 'POST', jsonBody, new Map<String, String>{ 'Content-Type' => 'application/json' });
    }
}
