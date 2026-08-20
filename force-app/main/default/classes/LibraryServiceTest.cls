/**
 * Covers LibraryService and the LibraryBook wrapper it produces.
 *
 * Every callout is mocked; no test ever reaches the network.
 */
@IsTest
private class LibraryServiceTest {
    private static final String EXPECTED_COVER_BASE = 'https://covers.openlibrary.org';

    private static final String SEARCH_SUCCESS_BODY =
        '{"numFound":2,"docs":[' +
        '{"key":"/works/OL27482W","title":"The Hobbit","author_name":["J.R.R. Tolkien"],' +
        '"first_publish_year":1937,"cover_i":14627509,"edition_count":481},' +
        '{"key":"/works/OL45804W","title":"Fantastic Mr Fox","author_name":["Roald Dahl","Quentin Blake"],' +
        '"first_publish_year":1970,"cover_i":6498519,"edition_count":120}' +
        ']}';

    private static final String TRENDING_SUCCESS_BODY =
        '{"works":[' +
        '{"key":"/works/OL17930368W","title":"Atomic Habits","author_name":["James Clear"],' +
        '"first_publish_year":2016,"cover_i":12539702,"edition_count":41},' +
        '{"key":"/works/OL27482W","title":"The Hobbit","author_name":["J.R.R. Tolkien"],' +
        '"first_publish_year":1937,"cover_i":14627509,"edition_count":481}' +
        ']}';

    // Missing cover_i, missing author_name, missing first_publish_year, missing key,
    // blank author entries and a non-object entry in the collection.
    private static final String PARTIAL_FIELDS_BODY =
        '{"numFound":4,"docs":[' +
        '{"key":"/works/OL1W","title":"No Cover Book","edition_count":3},' +
        '{"key":"/works/OL2W","title":"Blank Authors","author_name":["",null,"Real Name"],' +
        '"cover_i":null,"first_publish_year":null,"edition_count":null},' +
        '{"title":"No Key Book"},' +
        '"this entry is not an object"' +
        ']}';

    // ---------------------------------------------------------------- search

    @IsTest
    static void searchBooksReturnsMappedBooksOnSuccess() {
        CalloutMock mock = mockWith(200, SEARCH_SUCCESS_BODY);

        Test.startTest();
        List<LibraryBook> books = LibraryService.searchBooks('the hobbit', 24);
        Test.stopTest();

        Assert.areEqual(2, books.size(), 'Both docs entries should be mapped.');

        LibraryBook first = books[0];
        Assert.areEqual('OL27482W', first.workId, 'The "/works/" prefix should be stripped.');
        Assert.areEqual('The Hobbit', first.title, 'Title should be mapped as returned.');
        Assert.areEqual('J.R.R. Tolkien', first.authors, 'Single author should be mapped as is.');
        Assert.areEqual(
            EXPECTED_COVER_BASE + '/b/id/14627509-M.jpg',
            first.coverUrl,
            'Cover URL should be built from the cover id.'
        );
        Assert.areEqual(1937, first.publishYear, 'Publish year should be mapped.');
        Assert.areEqual(481, first.editionCount, 'Edition count should be mapped.');
        Assert.areEqual(
            'https://openlibrary.org/works/OL27482W',
            first.detailUrl,
            'Detail URL should point to the public work page.'
        );

        Assert.areEqual(
            'Roald Dahl, Quentin Blake',
            books[1].authors,
            'Multiple authors should be joined by a comma.'
        );

        Assert.isTrue(
            mock.capturedEndpoint.contains('callout:Open_Library_API/search.json'),
            'Search should use the Open Library Named Credential.'
        );
    }

    @IsTest
    static void searchBooksUrlEncodesTheTermAndAsksForTheDeclaredFields() {
        CalloutMock mock = mockWith(200, SEARCH_SUCCESS_BODY);

        Test.startTest();
        LibraryService.searchBooks('  the hobbit & friends  ', 10);
        Test.stopTest();

        Assert.isTrue(
            mock.capturedEndpoint.contains('q=the+hobbit+%26+friends'),
            'The term should be trimmed and URL encoded, got: ' + mock.capturedEndpoint
        );
        Assert.isTrue(
            mock.capturedEndpoint.contains('limit=10'),
            'An explicit valid page size should be honoured.'
        );
        Assert.isTrue(
            mock.capturedEndpoint.contains(
                'fields=key,title,author_name,first_publish_year,cover_i,edition_count'
            ),
            'Only the fields consumed by the UI should be requested.'
        );
    }

    @IsTest
    static void searchBooksAcceptsANullTermWithoutFailing() {
        CalloutMock mock = mockWith(200, '{"numFound":0,"docs":[]}');

        Test.startTest();
        List<LibraryBook> books = LibraryService.searchBooks(null, 24);
        Test.stopTest();

        Assert.isTrue(books.isEmpty(), 'An empty result set should produce an empty list.');
        Assert.isTrue(
            mock.capturedEndpoint.contains('q=&'),
            'A null term should be sent as an empty query.'
        );
    }

    @IsTest
    static void searchBooksReturnsEmptyListWhenDocsIsEmpty() {
        mockWith(200, '{"numFound":0,"docs":[]}');

        Test.startTest();
        List<LibraryBook> books = LibraryService.searchBooks('nothing matches this', 24);
        Test.stopTest();

        Assert.areEqual(0, books.size(), 'An empty "docs" array should yield no books.');
    }

    @IsTest
    static void searchBooksToleratesItemsWithMissingFields() {
        mockWith(200, PARTIAL_FIELDS_BODY);

        Test.startTest();
        List<LibraryBook> books = LibraryService.searchBooks('partial', 24);
        Test.stopTest();

        Assert.areEqual(3, books.size(), 'The non-object entry should be skipped.');

        LibraryBook noCover = books[0];
        Assert.areEqual('OL1W', noCover.workId, 'Work id should still be extracted.');
        Assert.isNull(noCover.coverUrl, 'A missing cover id should produce a null cover URL.');
        Assert.areEqual(
            'Unknown author',
            noCover.authors,
            'A missing author_name should fall back to "Unknown author".'
        );
        Assert.isNull(noCover.publishYear, 'A missing publish year should stay null.');
        Assert.areEqual(3, noCover.editionCount, 'Edition count should still be mapped.');

        LibraryBook blankAuthors = books[1];
        Assert.areEqual(
            'Real Name',
            blankAuthors.authors,
            'Blank and null author entries should be dropped.'
        );
        Assert.isNull(blankAuthors.coverUrl, 'An explicit null cover id should produce no URL.');
        Assert.isNull(blankAuthors.publishYear, 'An explicit null year should stay null.');
        Assert.isNull(blankAuthors.editionCount, 'An explicit null edition count should stay null.');

        LibraryBook noKey = books[2];
        Assert.isNull(noKey.workId, 'A missing key should leave the work id null.');
        Assert.isNull(noKey.detailUrl, 'Without a work id there is no detail URL.');
        Assert.areEqual('No Key Book', noKey.title, 'Title should still be mapped.');
    }

    // ------------------------------------------------------- recommendations

    @IsTest
    static void getRecommendationsReturnsMappedBooksOnSuccess() {
        CalloutMock mock = mockWith(200, TRENDING_SUCCESS_BODY);

        Test.startTest();
        List<LibraryBook> books = LibraryService.getRecommendations(24);
        Test.stopTest();

        Assert.areEqual(2, books.size(), 'Both trending works should be mapped.');
        Assert.areEqual('OL17930368W', books[0].workId, 'Trending items share the search shape.');
        Assert.areEqual('Atomic Habits', books[0].title, 'Title should be mapped.');
        Assert.areEqual('James Clear', books[0].authors, 'Author should be mapped.');
        Assert.areEqual(
            EXPECTED_COVER_BASE + '/b/id/12539702-M.jpg',
            books[0].coverUrl,
            'Cover URL should be built the same way as for search.'
        );
        Assert.isTrue(
            mock.capturedEndpoint.contains('callout:Open_Library_API/trending/daily.json'),
            'Recommendations should come from the daily trending endpoint.'
        );
    }

    @IsTest
    static void getRecommendationsReturnsEmptyListWhenWorksIsEmpty() {
        mockWith(200, '{"works":[]}');

        Test.startTest();
        List<LibraryBook> books = LibraryService.getRecommendations(24);
        Test.stopTest();

        Assert.areEqual(0, books.size(), 'An empty "works" array should yield no books.');
    }

    // ----------------------------------------------------------- page sizing

    @IsTest
    static void limitFallsBackToTheDefaultWhenNullOrOutOfRange() {
        CalloutMock mock = mockWith(200, '{"works":[]}');

        Test.startTest();
        LibraryService.getRecommendations(null);
        String nullLimitEndpoint = mock.capturedEndpoint;
        LibraryService.getRecommendations(0);
        String zeroLimitEndpoint = mock.capturedEndpoint;
        LibraryService.getRecommendations(5000);
        String hugeLimitEndpoint = mock.capturedEndpoint;
        Test.stopTest();

        Assert.isTrue(nullLimitEndpoint.contains('limit=24'), 'A null limit should default to 24.');
        Assert.isTrue(zeroLimitEndpoint.contains('limit=24'), 'A zero limit should default to 24.');
        Assert.isTrue(
            hugeLimitEndpoint.contains('limit=24'),
            'A limit above the maximum should default to 24.'
        );
    }

    // ------------------------------------------------------- error handling

    @IsTest
    static void searchBooksThrowsLibraryExceptionOnServerError() {
        mockWith(500, '{"error":"internal"}');

        Test.startTest();
        try {
            LibraryService.searchBooks('the hobbit', 24);
            Assert.fail('A 500 response should raise a LibraryException.');
        } catch (LibraryService.LibraryException expected) {
            Assert.isTrue(
                expected.getMessage().contains('500'),
                'The message should carry the status code, got: ' + expected.getMessage()
            );
            Assert.isTrue(
                expected.getMessage().contains('Open Library'),
                'The message should be readable by an end user.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void getRecommendationsThrowsLibraryExceptionOnServerError() {
        mockWith(503, '');

        Test.startTest();
        try {
            LibraryService.getRecommendations(24);
            Assert.fail('A 503 response should raise a LibraryException.');
        } catch (LibraryService.LibraryException expected) {
            Assert.isTrue(
                expected.getMessage().contains('503'),
                'The message should carry the status code, got: ' + expected.getMessage()
            );
        }
        Test.stopTest();
    }

    // ------------------------------------------------- unusable response bodies

    @IsTest
    static void searchBooksReturnsEmptyListForAnEmptyBody() {
        mockWith(200, '');

        Test.startTest();
        List<LibraryBook> books = LibraryService.searchBooks('anything', 24);
        Test.stopTest();

        Assert.areEqual(0, books.size(), 'An empty body should not raise, just return nothing.');
    }

    @IsTest
    static void searchBooksReturnsEmptyListForMalformedJson() {
        mockWith(200, 'this is not json at all');

        Test.startTest();
        List<LibraryBook> books = LibraryService.searchBooks('anything', 24);
        Test.stopTest();

        Assert.areEqual(0, books.size(), 'Malformed JSON should not raise, just return nothing.');
    }

    @IsTest
    static void searchBooksReturnsEmptyListWhenTheBodyIsNotAnObject() {
        mockWith(200, '[1,2,3]');

        Test.startTest();
        List<LibraryBook> books = LibraryService.searchBooks('anything', 24);
        Test.stopTest();

        Assert.areEqual(0, books.size(), 'A JSON array root should yield no books.');
    }

    @IsTest
    static void searchBooksReturnsEmptyListWhenTheCollectionIsMissing() {
        mockWith(200, '{"numFound":0}');

        Test.startTest();
        List<LibraryBook> books = LibraryService.searchBooks('anything', 24);
        Test.stopTest();

        Assert.areEqual(0, books.size(), 'A missing "docs" key should yield no books.');
    }

    @IsTest
    static void searchBooksReturnsEmptyListWhenTheCollectionIsNotAnArray() {
        mockWith(200, '{"docs":"unexpected"}');

        Test.startTest();
        List<LibraryBook> books = LibraryService.searchBooks('anything', 24);
        Test.stopTest();

        Assert.areEqual(0, books.size(), 'A non-array "docs" value should yield no books.');
    }

    // ---------------------------------------------- LibraryBook direct mapping

    @IsTest
    static void wrapperAcceptsEveryNumericRepresentationOfAJsonNumber() {
        Long editionsAsLong = 481L;
        Decimal yearAsDecimal = 1937.6;
        Double coverAsDouble = 120.9;

        LibraryBook fromNumbers = LibraryBook.fromApiItem(
            new Map<String, Object>{
                'key' => '/works/OL27482W',
                'title' => 'The Hobbit',
                'edition_count' => editionsAsLong,
                'first_publish_year' => yearAsDecimal,
                'cover_i' => coverAsDouble
            },
            EXPECTED_COVER_BASE
        );

        Assert.areEqual(481, fromNumbers.editionCount, 'A Long should be narrowed to an Integer.');
        Assert.areEqual(1937, fromNumbers.publishYear, 'A Decimal should be truncated.');
        Assert.areEqual(
            EXPECTED_COVER_BASE + '/b/id/120-M.jpg',
            fromNumbers.coverUrl,
            'A Double cover id should be narrowed to an Integer.'
        );

        LibraryBook fromText = LibraryBook.fromApiItem(
            new Map<String, Object>{
                'key' => 'OL99W',
                'title' => '   Spaced Title   ',
                'first_publish_year' => '2001',
                'edition_count' => 'not a number',
                'author_name' => 'not an array'
            },
            null
        );

        Assert.areEqual('OL99W', fromText.workId, 'A bare key without a prefix should be kept.');
        Assert.areEqual('Spaced Title', fromText.title, 'The title should be trimmed.');
        Assert.areEqual(2001, fromText.publishYear, 'A numeric string should be parsed.');
        Assert.isNull(fromText.editionCount, 'A non-numeric string should become null.');
        Assert.areEqual(
            'Unknown author',
            fromText.authors,
            'A non-array author_name should fall back to "Unknown author".'
        );
    }

    @IsTest
    static void wrapperHandlesANullItemAndABlankCoverBase() {
        LibraryBook book = LibraryBook.fromApiItem(null, '   ');

        Assert.isNull(book.workId, 'A null item should not produce a work id.');
        Assert.isNull(book.detailUrl, 'A null item should not produce a detail URL.');
        Assert.isNull(book.coverUrl, 'A null item should not produce a cover URL.');
        Assert.areEqual('Untitled', book.title, 'A missing title should fall back to "Untitled".');
        Assert.areEqual(
            'Unknown author',
            book.authors,
            'A missing author list should fall back to "Unknown author".'
        );
        Assert.isNull(book.publishYear, 'A missing year should stay null.');
        Assert.isNull(book.editionCount, 'A missing edition count should stay null.');

        LibraryBook trailingSlash = LibraryBook.fromApiItem(
            new Map<String, Object>{ 'key' => '/works/OL5W/', 'cover_i' => 1 },
            EXPECTED_COVER_BASE + '/'
        );
        Assert.areEqual('OL5W', trailingSlash.workId, 'A trailing slash should be ignored.');
        Assert.areEqual(
            EXPECTED_COVER_BASE + '/b/id/1-M.jpg',
            trailingSlash.coverUrl,
            'A trailing slash on the cover base should not be duplicated.'
        );
    }

    // ------------------------------------------------------------------ setup

    private static CalloutMock mockWith(Integer statusCode, String body) {
        CalloutMock mock = new CalloutMock(statusCode, body);
        Test.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    /**
     * NamedCredential is a setup object and is invisible to tests running with
     * SeeAllData=false, so the record is built in memory. Endpoint is not
     * writable through the constructor, hence the JSON round trip.
     */
    private static NamedCredential buildCredential(String endpoint) {
        return (NamedCredential) JSON.deserialize(
            '{"Endpoint":' + JSON.serialize(endpoint) + '}',
            NamedCredential.class
        );
    }

    @IsTest
    static void resolveCoversBaseUrlUsesNamedCredentialEndpoint() {
        String resolved = LibraryService.resolveCoversBaseUrl(
            new List<NamedCredential>{ buildCredential('https://covers.example.org') }
        );

        Assert.areEqual(
            'https://covers.example.org',
            resolved,
            'The Named Credential endpoint should win over the default host.'
        );
    }

    @IsTest
    static void resolveCoversBaseUrlStripsTrailingSlash() {
        String resolved = LibraryService.resolveCoversBaseUrl(
            new List<NamedCredential>{ buildCredential('  https://covers.example.org/  ') }
        );

        Assert.areEqual(
            'https://covers.example.org',
            resolved,
            'A trailing slash would produce a double slash in the cover URL.'
        );
    }

    @IsTest
    static void resolveCoversBaseUrlFallsBackWhenNoCredential() {
        String resolved = LibraryService.resolveCoversBaseUrl(new List<NamedCredential>());

        Assert.areEqual(
            LibraryService.DEFAULT_COVERS_BASE,
            resolved,
            'An empty query result should fall back to the public cover host.'
        );
    }

    @IsTest
    static void resolveCoversBaseUrlFallsBackWhenEndpointIsBlank() {
        String resolved = LibraryService.resolveCoversBaseUrl(
            new List<NamedCredential>{ buildCredential('   ') }
        );

        Assert.areEqual(
            LibraryService.DEFAULT_COVERS_BASE,
            resolved,
            'A blank endpoint should fall back to the public cover host.'
        );
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
