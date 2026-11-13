package com.example.books;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
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
            JsonNode nodes = objectMapper.readTree(stream);
            List<Book> loaded = new ArrayList<>();
            for (JsonNode node : nodes) {
                List<String> topics = new ArrayList<>();
                node.path("topics").forEach(topic -> topics.add(topic.asText()));
                List<String> authors = new ArrayList<>();
                node.path("authors").forEach(author -> authors.add(author.asText()));
                loaded.add(new Book(node.path("isbn").asText(), node.path("title").asText(),
                        node.path("subtitle").isMissingNode() ? null : node.path("subtitle").asText(),
                        String.join(", ", authors), node.path("publisher").asText(), node.path("year").asInt(),
                        node.path("url").asText(), topics,
                        node.path("description").isMissingNode() ? null : node.path("description").asText()));
            }
            this.books = List.copyOf(loaded);
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
                || book.author().toLowerCase(Locale.ROOT).contains(query)
                || book.publisher().toLowerCase(Locale.ROOT).contains(query)
                || (book.description() != null && book.description().toLowerCase(Locale.ROOT).contains(query));
    }
}
