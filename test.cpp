#./sysroot/bin/clang++ -target x86_64-linux-llvm ./hello.cpp -std=c++23 -static

#include <iostream>
#include <string>
#include <string_view>
#include <print>
#include <optional>
#include <expected>
#include <ranges>
#include <algorithm>
#include <format>

// Using std::expected for error handling (C++23)
std::expected<int, std::string> divide(int a, int b) {
    if (b == 0) {
        return std::unexpected("Division by zero");
    }
    return a / b;
}

int main() {
    // Using std::print (C++23)
    std::print("Hello, C++23 World!\n");
    
    // Using string_view literals
    using namespace std::string_view_literals;
    auto sv = "C++23 features"sv;
    
    // Using std::format (C++20, but commonly used with C++23)
    std::cout << std::format("Testing {}\n", sv);
    
    // Using ranges with pipe syntax (C++23 enhanced)
    auto numbers = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    auto even_numbers = numbers 
        | std::views::filter([](int n) { return n % 2 == 0; })
        | std::views::transform([](int n) { return n * n; });
    
    // Using std::print with format string for the filtered results
    std::print("Squared even numbers: ");
    for (int n : even_numbers) {
        std::print("{} ", n);
    }
    std::print("\n");
    
    // Demonstrating std::expected
    auto result1 = divide(10, 2);
    auto result2 = divide(10, 0);
    
    if (result1) {
        std::print("10 / 2 = {}\n", *result1);
    }
    
    if (!result2) {
        std::print("Error: {}\n", result2.error());
    }
    
    // Using auto(x) = y; initialization (C++23)
    auto(meaning) = 42;
    std::print("The meaning of life: {}\n", meaning);
    
    return 0;
}
