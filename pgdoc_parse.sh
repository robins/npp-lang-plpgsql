# All the following scripts fetch from PG Docs (DEVEL branch)
 
# XXX: Remove empty lines at the end of generated text files
# XXX: Some piped commands can be crafted better / concise (use cut -d ":" -f1 etc.)
# XXX: This currently fetches ALL in the list, and doesn't filter those that are blank / non-reserved in PG column
# XXX: This currently fetches only the first items in the list (at times the list gives int / int4... in that we don't pick int4 yet)
# XXX: Similarly, we don't current pick up datatypes that are mentioned in between text (for e.g. http://www.postgresql.org/docs/9.1/static/datatype-binary.html mentions BLOB type, that we don't include yet)
# XXX: This list of URLs itself can be fetched directly, that'd allow fetching of new pages in PGDocs.
# XXX: Replace all newlines with spaces in the output files (currently we're doing this by hand)

# Fetch reserved words from PG Docs
timeout -s SIGTERM 50 curl -so - \
  http://www.postgresql.org/docs/devel/static/sql-keywords-appendix.html  \
    | grep -A2 "TOKEN" | tr -d '\n' | sed 's/--/\n/g' | grep -v "non-reserved" \
    | grep "reserved" | sed 's/\</ /g' | sed 's/\>/ /g' | awk '{print $9}' \
    | grep -v "<" | grep -v ">" | tr '[:upper:]' '[:lower:]' \
      > output/reserved_words.txt

      
# Fetch Datatypes from PG Docs
timeout -s SIGTERM 100 curl -so - \
  http://www.postgresql.org/docs/devel/static/datatype.html \
  http://www.postgresql.org/docs/devel/static/datatype-numeric.html \
  http://www.postgresql.org/docs/devel/static/datatype-money.html \
  http://www.postgresql.org/docs/devel/static/datatype-character.html \
  http://www.postgresql.org/docs/devel/static/datatype-binary.html \
  http://www.postgresql.org/docs/devel/static/datatype-datetime.html \
  http://www.postgresql.org/docs/devel/static/datatype-boolean.html \
  http://www.postgresql.org/docs/devel/static/datatype-enum.html \
  http://www.postgresql.org/docs/devel/static/datatype-geometric.html \
  http://www.postgresql.org/docs/devel/static/datatype-net-types.html \
  http://www.postgresql.org/docs/devel/static/datatype-net-types.html \
  http://www.postgresql.org/docs/devel/static/datatype-textsearch.html \
  http://www.postgresql.org/docs/devel/static/datatype-uuid.html \
  http://www.postgresql.org/docs/devel/static/datatype-oid.html \
  http://www.postgresql.org/docs/devel/static/datatype-pg-lsn.html \
  http://www.postgresql.org/docs/devel/static/datatype-pseudo.html \
    | grep "TYPE" | grep td | sed 's/\</ /g' | sed 's/\>/ /g' \
    | awk '{print $9}' | grep -v "<" | grep -v ">" | grep -v "XHTML" \
    | sort | uniq | tr '[:upper:]' '[:lower:]' \
      > output/datatypes.txt

    
# Fetch Configuration Parameters from PG Docs
timeout -s SIGTERM 100 curl -so -  \
  http://www.postgresql.org/docs/devel/static/runtime-config-connection.html     \
  http://www.postgresql.org/docs/devel/static/runtime-config-resource.html       \
  http://www.postgresql.org/docs/devel/static/runtime-config-wal.html            \
  http://www.postgresql.org/docs/devel/static/runtime-config-replication.html    \
  http://www.postgresql.org/docs/devel/static/runtime-config-query.html          \
  http://www.postgresql.org/docs/devel/static/runtime-config-logging.html        \
  http://www.postgresql.org/docs/devel/static/runtime-config-statistics.html     \
  http://www.postgresql.org/docs/devel/static/runtime-config-autovacuum.html     \
  http://www.postgresql.org/docs/devel/static/runtime-config-client.html         \
  http://www.postgresql.org/docs/devel/static/runtime-config-locks.html          \
  http://www.postgresql.org/docs/devel/static/runtime-config-compatible.html     \
  http://www.postgresql.org/docs/devel/static/runtime-config-error-handling.html \
  http://www.postgresql.org/docs/devel/static/runtime-config-preset.html         \
  http://www.postgresql.org/docs/devel/static/runtime-config-developer.html      \
  | grep -oP -i 'varname.{0,40}' | cut --bytes=10- | cut -d "<" -f1 | sort| uniq \
  | tr '[:upper:]' '[:lower:]' \
    > output/configuration_parameters.txt
