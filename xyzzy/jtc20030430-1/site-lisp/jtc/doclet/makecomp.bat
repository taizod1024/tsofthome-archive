set SRCPATH=c:\jdk1.3\src 
set CMD=javadoc -doclet ListClass -sourcepath %SRCPATH%
%CMD% java.lang java.io java.util           > ..\complete\java.lst
%CMD% java.awt java.awt.image java.awt.peer > ..\complete\java_awt.lst
%CMD% java.net java.applet                  > ..\complete\java_net_applet.lst
