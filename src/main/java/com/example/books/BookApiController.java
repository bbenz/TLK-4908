package com.example.books;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.ArraySchema;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import jakarta.validation.constraints.Pattern;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/books")
@Validated
class BookApiController {
    private final BookCatalog catalog;

    BookApiController(BookCatalog catalog) {
        this.catalog = catalog;
    }

    @Operation(summary = "List books")
    @ApiResponse(responseCode = "200", description = "A list of books",
            content = @Content(array = @ArraySchema(schema = @Schema(implementation = Book.class))))
    @GetMapping(produces = "application/json")
    List<Book> list(@RequestParam(required = false) String topic, @RequestParam(required = false) String q) {
        return catalog.find(topic, q);
    }

    @Operation(summary = "Get a book by ISBN")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "A book",
                    content = @Content(schema = @Schema(implementation = Book.class))),
            @ApiResponse(responseCode = "404", description = "Book not found", content = @Content)
    })
    @GetMapping(value = "/{isbn}", produces = "application/json")
    ResponseEntity<?> get(@PathVariable @Pattern(regexp = "^\\d{13}$") String isbn) {
        return catalog.findByIsbn(isbn)
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.status(404).contentType(MediaType.APPLICATION_PROBLEM_JSON)
                        .body(ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, "Book not found")));
    }
}
