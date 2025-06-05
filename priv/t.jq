def snake_case(s): s | gsub("(?<x>[a-z09])(?<y>[A-Z])"; "\(.x)_\(.y|ascii_downcase)") | ascii_downcase;
