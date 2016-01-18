class SiegeMachine
  # SIEGE 2.70
  # Usage: siege [options]
  #        siege [options] URL
  #        siege -g URL
  # Options:
  #   -V, --version           VERSION, prints the version number.
  #   -h, --help              HELP, prints this section.
  #   -C, --config            CONFIGURATION, show the current config.
  #   -v, --verbose           VERBOSE, prints notification to screen.
  #   -g, --get               GET, pull down HTTP headers and display the
  #                           transaction. Great for application debugging.
  #   -c, --concurrent=NUM    CONCURRENT users, default is 10
  #   -i, --internet          INTERNET user simulation, hits URLs randomly.
  #   -b, --benchmark         BENCHMARK: no delays between requests.
  #   -t, --time=NUMm         TIMED testing where "m" is modifier S, M, or H
  #                           ex: --time=1H, one hour test.
  #   -r, --reps=NUM          REPS, number of times to run the test.
  #   -f, --file=FILE         FILE, select a specific URLS FILE.
  #   -R, --rc=FILE           RC, specify an siegerc file
  #   -l, --log[=FILE]        LOG to FILE. If FILE is not specified, the
  #                           default is used: PREFIX/var/siege.log
  #   -m, --mark="text"       MARK, mark the log file with a string.
  #   -d, --delay=NUM         Time DELAY, random delay before each requst
  #                           between 1 and NUM. (NOT COUNTED IN STATS)
  #   -H, --header="text"     Add a header to request (can be many)
  #   -A, --user-agent="text" Sets User-Agent in request
  # Examples:  
  #   siege -d10 -c50 -i -f mysite.txt
  #   -c50 (simulate 50 users)
  #   -d10 (random request interval between 0 and 10 seconds)
  #
  #   siege -d1 -c1 -f mysite.txt --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:17.0) Gecko/17.0 Firefox/17.0 FirePHP/0.7.1"
  #
  #   siege -d1 -c1 --reps=1 --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:17.0) Gecko/17.0 Firefox/17.0 FirePHP/0.7.1" URL
  
  def run(url)
    puts `siege --delay=1 --concurrent=1 --reps=1 --user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:17.0) Gecko/17.0 Firefox/17.0 FirePHP/0.7.1" #{url}`
  end
end