/**
 * Lightning entry point for the Library feature.
 *
 * The LWC talks only to this class, never to LibraryService directly.
 *
 * Both methods perform a callout, so they are @AuraEnabled WITHOUT
 * cacheable=true and must be called imperatively from the component. A
 * cacheable method cannot make a callout.
 */
public with sharing class LibraryController {
    private static final Integer DEFAULT_PAGE_SIZE = 24;
    private static final String GENERIC_ERROR =
        'Something went wrong while loading books. Please try again.';

    /**
     * Searches books by free text.
     *
     * A blank or null term returns the recommendations instead of an empty
     * list, so the component can reuse one call for the initial render and for
     * a cleared search box.
     *
     * @param searchTerm term typed by the user; blank or null returns recommendations
     * @return up to 24 books
     */
    @AuraEnabled
    public static List<LibraryBook> searchBooks(String searchTerm) {
        try {
            return String.isBlank(searchTerm)
                ? LibraryService.getRecommendations(DEFAULT_PAGE_SIZE)
                : LibraryService.searchBooks(searchTerm, DEFAULT_PAGE_SIZE);
        } catch (Exception error) {
            throw buildAuraException(error);
        }
    }

    /**
     * Returns the recommended books shown before the user searches anything.
     *
     * @return up to 24 books
     */
    @AuraEnabled
    public static List<LibraryBook> getRecommendations() {
        try {
            return LibraryService.getRecommendations(DEFAULT_PAGE_SIZE);
        } catch (Exception error) {
            throw buildAuraException(error);
        }
    }

    /**
     * AuraHandledException only forwards its message to the client when the
     * message is set explicitly, so it is assigned through both the constructor
     * and setMessage().
     */
    private static AuraHandledException buildAuraException(Exception error) {
        String message = String.isBlank(error.getMessage()) ? GENERIC_ERROR : error.getMessage();
        AuraHandledException auraError = new AuraHandledException(message);
        auraError.setMessage(message);
        return auraError;
    }
}
