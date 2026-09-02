/// Tagalog (Filipino) search keyword expansion.
///
/// Lets users find services by typing a Tagalog term even when the app is in
/// English (or vice-versa). Each Tagalog key maps to the English terms it
/// should expand to so client-side search filters can match a broader set of
/// service titles, categories, and descriptions.
///
/// Deliberately kept in a separate util (not wired through `AppLocalizations`)
/// because it is language-to-language search data, not UI copy.
library;

const Map<String, List<String>> _tagalogToEnglish = {
  // Categories: Cleaning
  'linis': ['cleaning', 'clean', 'house cleaning', 'housekeeping'],
  'paglilinis': ['cleaning', 'clean'],
  'maglinis': ['cleaning', 'clean'],
  'kutad': ['cleaning', 'clean'],
  // Categories: Plumbing
  'plumbero': ['plumbing', 'plumber', 'pipe'],
  'tubero': ['plumbing', 'plumber', 'pipe'],
  'tubig': ['plumbing', 'pipe', 'water leak', 'drain'],
  'tulo': ['plumbing', 'pipe leak', 'leak', 'faucet'],
  'sira ang tubo': ['plumbing', 'pipe', 'pipe replacement'],
  'plumbing': ['plumbing', 'plumber', 'pipe'],
  // Categories: Electrical
  'kuryente': ['electrical', 'electrician', 'wiring', 'outlet'],
  'elektrisyan': ['electrical', 'electrician'],
  'tripping': ['electrical', 'breaker', 'circuit breaker'],
  'saksakan': ['electrical', 'outlet'],
  'ilaw': ['electrical', 'lighting', 'light fixture'],
  // Categories: Painting & Decorating
  'pintura': ['painting', 'paint', 'painting & decorating', 'painter'],
  'pagpipinta': ['painting', 'paint'],
  'pintor': ['painting', 'painter'],
  'kulay': ['painting', 'paint'],
  // Categories: Handyman / General labor
  'handyman': ['handyman', 'general labor', 'repair'],
  'maninilbihan': ['handyman', 'general labor'],
  'kumpuni': ['handyman', 'repair', 'fix'],
  'ayos': ['handyman', 'repair', 'fix'],
  'pagkukumpuni': ['handyman', 'repair'],
  // Categories: Locksmith
  'locksmith': ['locksmith', 'lock'],
  'susian': ['locksmith', 'lock', 'key'],
  'susi': ['locksmith', 'lock', 'key'],
  'nakalock': ['locksmith', 'lock'],
  // Categories: Pest control
  'peste': ['pest control', 'pest', 'termite', 'cockroach', 'rats', 'ipis'],
  'daga': ['pest control', 'rats', 'rodent'],
  'ipis': ['pest control', 'cockroach'],
  'anay': ['pest control', 'termite'],
  'langgam': ['pest control', 'ants'],
  // Categories: Aircon / HVAC
  'aircon': ['aircon', 'air conditioning', 'hvac', 'ac'],
  'hvac': ['aircon', 'hvac', 'air conditioning'],
  // Categories: Car wash / auto
  'kotseng': ['car wash', 'auto', 'detailing'],
  'carwash': ['car wash', 'auto', 'detailing'],
  // Categories: Landscaping / gardening
  'halaman': ['landscaping', 'gardening', 'garden'],
  'hardin': ['landscaping', 'gardening', 'garden'],
  'pagdidilig': ['landscaping', 'gardening'],
  // Service words: general / repair
  'serbisyo': ['service', 'services'],
  'kumpunihin': ['repair', 'fix', 'handyman'],
  'reklamo': ['repair'],
  // Service words: home / cleaning related
  'bahay': ['home', 'house', 'house cleaning', 'cleaning'],
  'kwarto': ['room', 'cleaning'],
  'banyo': ['bathroom', 'bath', 'cleaning'],
  'kusina': ['kitchen', 'cleaning'],
  'labahan': ['laundry', 'laundry service'],
  'laba': ['laundry'],
  'plantsa': ['ironing', 'laundry'],
  // Service words: moving / transport
  'lipat bahay': ['moving', 'moving service', 'relocation'],
  'hahatid': ['delivery', 'transport'],
  // Service words: childcare / personal
  'yaya': ['nanny', 'childcare', 'babysitter'],
  'alagaan ang bata': ['babysitter', 'childcare', 'nanny'],
  'caregiver': ['caregiver', 'elder care', 'nursing'],
  // Service words: catering / events
  'katering': ['catering', 'food service'],
  'handaan': ['catering', 'event'],
  'mamahalin ng handaan': ['catering', 'event'],
  // Service words: photography / events
  'picturan': ['photography', 'photographer', 'videography'],
  'kamera': ['photography', 'photographer', 'videography'],
  // Service words: tutoring
  'tutor': ['tutor', 'tutoring', 'online class'],
  'pagtuturo': ['tutor', 'tutoring'],
  // Service words: beauty / grooming
  'gupit': ['barber', 'haircut', 'grooming', 'beauty'],
  'manikyur': ['manicure', 'beauty', 'nail'],
  'pedikyur': ['pedicure', 'beauty', 'nail'],
  'masahe': ['massage', 'spa'],
  // Service words: fitness
  'fitness': ['fitness', 'personal trainer', 'gym'],
  // Service words: pet care
  'aso': ['pet care', 'dog grooming', 'dog walker'],
  'pusa': ['pet care', 'cat grooming'],
  'alagang aso': ['pet care', 'dog grooming', 'dog walking'],
  // Service words: tech / office
  'kompyuter': ['computer', 'repair', 'it support', 'technician'],
  'internet': ['wifi', 'internet', 'it support', 'network'],
};

/// Returns `true` if [query] contains at least one recognized Tagalog search
/// term (whole-phrase or per-word).
bool isTagalogQuery(String query) {
  final lowercase = query.toLowerCase().trim();
  if (lowercase.isEmpty) return false;
  if (_tagalogToEnglish.containsKey(lowercase)) return true;
  return lowercase
      .split(RegExp(r'\s+'))
      .any((word) => word.isNotEmpty && _tagalogToEnglish.containsKey(word));
}

/// Expands a raw user query into a set of matchable English terms.
///
/// For each word in [query], the English terms that word maps to are added.
/// The returned set is lowercased and contains both any Tagalog substrings
/// and their English expansions, so callers can `.any((term) =>
/// haystack.contains(term))`.
Set<String> expandTagalogQuery(String query) {
  final lowercase = query.toLowerCase().trim();
  if (lowercase.isEmpty) return {};

  final expanded = <String>{};
  // Try the whole trimmed query first (covers multi-word keys like
  // 'lipat bahay').
  final whole = _tagalogToEnglish[lowercase];
  if (whole != null) {
    expanded.addAll(whole);
  }
  // Then expand individual words.
  for (final word in lowercase.split(RegExp(r'\s+'))) {
    if (word.isEmpty) continue;
    final mapped = _tagalogToEnglish[word];
    if (mapped != null) {
      expanded.addAll(mapped);
    }
    expanded.add(word);
  }
  return expanded;
}

/// Convenience: does [haystack] (the service title/category/description
/// already lowercased) match any term produced by [expandTagalogQuery]?
bool tagalogQueryMatches(String query, String haystack) {
  final expanded = expandTagalogQuery(query);
  if (expanded.isEmpty) return false;
  return expanded.any(haystack.contains);
}
