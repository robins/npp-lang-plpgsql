# All the following scripts fetch from PG Docs (DEVEL branch)
 
# XXX: Remove empty lines at the end of generated text files
# XXX: Some piped commands can be crafted better / concise (use cut -d ":" -f1 etc.)
# XXX: This currently fetches ALL in the list, and doesn't filter those that are blank / non-reserved in PG column
# XXX: This currently fetches only the first items in the list (at times the list gives int / int4... in that we don't pick int4 yet)
# XXX: Similarly, we don't current pick up datatypes that are mentioned in between text (for e.g. http://www.postgresql.org/docs/9.1/static/datatype-binary.html mentions BLOB type, that we don't include yet)
# XXX: This list of URLs itself can be fetched directly, that'd allow fetching of new pages in PGDocs.
# XXX: Replace all newlines with spaces in the output files (currently we're doing this by hand)
# XXX: Instead of using cut --bytes=10- we should be using cut -d ">" -f2      
# XXX: Get a script to update function list with a customizable set of extensions list enabled.
# XXX: Get sql.xml file's autocomplete section and update that as per postgres and use that instead.


# Fetch reserved words from PG Docs
timeout -s SIGTERM 50 curl -so - \
  "http://git.postgresql.org/gitweb/?p=postgresql.git;a=blob_plain;f=src/include/parser/kwlist.h" \
  "http://git.postgresql.org/gitweb/?p=postgresql.git;a=blob_plain;f=src/pl/plpgsql/src/pl_scanner.c" \
    | grep -w "PG_KEYWORD(" | cut -d "\"" -f2 | tr "\n" " " | tr '[:lower:]' '[:upper:]' \
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
      > output/datatypes.txt

timeout -s SIGTERM 100 curl -so - \
  "http://git.postgresql.org/gitweb/?p=postgresql.git;a=blob_plain;f=src/interfaces/ecpg/preproc/c_keywords.c" \
  | grep "{\"" | cut -d "\"" -f2  \
    >> output/datatypes.txt

timeout -s SIGTERM 100 curl -so - \
  "http://git.postgresql.org/gitweb/?p=postgresql.git;a=blob_plain;f=src/backend/bootstrap/bootstrap.c" \
  | grep "{\"" | cut -d "\"" -f2  \
    >> output/datatypes.txt

cat output/datatypes.txt | tr "[[:lower:]]" "[[:upper:]]" | sort | uniq \
  | tr "\n" " " \
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
  | grep -oP -i 'varname.{0,40}' | cut --bytes=10- | cut -d "<" -f1 \
    > output/configuration_parameters.txt
    
#XXX: The difference between first and second list would tell about config variables
#   that are either not documented or places that we are not seeing yet
timeout -s SIGTERM 100 curl -so -  \
  "http://git.postgresql.org/gitweb/?p=postgresql.git;a=blob_plain;f=src/backend/utils/misc/postgresql.conf.sample" \
  "http://git.postgresql.org/gitweb/?p=postgresql.git;a=blob_plain;f=src/backend/access/transam/recovery.conf.sample" \
  | cut -d "=" -f1 | sed 's/#//' | sed 's/ //' | grep -v "[^[:lower:]_]" \
    >> output/configuration_parameters.txt
    

timeout -s SIGTERM 100 curl -so - \
  http://www.postgresql.org/docs/devel/static/libpq-connect.html \
  | tr -d "\n"| sed 's/  */ /g' | grep -oP 'LIBPQ.{0,200}' \
  | grep -oP 'LITERAL.{0,100}' | cut -d ">" -f2| cut -d "<" -f1  \
  | grep -v "[^[:lower:]_]" \
    >> output/configuration_parameters.txt

cat output/configuration_parameters.txt | sort | uniq | tr "\n" " " \
    > output/configuration_parameters.txt



    
#Fetch *ALL* HTML files from PostgreSQL Documentation in the DEVEL branch    
wget -nd -L -e robots=off -T10 -A html -r http://www.postgresql.org/docs/devel/static/


#Extract Reserved Words from the Downloaded HTML files (of PostgreSQL Doc)
cat *.html | grep -oP 'COMMAND.{0,100}' | cut -d ">" -f2 | cut -d "<" -f1 \
  | tr " " "\n" | grep -v "[^[:upper:]]" |  sort | uniq > command.txt

cat *.html | grep -oP 'TOKEN.{0,100}' | cut -d ">" -f2 | cut -d "<" -f1 \
  | tr " " "\n" | grep -v "[^[:upper:]]" |  sort | uniq > token.txt

cat *.html | grep -oP 'LITERAL.{0,100}' | cut -d ">" -f2 | cut -d "<" -f1 \
  | tr " " "\n" | grep -v "[^[:upper:]]" |  sort | uniq > literal.txt

