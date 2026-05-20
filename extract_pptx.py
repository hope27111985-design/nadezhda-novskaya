import zipfile
import re
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

pptx_path = r"C:\Users\MSI-\Desktop\Сеул 2026\итоги Сеул апрель 2026 врачи.pptx"

with zipfile.ZipFile(pptx_path) as z:
    texts = []
    for name in z.namelist():
        if name.startswith("ppt/slides/slide") and name.endswith(".xml"):
            xml = z.read(name).decode('utf-8')
            matches = re.findall(r'<a:t[^>]*>([^<]+)</a:t>', xml)
            for t in matches:
                t = t.strip()
                if t and not t.isdigit():
                    texts.append(t)

seen = set()
for t in texts:
    if t not in seen:
        print(t)
        seen.add(t)
