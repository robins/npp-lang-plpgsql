# Fetch reserved words from PG Docs - DEVEL branch
# XXX: This currently fetches ALL in the list, and doesn't filter those that are blank / non-reserved in PG column

 curl -so - http://www.postgresql.org/docs/devel/static/sql-keywords-appendix.html  | grep -A2 "TOKEN" | tr -d '\n' | sed 's/--/\n/g' | grep -v "non-reserved" | grep "reserved" | sed 's/\</ /g' | sed 's/\>/ /g' | awk '{print $9}' | grep -v "<" | grep -v ">" > reserved_words.txt
 

 