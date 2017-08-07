guide_body = """<!-- Iridize guide -->
<script type="text/javascript">
window.iridize=window.iridize||function(e,t,n){return iridize.api.call(e,t,n);};iridize.api=iridize.api||{q:[],call:function(e,t,n){iridize.api.q.push({method:e,data:t,callback:n});}};
iridize.appId="fdvngYO5QEaimBa6kGqe+w";

(function(){var e=document.createElement("script");var t=document.getElementsByTagName("script")[0];e.src=("https:"==document.location.protocol?"https:":"http:")+"//d2p93rcsj9dwm5.cloudfront.net/player/latest/static/js/iridizeLoader.min.js";e.type="text/javascript";e.async=true;t.parentNode.insertBefore(e,t);})();

</script>
  <!-- Iridize guide -->"""



with open('/opt/cloudify-stage/dist/index.html', 'r') as f:
    filedata = f.read()
# Replace the target string
filedata = filedata.replace('</body>', (guide_body + '\n</body>'))
# Write the file out again
with open('/opt/cloudify-stage/dist/index.html', 'w') as f:
    f.write(filedata)