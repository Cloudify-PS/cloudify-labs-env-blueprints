import sys

full_name = sys.argv[1]


ga_body = """<!-- Google Tag Manager (noscript) -->
<noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-PGLWXPL"
                  height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
<!-- End Google Tag Manager (noscript) -->"""

ga_head = """<!-- Google Tag Manager -->
    <script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
        new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
        j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
        'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
    })(window,document,'script','dataLayer','GTM-PGLWXPL');</script>
    <!-- End Google Tag Manager -->"""


pure_chat = """<script type='text/javascript' data-cfasync='false'>window.purechatApi = { l: [], t: [], on: function () { this.l.push(arguments); } }; (function () { var done = false; var script = document.createElement('script'); script.async = true; script.type = 'text/javascript'; script.src = 'https://app.purechat.com/VisitorWidget/WidgetScript'; document.getElementsByTagName('HEAD').item(0).appendChild(script); script.onreadystatechange = script.onload = function (e) { if (!done && (!this.readyState || this.readyState == 'loaded' || this.readyState == 'complete')) { var w = new PCWidget({c: 'bbcb64c5-fcd5-4620-996b-dcf32384bfb0', f: true }); done = true; } }; })();</script>"""


if "@" in full_name:
    mail = full_name.split('-')[-2]
    spl = mail.split('@')
    name, company = spl[0], spl[1]
    company = company.split('.')[0]
    lab_name = name + "-" + company
else:
    lab_name = full_name

## replace lab name in index.html file
# Read in the file
with open('/opt/cloudify-stage/dist/index.html', 'r') as f:
    filedata = f.read()
# Replace the target string
filedata = filedata.replace('Cloudify UI', ('Cloudify UI - cloudify-lab - '+lab_name))
# Write the file out again
with open('/opt/cloudify-stage/dist/index.html', 'w') as f:
    f.write(filedata)



with open('/opt/cloudify-stage/dist/index.html', 'r') as f:
    filedata = f.read()
# Replace the target string
filedata = filedata.replace('</head>', (ga_head + '\n</head>'))
# Write the file out again
with open('/opt/cloudify-stage/dist/index.html', 'w') as f:
    f.write(filedata)


with open('/opt/cloudify-stage/dist/index.html', 'r') as f:
    filedata = f.read()
# Replace the target string
filedata = filedata.replace('<body>', ('<body>\n' +ga_body))
# Write the file out again
with open('/opt/cloudify-stage/dist/index.html', 'w') as f:
    f.write(filedata)


with open('/opt/cloudify-stage/dist/index.html', 'r') as f:
    filedata = f.read()
# Replace the target string
filedata = filedata.replace('</body>', (pure_chat + '\n</body>'))
# Write the file out again
with open('/opt/cloudify-stage/dist/index.html', 'w') as f:
    f.write(filedata)
