#!/bin/zsh

 function web_search() {
  emulate -L zsh

  typeset -A urls
  urls=(
    $ZSH_WEB_SEARCH_ENGINES
    # Web search engines
    google          "https://www.google.com/search?q="
    bing            "https://www.bing.com/search?q="
    brave           "https://search.brave.com/search?q="
    yahoo           "https://search.yahoo.com/search?p="
    duckduckgo      "https://www.duckduckgo.com/?q="
    ecosia          "https://www.ecosia.org/search?q="
    givero          "https://www.givero.com/search?q="
    qwant           "https://www.qwant.com/?q="

    # CODE 
    github          "https://github.com/search?q="
    stackoverflow   "https://stackoverflow.com/search?q="

    #NEWS
    gnews           "https://news.google.com/search?for="
    
    # Opinions
    reddit          "https://www.reddit.com/search?q="
    goodreads       "https://www.goodreads.com/search?q="
    imdb           "https://www.imdb.com/find?q="
    metacritic      "https://www.metacritic.com/search/all/"
    rotten          "https://www.rottentomatoes.com/search?search="
    ask             "https://www.ask.com/web?q="

    # Multimedia
    youtube         "https://www.youtube.com/results?search_query="
    1001tracklists  "https://www.1001tracklists.com/search.html?search_text="
    soundcloud      "https://soundcloud.com/search?q="
    gimages         "https://www.google.com/search?tbm=ischq="

    #AI
    perplexity      "https://perplexity.ai/search?q="
    
    #Research
    wolframalpha    "https://www.wolframalpha.com/input/?i="
    archive         "https://web.archive.org/web/*/"
    scholar         "https://scholar.google.com/scholar?q="

  )

  # check whether the search engine is supported
  if [[ -z "$urls[$1]" ]]; then
    echo "Search engine '$1' not supported."
    return 1
  fi

  if [[ $# -gt 1 ]]; then
    url="${urls[$1]}$(omz_urlencode ${@[2,-1]})"
  else
    # build main page url:
    # split by '/', then rejoin protocol (1) and domain (2) parts with '//'
    url="${(j://:)${(s:/:)urls[$1]}[1,2]}"
  fi

  $BROWSER "$url" &&
}


alias google='web_search google'
alias gnews='web_search gnews'
alias gimages='web_search gimages'
alias perplexity='web_search perplexity'
