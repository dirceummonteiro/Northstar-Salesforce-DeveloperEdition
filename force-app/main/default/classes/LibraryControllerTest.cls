/**
 * Covers the Lightning entry point: result mapping, the blank-term fallback to
 * recommendations, and the error path surfaced as an AuraHandledException.
 */
@IsTest
private class LibraryControllerTest {
    private static final String SEARCH_BODY =
        '{"numFound":1,"docs":[' +
        '{"key":"/works/OL27482W","title":"The Hobbit","author_name":["J.R.R. Tolkien"],' +
        '"first_publish_year":1937,"cover_i":14627509,"edition_count":481}' +
        ']}';

    private static final String TRENDING_BODY =
        '{"works":[' +
        '{"key":"/works/OL17930368W","title":"Atomic Habits","author_name":["James Clear"],' +
        '"first_publish_year":2016,"cover_i":12539702,"edition_count":41}' +
        ']}';

    @IsTest
    static void searchBooksReturnsResultsForATerm() {
        CalloutMock mock = mockWith(200, SEARCH_BODY);

        Test.startTest();
        List<LibraryBook> books = LibraryController.searchBooks('the hobbit');
        Test.stopTest();

        Assert.areEqual(1, books.size(), 'The single doc should be returned.');
        Assert.areEqual('OL27482W', books[0].workId, 'The work id should reach the component.');
        Assert.areEqual('The Hobbit', books[0].title, 'The title should reach the component.');
        Assert.isTrue(
            mock.capturedEndpoint.contains('search.json'),
            'A non-blank term should hit the search endpoint.'
        );
        Assert.isTrue(
            mock.capturedEndpoint.contains('limit=24'),
            'The controller should apply the default page size of 24.'
        );
    }

    @IsTest
    static void searchBooksWithABlankTermReturnsRecommendations() {
        CalloutMock mock = mockWith(200, TRENDING_BODY);

        Test.startTest();
        List<LibraryBook> books = LibraryController.searchBooks('   ');
        Test.stopTest();

        Assert.areEqual(1, books.size(), 'A blank term should still return content.');
        Assert.areEqual(
            'OL17930368W',
            books[0].workId,
            'A blank term should fall back to the recommendations.'
        );
        Assert.isTrue(
            mock.capturedEndpoint.contains('trending/daily.json'),
            'A blank term should hit the trending endpoint.'
        );
    }

    @IsTest
    static void searchBooksWithANullTermReturnsRecommendations() {
        CalloutMock mock = mockWith(200, TRENDING_BODY);

        Test.startTest();
        List<LibraryBook> books = LibraryController.searchBooks(null);
        Test.stopTest();

        Assert.areEqual(1, books.size(), 'A null term should still return content.');
        Assert.isTrue(
            mock.capturedEndpoint.contains('trending/daily.json'),
            'A null term should hit the trending endpoint.'
        );
    }

    @IsTest
    static void getRecommendationsReturnsResults() {
        CalloutMock mock = mockWith(200, TRENDING_BODY);

        Test.startTest();
        List<LibraryBook> books = LibraryController.getRecommendations();
        Test.stopTest();

        Assert.areEqual(1, books.size(), 'The single trending work should be returned.');
        Assert.areEqual('Atomic Habits', books[0].title, 'The title should reach the component.');
        Assert.areEqual(
            'https://covers.openlibrary.org/b/id/12539702-M.jpg',
            books[0].coverUrl,
            'The cover URL should reach the component ready to render.'
        );
        Assert.isTrue(
            mock.capturedEndpoint.contains('limit=24'),
            'The controller should apply the default page size of 24.'
        );
    }

    @IsTest
    static void searchBooksSurfacesApiFailuresAsAuraHandledException() {
        mockWith(500, '{"error":"internal"}');

        Test.startTest();
        try {
            LibraryController.searchBooks('the hobbit');
            Assert.fail('A failing callout should raise an AuraHandledException.');
        } catch (AuraHandledException expected) {
            Assert.isTrue(
                expected.getMessage().contains('500'),
                'The status code should reach the component, got: ' + expected.getMessage()
            );
            Assert.isTrue(
                expected.getMessage().contains('Open Library'),
                'The user facing message should be preserved, got: ' + expected.getMessage()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void getRecommendationsSurfacesApiFailuresAsAuraHandledException() {
        mockWith(502, '');

        Test.startTest();
        try {
            LibraryController.getRecommendations();
            Assert.fail('A failing callout should raise an AuraHandledException.');
        } catch (AuraHandledException expected) {
            Assert.isTrue(
                expected.getMessage().contains('502'),
                'The status code should reach the component, got: ' + expected.getMessage()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unusableResponsesReachTheComponentAsAnEmptyList() {
        mockWith(200, 'not json');

        Test.startTest();
        List<LibraryBook> books = LibraryController.searchBooks('the hobbit');
        Test.stopTest();

        Assert.areEqual(
            0,
            books.size(),
            'An unreadable body should render an empty state, not an error.'
        );
    }

    private static CalloutMock mockWith(Integer statusCode, String body) {
        CalloutMock mock = new CalloutMock(statusCode, body);
        Test.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    private class CalloutMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;
        public String capturedEndpoint;

        private CalloutMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest request) {
            this.capturedEndpoint = request.getEndpoint();
            HttpResponse response = new HttpResponse();
            response.setStatusCode(this.statusCode);
            response.setStatus(this.statusCode == 200 ? 'OK' : 'Error');
            response.setHeader('Content-Type', 'application/json');
            response.setBody(this.body);
            return response;
        }
    }
}
