/**
 * Read-only wrapper exposed to Lightning for a single Open Library work.
 *
 * Both the search endpoint (/search.json -> "docs") and the trending endpoint
 * (/trending/daily.json -> "works") return items with the same shape, so this
 * single factory parses both. Every field of the payload is optional: the
 * factory never assumes a key is present and never dereferences a null value.
 */
public with sharing class LibraryBook {
    private static final String UNKNOWN_AUTHOR = 'Unknown author';
    private static final String UNTITLED = 'Untitled';
    private static final String AUTHOR_SEPARATOR = ', ';
    private static final String WORK_DETAIL_BASE = 'https://openlibrary.org/works/';
    private static final String COVER_PATH = '/b/id/';
    private static final String COVER_SIZE_SUFFIX = '-M.jpg';
    private static final String FALLBACK_COVERS_BASE = 'https://covers.openlibrary.org';
    private static final String NUMBER_PATTERN = '-?\\d+(\\.\\d+)?';

    /** Open Library work identifier without the "/works/" prefix, e.g. "OL27482W". */
    @AuraEnabled
    public String workId { get; set; }

    /** Work title, or "Untitled" when the payload omits it. */
    @AuraEnabled
    public String title { get; set; }

    /** Author names joined by ", ", or "Unknown author" when none are provided. */
    @AuraEnabled
    public String authors { get; set; }

    /** Absolute cover image URL, or null when the work has no cover. */
    @AuraEnabled
    public String coverUrl { get; set; }

    /** Year of first publication, or null when unknown. */
    @AuraEnabled
    public Integer publishYear { get; set; }

    /** Number of known editions, or null when unknown. */
    @AuraEnabled
    public Integer editionCount { get; set; }

    /** Public Open Library page for this work, or null when the id is missing. */
    @AuraEnabled
    public String detailUrl { get; set; }

    public LibraryBook() {
        this.title = UNTITLED;
        this.authors = UNKNOWN_AUTHOR;
    }

    /**
     * Builds a wrapper from one deserialized API item.
     *
     * @param item          a single entry of "docs" or "works"; may be null
     * @param coversBaseUrl base URL of the cover service; falls back to the public host
     */
    public static LibraryBook fromApiItem(Map<String, Object> item, String coversBaseUrl) {
        Map<String, Object> source = item == null ? new Map<String, Object>() : item;
        LibraryBook book = new LibraryBook();
        book.workId = extractWorkId(readString(source.get('key')));
        book.title = normalizeTitle(readString(source.get('title')));
        book.authors = joinAuthors(source.get('author_name'));
        book.coverUrl = buildCoverUrl(toInteger(source.get('cover_i')), coversBaseUrl);
        book.publishYear = toInteger(source.get('first_publish_year'));
        book.editionCount = toInteger(source.get('edition_count'));
        book.detailUrl = String.isBlank(book.workId) ? null : WORK_DETAIL_BASE + book.workId;
        return book;
    }

    // "/works/OL27482W" -> "OL27482W". Tolerates a bare id, a trailing slash and a null key.
    private static String extractWorkId(String rawKey) {
        String trimmedKey = rawKey == null ? '' : rawKey.trim().removeEnd('/');
        String tail = trimmedKey.substringAfterLast('/');
        return String.isNotBlank(tail) ? tail : (String.isBlank(trimmedKey) ? null : trimmedKey);
    }

    private static String normalizeTitle(String rawTitle) {
        return String.isBlank(rawTitle) ? UNTITLED : rawTitle.trim();
    }

    // "author_name" is a JSON array of strings; blank entries are dropped.
    private static String joinAuthors(Object rawAuthors) {
        List<Object> values = rawAuthors instanceof List<Object>
            ? (List<Object>) rawAuthors
            : new List<Object>();
        List<String> names = new List<String>();
        for (Object value : values) {
            String name = readString(value);
            if (String.isNotBlank(name)) {
                names.add(name.trim());
            }
        }
        return names.isEmpty() ? UNKNOWN_AUTHOR : String.join(names, AUTHOR_SEPARATOR);
    }

    private static String buildCoverUrl(Integer coverId, String coversBaseUrl) {
        String base = String.isBlank(coversBaseUrl)
            ? FALLBACK_COVERS_BASE
            : coversBaseUrl.trim().removeEnd('/');
        return coverId == null ? null : base + COVER_PATH + coverId + COVER_SIZE_SUFFIX;
    }

    private static String readString(Object value) {
        return value == null ? null : String.valueOf(value);
    }

    /**
     * Untyped JSON deserialization yields an Integer for a whole number, but the
     * same field may arrive as a Long, a Double, a Decimal or a numeric string.
     * The string round trip normalizes all of them without relying on
     * instanceof to tell Double and Decimal apart. Anything that is not a plain
     * number degrades to null instead of throwing.
     */
    private static Integer toInteger(Object value) {
        if (value instanceof Integer) {
            return (Integer) value;
        }
        String text = readString(value);
        Boolean isNumber = String.isNotBlank(text) && Pattern.matches(NUMBER_PATTERN, text.trim());
        return isNumber ? Decimal.valueOf(text.trim()).intValue() : null;
    }
}
