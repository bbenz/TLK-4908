package com.example.books;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;

import java.util.List;

@Schema(name = "Book")
public record Book(
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED, pattern = "^\\d{13}$")
        @Pattern(regexp = "^\\d{13}$") String isbn,
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED) @NotBlank String title,
        String subtitle,
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED) @NotBlank String author,
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED) @NotBlank String publisher,
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED) @Positive int year,
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED, format = "uri") @NotBlank String url,
        @Schema(requiredMode = Schema.RequiredMode.REQUIRED) @NotEmpty List<@NotBlank String> topics,
        String description) {
}
