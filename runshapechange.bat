"java" -Dfile.encoding=UTF-8 -Dhttp.proxyHost=proxy.vegvesen.no -Dhttp.proxyPort=8080 -jar "C:\Program Files (x86)\Arkitektum AS\ShapeChange\ShapeChange.jar" -c "C:\DATA\GitHub\NVDBGML\config\ShapeChangeConfiguration.xml"
Mkdir C:\DATA\GitHub\NVDBGML\XSD\NVDB\107
Del /Q C:\DATA\GitHub\NVDBGML\XSD\NVDB\107\*.*
Move C:\DATA\GitHub\NVDBGML\XSD\INPUT\*.* C:\DATA\GitHub\NVDBGML\XSD\NVDB\107\
