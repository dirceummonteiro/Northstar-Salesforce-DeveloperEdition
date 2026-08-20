import { LightningElement } from 'lwc';
import searchBooks from '@salesforce/apex/LibraryController.searchBooks';
import getRecommendations from '@salesforce/apex/LibraryController.getRecommendations';

const GENERIC_ERROR_MESSAGE =
    'We could not reach the library right now. Please try again in a moment.';

export default class LibraryHome extends LightningElement {
    searchTerm = '';
    books = [];
    isLoading = false;
    hasError = false;
    errorMessage = '';
    isSearchMode = false;

    connectedCallback() {
        this.loadRecommendations();
    }

    get sectionTitle() {
        return this.isSearchMode ? 'Search results' : 'Recommended for you';
    }

    get sectionSubtitle() {
        if (this.isSearchMode) {
            return this.hasBooks
                ? `${this.books.length} book${this.books.length === 1 ? '' : 's'} found`
                : '';
        }
        return 'Trending today, curated by Open Library';
    }

    get hasBooks() {
        return this.books && this.books.length > 0;
    }

    get showEmptyState() {
        return !this.isLoading && !this.hasError && !this.hasBooks;
    }

    get emptyStateTitle() {
        return this.isSearchMode ? 'No books found' : 'No recommendations available';
    }

    get emptyStateMessage() {
        return this.isSearchMode
            ? 'Try a different title or author.'
            : 'Check back later for trending picks.';
    }

    get showClearSearch() {
        return this.isSearchMode;
    }

    get displayBooks() {
        return this.books.map((book) => {
            const authors = this.formatAuthors(book.authors);
            const hasCover = !!book.coverUrl;
            const hasPublishYear = book.publishYear !== null && book.publishYear !== undefined;
            const hasEditionCount = !!book.editionCount && book.editionCount > 1;
            const hasDetailUrl = !!book.detailUrl;
            return {
                key: book.workId,
                title: book.title || 'Untitled',
                authors,
                hasAuthors: !!authors,
                coverUrl: book.coverUrl,
                hasCover,
                publishYear: book.publishYear,
                hasPublishYear,
                editionCountLabel: hasEditionCount ? `${book.editionCount} editions` : '',
                hasEditionCount,
                detailUrl: book.detailUrl,
                hasDetailUrl,
                detailAriaLabel: `View "${book.title || 'this book'}" on Open Library`
            };
        });
    }

    formatAuthors(authors) {
        if (!authors) {
            return '';
        }
        if (Array.isArray(authors)) {
            return authors.filter((name) => !!name).join(', ');
        }
        return String(authors);
    }

    handleSearchTermChange(event) {
        this.searchTerm = event.target.value;
    }

    handleSearchKeyUp(event) {
        if (event.key === 'Enter') {
            this.runSearch();
        }
    }

    handleSearchClick() {
        this.runSearch();
    }

    handleClearSearch() {
        this.searchTerm = '';
        this.isSearchMode = false;
        this.loadRecommendations();
    }

    runSearch() {
        const term = (this.searchTerm || '').trim();
        if (!term) {
            return;
        }
        this.isSearchMode = true;
        this.isLoading = true;
        this.hasError = false;
        this.errorMessage = '';
        this.books = [];

        searchBooks({ searchTerm: term })
            .then((result) => {
                this.books = result || [];
            })
            .catch((error) => {
                this.handleError(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    loadRecommendations() {
        this.isLoading = true;
        this.hasError = false;
        this.errorMessage = '';
        this.books = [];

        getRecommendations()
            .then((result) => {
                this.books = result || [];
            })
            .catch((error) => {
                this.handleError(error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleError(error) {
        this.hasError = true;
        this.books = [];
        this.errorMessage = this.extractErrorMessage(error);
    }

    extractErrorMessage(error) {
        if (error && error.body) {
            if (Array.isArray(error.body) && error.body.length > 0 && error.body[0].message) {
                return error.body[0].message;
            }
            if (typeof error.body.message === 'string' && error.body.message) {
                return error.body.message;
            }
        }
        return GENERIC_ERROR_MESSAGE;
    }
}
