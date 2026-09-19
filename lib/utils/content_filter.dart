// Content filter utility for rejecting offensive language and
// irrelevant / brainrot wording from user-facing text fields.
//
// Used in:
//   - CustomerNameScreen   (customer name input)
//   - MenuOrderingScreen   (special instructions input)

class ContentFilter {
  // ──────────────────────────────────────────────────────────────────
  // Blocked word lists
  // ──────────────────────────────────────────────────────────────────

  /// Vulgar / offensive / hate-speech terms (partial-match, case-insensitive).
  static const List<String> _profanityList = [
    // Sexual / explicit
    'fuck', 'fucker', 'fucking', 'fvck', 'f*ck', 'f**k',
    'shit', 'sh1t', 'sh!t', 's**t',
    'ass', 'asshole', 'arse',
    'bitch', 'b1tch', 'b*tch',
    'bastard',
    'cunt', 'c*nt',
    'dick', 'd*ck',
    'cock', 'c*ck',
    'pussy', 'p*ssy',
    'slut', 'wh*re', 'whore',
    'porn', 'porno',
    'sex', 'sexy',
    'rape', 'rapist',
    // Racial / hate slurs
    'nigga', 'nigger', 'n*gga', 'n*gger', 'ni*ga', 'nig*a','nigg*', 'ni*ger', 'nig*er','nigg*r','nigge*','*igger',
    'faggot', 'fag', 'f*ggot',
    'retard', 'retarded',
    'spic', 'chink', 'kike', 'wetback',
    // General offensive
    'motherfucker', 'mf', 'gtfo', 'stfu',
    'dumbass', 'jackass', 'dipshit',
    'piss', 'p*ss',
    'crap',
    'damn', 'damned',
    'hell', // common but included per context
    'idiot', 'moron', 'imbecile',
    'loser', 'screw you', 'go to hell',
    'kill yourself', 'kys',
    'die', 'murder',
    'hate', 'terrorist', 'nazis',
  ];

  /// Brainrot / internet slang / nonsensical phrases that make no sense
  /// in a food-ordering context.
  static const List<String> _brainrotList = [
    // Gen-Z / TikTok slang
    'skibidi', 'rizz', 'rizzler', 'sigma',
    'ohio', 'only in ohio',
    'gyatt', 'gyat',
    'fanum tax',
    'npc', 'npc behavior',
    'slay queen', 'slay',
    'bussin', 'bussin bussin',
    'based', 'cringe', 'mid',
    'no cap', 'cap cap',
    'lowkey', 'highkey',
    'fr fr', 'frfr',
    'on god', 'ong',
    'sheesh', 'bruh', 'bruhhh',
    'sus', 'imposter',
    'ligma', 'sugma',
    'bofa', 'deez nuts', 'deez',
    'yeet', 'yeeted',
    'poggers', 'pog champ',
    'big chungus',
    'amogus', 'among us',
    'lmao', 'lmfao', 'rofl',
    'idc', 'idk', 'imo', 'tbh',
    'smh', 'fml',
    'xd', 'lol lol lol',
    'hahaha', 'hehehehe',
    'kekw', 'pepega',
    'copium', 'hopium',
    'ratio', 'l + ratio',
    'touch grass',
    'rent free',
    'main character', 'npc moment',
    'vibe check',
    'hit different',
    'slaps hard',
    'he ate',
    'ate and left no crumbs',
    'snatched',
    'periodt',
    'understood the assignment',
    'it is what it is',
    'the audacity',
    'no thoughts head empty',
    'that slaps',
    'lowkey obsessed',
    'mother',
    'go off queen',
    'ok boomer',
    'wake up babe',
    'real and true',
    'not me',
    'thanks i hate it',
    'send it',
    'big oof',
    'oof',
    'this is fine',
    'stonks',
    'we do a little trolling',
    'i am once again asking',
    'tell me you',
    'hot take',
    'spill the tea',
    'no printer',
    'living rent free',
    'understood the vibe',
    'caught in 4k',
    'say it louder',
    'say less',
    'aight bet',
    'bet bet',
    'on sight',
    'deadass',
    'no kizzy',
    'kizzy',
    'zaza',
    'delulu', 'solulu',
    'rizz up',
    'unalived',
    'gatekeep', 'girlboss',
    'manifestation', 'manifest',
    'purr',
    'i feel like',
    'ok real',
    'bffr',
    'ngl ngl',
    'wsg',
    'litt',
    'goated',
    'goat goat',
    'let him cook',
    'cooking',
    'he is cooking',
    'mogging',
    'mog',
    'w rizz',
    'l rizz',
    'hawk tuah',
    'talmbout',
    'bro is',
    'bro said',
    'bro really',
    'bro thought',
    'bro moment',
    'bro behaviour',
    'bro what',
    'nah fr',
    'yap session',
    'yapping',
    'glazing',
    'glaze',
  ];

  // ──────────────────────────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────────────────────────

  /// Returns `null` when the input is clean, or an error message string
  /// that can be used directly as a [FormField] validator return value.
  static String? validate(String? value, {bool isName = false}) {
    if (value == null || value.trim().isEmpty) return null; // let required-check handle blank

    final lower = value.toLowerCase();

    for (final word in _profanityList) {
      if (_containsWord(lower, word)) {
        return isName
            ? 'Please use a proper name — offensive language is not allowed.'
            : 'Please keep instructions respectful — offensive language is not allowed.';
      }
    }

    for (final phrase in _brainrotList) {
      if (_containsPhrase(lower, phrase)) {
        return isName
            ? 'Please enter a real name — unrelated slang or phrases are not allowed.'
            : 'Please describe your food preferences clearly — unrelated phrases are not allowed.';
      }
    }

    // Extra: name-specific checks (numbers, gibberish-only, emoji-only)
    if (isName) {
      final stripped = value.replaceAll(RegExp(r'[^\x00-\x7F]'), '').trim(); // remove emoji
      if (stripped.isEmpty) {
        return 'Please enter a real name using letters.';
      }
      if (RegExp(r'^\d+$').hasMatch(stripped)) {
        return 'A name cannot be numbers only.';
      }
      if (stripped.length < 2) {
        return 'Name is too short — please enter your full name.';
      }
      // No meaningful letters (e.g. "!!!???")
      if (!RegExp(r'[a-zA-Z]').hasMatch(stripped)) {
        return 'Please enter a valid name with letters.';
      }
    }

    return null; // ✅ clean
  }

  /// Sanitises a string by replacing blocked words with asterisks.
  /// Use this for live `onChanged` feedback rather than hard rejection.
  static String sanitize(String value) {
    String result = value;
    for (final word in [..._profanityList, ..._brainrotList]) {
      result = result.replaceAll(
        RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false),
        '*' * word.length,
      );
    }
    return result;
  }

  // ──────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────

  /// Word-boundary match for single-word terms.
  static bool _containsWord(String text, String word) {
    if (word.contains(' ')) return _containsPhrase(text, word);
    return RegExp(r'\b' + RegExp.escape(word) + r'\b').hasMatch(text);
  }

  /// Substring match for multi-word phrases.
  static bool _containsPhrase(String text, String phrase) {
    return text.contains(phrase);
  }
}
