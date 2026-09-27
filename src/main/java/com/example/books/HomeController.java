package com.example.books;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
class HomeController {
    private final BookCatalog catalog;
    private final String lastChecked;

    HomeController(BookCatalog catalog, @Value("${books.last-checked}") String lastChecked) {
        this.catalog = catalog;
        this.lastChecked = lastChecked;
    }

    @GetMapping("/")
    String home(@RequestParam(required = false) String topic, @RequestParam(required = false) String q, Model model) {
        model.addAttribute("books", catalog.find(topic, q));
        model.addAttribute("topics", catalog.topics());
        model.addAttribute("selectedTopic", topic == null ? "" : topic);
        model.addAttribute("q", q == null ? "" : q);
        model.addAttribute("lastChecked", lastChecked);
        return "index";
    }

    public static String shortDescription(String description) {
        if (description == null || description.length() <= 140) {
            return description;
        }
        int cut = description.lastIndexOf(' ', 137);
        if (cut < 80) {
            cut = 137;
        }
        return description.substring(0, cut) + "...";
    }
}
