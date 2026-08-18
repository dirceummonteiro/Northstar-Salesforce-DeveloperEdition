@isTest
private class HttpCalloutServiceTest {
    // Mock configurável de resposta HTTP.
    private class MockResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String body;

        private MockResponse(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }

    @isTest
    static void testGet() {
        Test.setMock(HttpCalloutMock.class, new MockResponse(200, '{"ok":true}'));
        Test.startTest();
        HttpResponse res = HttpCalloutService.get('https://example.com/api');
        Test.stopTest();
        System.assertEquals(200, res.getStatusCode(), 'GET deveria retornar 200');
        System.assertEquals('{"ok":true}', res.getBody(), 'Body inesperado no GET');
    }

    @isTest
    static void testPostJson() {
        Test.setMock(HttpCalloutMock.class, new MockResponse(201, '{"id":"1"}'));
        Test.startTest();
        HttpResponse res = HttpCalloutService.postJson('https://example.com/api', '{"name":"x"}');
        Test.stopTest();
        System.assertEquals(201, res.getStatusCode(), 'POST deveria retornar 201');
    }

    @isTest
    static void testSendSemHeadersNemBody() {
        // Exercita os ramos "headers == null" e "body em branco".
        Test.setMock(HttpCalloutMock.class, new MockResponse(204, ''));
        Test.startTest();
        HttpResponse res = HttpCalloutService.send('https://example.com/api', 'DELETE', null, null);
        Test.stopTest();
        System.assertEquals(204, res.getStatusCode(), 'DELETE deveria retornar 204');
    }
}
