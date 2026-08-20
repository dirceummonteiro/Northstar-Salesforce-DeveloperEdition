/**
 * Callout layer for the Open Library public API.
 *
 * Reuses HttpCalloutService for the transport. Search and trending share the
 * same item shape, so a single parser serves both collections ("docs" and
 * "works").
 *
 * Never invoked directly from Lightning: LibraryController is the only entry
 * point exposed to the front end.
 */
public with sharing class LibraryService {
    /** Public cover host, used when the Named Credential cannot be resolved. */
    public static final String DEFAULT_COVERS_BASE = 'https://covers.openlibrary.org';

    private static final String COVERS_CREDENTIAL_NAME = 'Open_Library_Covers';
    private static final String SEARCH_ENDPOINT = 'callout:Open_Library_API/search.json';
    private static final String TRENDING_ENDPOINT = 'callout:Open_Library_API/trending/daily.json';
    private static final String SEARCH_FIELDS =
        'key,title,author_name,first_publish_year,cover_i,edition_count';
    private static final String SEARCH_COLLECTION = 'docs';
    private static final String TRENDING_COLLECTION = 'works';
    private static final Integer DEFAULT_PAGE_SIZE = 24;
    private static final Integer MAX_PAGE_SIZE = 100;

    // Works without artwork are dropped, so the API is asked for more than the
    // page size to keep the grid full after filtering.
    private static final Integer OVER_FETCH_FACTOR = 2;

    // Resolved once per transaction.
    private static String coversBaseUrl;

    /** Thrown when Open Library answers with a non-200 status. */
    public class LibraryException extends Exception {
    }

    /**
     * Searches works by free text.
     *
     * @param query     search term; a blank term still queries the API
     * @param limitSize page size; null or out of range falls back to 24
     * @return matching books with a cover, or an empty list when none qualify
     */
    public static List<LibraryBook> searchBooks(String query, Integer limitSize) {
        String term = query == null ? '' : query.trim();
        Integer pageSize = resolveLimit(limitSize);
        String endpoint =
            SEARCH_ENDPOINT +
            '?q=' + EncodingUtil.urlEncode(term, 'UTF-8') +
            '&limit=' + fetchLimit(pageSize) +
            '&fields=' + SEARCH_FIELDS;
        return parseBooks(executeGet(endpoint), SEARCH_COLLECTION, pageSize);
    }

    /**
     * Returns the daily trending works, used as the recommendation strategy.
     *
     * @param limitSize page size; null or out of range falls back to 24
     * @return trending books with a cover, or an empty list when none qualify
     */
    public static List<LibraryBook> getRecommendations(Integer limitSize) {
        Integer pageSize = resolveLimit(limitSize);
        String endpoint = TRENDING_ENDPOINT + '?limit=' + fetchLimit(pageSize);
        return parseBooks(executeGet(endpoint), TRENDING_COLLECTION, pageSize);
    }

    private static String executeGet(String endpoint) {
        HttpResponse response = HttpCalloutService.get(endpoint);
        Integer statusCode = response.getStatusCode();
        if (statusCode != 200) {
            throw new LibraryException(
                'We could not reach Open Library right now (status ' +
                statusCode +
                '). Please try again in a moment.'
            );
        }
        return response.getBody();
    }

    private static Integer resolveLimit(Integer limitSize) {
        Integer requested = limitSize == null ? DEFAULT_PAGE_SIZE : limitSize;
        return requested < 1 || requested > MAX_PAGE_SIZE ? DEFAULT_PAGE_SIZE : requested;
    }

    /**
     * Asks the API for more items than the caller wants, because works without a
     * cover are discarded and would otherwise leave the grid short.
     */
    private static Integer fetchLimit(Integer pageSize) {
        Integer requested = pageSize * OVER_FETCH_FACTOR;
        return requested > MAX_PAGE_SIZE ? MAX_PAGE_SIZE : requested;
    }

    // Single parser for both endpoints: the items of "docs" and "works" are identical.
    private static List<LibraryBook> parseBooks(
        String responseBody,
        String collectionKey,
        Integer pageSize
    ) {
        List<LibraryBook> books = new List<LibraryBook>();
        String coversBase = getCoversBaseUrl();
        for (Object item : extractItems(responseBody, collectionKey)) {
            if (books.size() == pageSize) {
                break;
            }
            if (!(item instanceof Map<String, Object>)) {
                continue;
            }
            LibraryBook book = LibraryBook.fromApiItem((Map<String, Object>) item, coversBase);
            // A card with only a placeholder adds nothing, so cover-less works are dropped.
            if (String.isNotBlank(book.coverUrl)) {
                books.add(book);
            }
        }
        return books;
    }

    // An empty or malformed body is not an error: it simply yields no results.
    private static List<Object> extractItems(String responseBody, String collectionKey) {
        List<Object> empty = new List<Object>();
        if (String.isBlank(responseBody)) {
            return empty;
        }
        Object parsed = null;
        try {
            parsed = JSON.deserializeUntyped(responseBody);
        } catch (Exception parseError) {
            return empty;
        }
        if (!(parsed instanceof Map<String, Object>)) {
            return empty;
        }
        Object collection = ((Map<String, Object>) parsed).get(collectionKey);
        return collection instanceof List<Object> ? (List<Object>) collection : empty;
    }

    /**
     * Resolves the cover host from the Named Credential, falling back to the
     * public host. Resolved once per transaction.
     */
    private static String getCoversBaseUrl() {
        if (coversBaseUrl == null) {
            coversBaseUrl = resolveCoversBaseUrl([
                SELECT Endpoint
                FROM NamedCredential
                WHERE DeveloperName = :COVERS_CREDENTIAL_NAME
                LIMIT 1
            ]);
        }
        return coversBaseUrl;
    }

    /**
     * Picks the cover host from a Named Credential record, or falls back to the
     * public host when none is available.
     *
     * Kept free of SOQL on purpose: NamedCredential is a setup object and is not
     * visible to tests running with SeeAllData=false, so the query lives in the
     * caller and the decision logic stays directly testable.
     *
     * @param credentials query result; may be empty
     * @return usable cover host without a trailing slash
     */
    @TestVisible
    private static String resolveCoversBaseUrl(List<NamedCredential> credentials) {
        if (credentials.isEmpty() || String.isBlank(credentials[0].Endpoint)) {
            return DEFAULT_COVERS_BASE;
        }
        return credentials[0].Endpoint.trim().removeEnd('/');
    }
}
