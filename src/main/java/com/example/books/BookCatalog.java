package com.example.books;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

@Service
public class BookCatalog {
    private final List<Book> books;

    public BookCatalog() throws IOException {
        ObjectMapper objectMapper = new ObjectMapper();
        try (InputStream stream = getClass().getResourceAsStream("/books.json")) {
            if (stream == null) {
                throw new IllegalStateException("books.json is missing");
            }
            this.books = List.copyOf(objectMapper.readValue(stream, new TypeReference<List<Book>>() {}));
        }
    }

    public List<Book> find(String topic, String q) {
        return books.stream()
                .filter(book -> topic == null || topic.isBlank() || book.topics().contains(topic))
                .filter(book -> matchesQuery(book, q))
                .toList();
    }

    public Optional<Book> findByIsbn(String isbn) {
        return books.stream().filter(book -> book.isbn().equals(isbn)).findFirst();
    }

    public List<String> topics() {
        return books.stream().flatMap(book -> book.topics().stream()).distinct().sorted().toList();
    }

    private static boolean matchesQuery(Book book, String q) {
        if (q == null || q.isBlank()) {
            return true;
        }
        String query = q.toLowerCase(Locale.ROOT);
        return book.title().toLowerCase(Locale.ROOT).contains(query)
                || book.authors().stream().anyMatch(author -> author.toLowerCase(Locale.ROOT).contains(query))
                || book.publisher().toLowerCase(Locale.ROOT).contains(query)
                || (book.description() != null && book.description().toLowerCase(Locale.ROOT).contains(query));
    }
}
