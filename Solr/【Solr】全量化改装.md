





```bash
curl -s "http://admin:nvp_18CL@127.0.0.1:8983/solr/address/dataimport?command=full-import&commit=true&wt=json&indent=true&verbose=false&clean=true&optimize=false&debug=flase"

curl -s "http://admin:nvp_18CL@127.0.0.1:8983/solr/address/dataimport?command=delta-import&commit=true&wt=json&indent=true&verbose=false&clean=false&optimize=false&debug=flase"
```
