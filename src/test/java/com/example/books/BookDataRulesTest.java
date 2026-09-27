package com.example.books;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.net.URI;
import java.time.Year;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.assertj.core.api.Assertions.assertThat;

class BookDataRulesTest {

    private static final Set<String> ALLOWED_TOPICS = Set.of(
            "spring-ai", "langchain4j", "quarkus", "jakarta-ee", "generative-ai", "rag",
            "agents", "mcp", "machine-learning", "deep-learning", "ai-assisted-coding");

    @Test
    void enoughBooks() {
        assertThat(books()).as("at least 8 books").hasSizeGreaterThanOrEqualTo(8);
    }

    @Test
    void isbnsAreThirteenDigitsAndUnique() {
        Set<String> seen = new HashSet<>();
        for (BookData book : books()) {
            assertThat(book.isbn()).as("\"%s\": ISBN is 13 digits", book.title()).matches("\\d{13}");
            assertThat(seen.add(book.isbn())).as("\"%s\": ISBN %s is unique", book.title(), book.isbn()).isTrue();
        }
    }

    @Test
    void everyIsbnHasAValidCheckDigit() {
        for (BookData book : books()) {
            assertThat(isValidIsbn13(book.isbn()))
                .as("\"%s\": ISBN %s has a bad check digit",
                    book.title(), book.isbn())
                .isTrue();
        }
    }

    @Test
    void urlsUseHttps() {
        for (BookData book : books()) {
            assertThat(book.url()).as("\"%s\": url uses https", book.title()).startsWith("https://");
            assertThat(URI.create(book.url()).getScheme()).as("\"%s\": url is valid", book.title()).isEqualTo("https");
        }
    }

    @Test
    void yearsAreRealistic() {
        for (BookData book : books()) {
            assertThat(book.year()).as("\"%s\": year is in range", book.title())
                    .isBetween(2015, Year.now().getValue());
        }
    }

    @Test
    void everyBookHasATitleAndAnAuthor() {
        for (BookData book : books()) {
            assertThat(book.title()).as("title is set").isNotBlank();
            assertThat(book.authors()).as("\"%s\": at least one author", book.title()).isNotEmpty();
            assertThat(book.authors()).as("\"%s\": author names are set", book.title()).allSatisfy(author -> assertThat(author).isNotBlank());
        }
    }

    @Test
    void topicsComeFromTheList() {
        for (BookData book : books()) {
            assertThat(book.topics()).as("\"%s\": topics are set", book.title()).isNotEmpty();
            assertThat(ALLOWED_TOPICS).as("\"%s\": topics are allowed", book.title()).containsAll(book.topics());
        }
    }

    private static List<BookData> books() {
        try (var stream = BookDataRulesTest.class.getResourceAsStream("/books.json")) {
            assertThat(stream).as("books.json exists").isNotNull();
            return new ObjectMapper().readValue(stream, new TypeReference<>() {});
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    private static boolean isValidIsbn13(String isbn) {
        int sum = 0;
        for (int i = 0; i < 12; i++) {
            sum += Character.digit(isbn.charAt(i), 10) * (i % 2 == 0 ? 1 : 3);
        }
        int check = (10 - (sum % 10)) % 10;
        return check == Character.digit(isbn.charAt(12), 10);
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    record BookData(String isbn, String title, List<String> authors, String url, int year, List<String> topics) {
    }
}
