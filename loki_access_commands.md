Loki-Access Commands
====================

```bash
# curl -b JSESSIONID_6080=lf2dao78rr9u -c cookie.txt -o engines.xml http://loki.mayo.edu:6080/service/engines.xml
```

```bash
# curl -b JSESSIONID_6080=lf2dao78rr9u -c cookie.txt -o engines.xml http://loki.mayo.edu:6080/service/engines.xml
```

```bash
export GREP=/usr/local/bin/ggrep
if [[ -z "${LOKIP2}" ]]; then read -s -p "Enter Loki password: " LOKIP2 ; fi ; curl --cookie-jar cookie.txt -X POST -H "Connection: keep-alive" -H "Content-Type: application/x-www-form-urlencoded" -d "username=m243189&password=${LOKIP2}" http://loki.mayo.edu:6080/login/security_check ; SESSIONID=$(${GREP} -Po "JSESSIONID_6080\t\w+" cookie.txt | awk '{print $2}') ; 
```

```bash
curl -b JSESSIONID_6080=${SESSIONID} -c cookie.txt -X POST -H "Connection: keep-alive" -H "Content-Type: application/x-www-form-urlencoded" -d "e=test2%2Ftestdir1%2F%7Cwindows%2F&order=name" -o directory_name.xml http://loki.mayo.edu:6080/start/DirectoryService

curl -b JSESSIONID_6080=${SESSIONID} -c cookie.txt -X POST -H "Connection: keep-alive" -H "Content-Type: application/x-www-form-urlencoded" -d "e=test2%2Ftestdir2%2F%7Cwindows%2F&order=date" -o directory_date.xml http://loki.mayo.edu:6080/start/DirectoryService
```

## Sample cookies with previous directory information

```
7080-fdd_title=sort=;filter=; 9080-fdd_instrument=filter=20294=1\;1062B=1\;1063B=1\;MA10331C=1\;MA10649C=1\;Exactive Series slot #1085=1\;Exactive Series slot #111=1\;Exactive Series slot #144=1\;Exactive Series slot #2705=1\;Exactive Series slot #291=1\;Exactive Series slot #527=1\;Exactive Series slot #6312=1\;Exactive Series slot #774=1\;Exactive Series slot \\\\\\\\#594=1\;FSN20335=1\;LTQ30471=1\;MA10336C=1\;01475B=1\;Exactive Serie 3384,Exactive Series 3384=1\;Exactive Serie 3093,Q Exactive Plus 3093=1\;Q Exactive Plus 3094,QE_Plus_SN03874L=1\;Exactive Series slot #594=1\;QE3 QExactive Plus 03500L=1\;Exactive Series slot #1=1\;Exactive Series slot #1266=1\;SN01261B=1\;SN01494B=1; 9080-fdd_title=sort=;filter=; fdd_title=sort=;filter=; 7080-exp0=ResearchandDevelopment/Theis/Exploris/Data/FAIMS_Eval_20221202_Ex1/; email=theis.jason@mayo.edu; 6080-exp0=Kurtin%20to%20Dasari/|ResearchandDevelopment/Theis/Exploris/Data/AmyloidStandard10_20230110_IO25cm/|windows/; param=339; JSESSIONID_9080=aeg07795le94; JSESSIONID_8080=1xean7qxxe5dn; JSESSIONID_6080=ugnrzuddc1cs

fo=name; 7080-fdd_title=sort=;filter=; 9080-fdd_instrument=filter=20294=1\;1062B=1\;1063B=1\;MA10331C=1\;MA10649C=1\;Exactive Series slot #1085=1\;Exactive Series slot #111=1\;Exactive Series slot #144=1\;Exactive Series slot #2705=1\;Exactive Series slot #291=1\;Exactive Series slot #527=1\;Exactive Series slot #6312=1\;Exactive Series slot #774=1\;Exactive Series slot \\\\\\\\#594=1\;FSN20335=1\;LTQ30471=1\;MA10336C=1\;01475B=1\;Exactive Serie 3384,Exactive Series 3384=1\;Exactive Serie 3093,Q Exactive Plus 3093=1\;Q Exactive Plus 3094,QE_Plus_SN03874L=1\;Exactive Series slot #594=1\;QE3 QExactive Plus 03500L=1\;Exactive Series slot #1=1\;Exactive Series slot #1266=1\;SN01261B=1\;SN01494B=1; 9080-fdd_title=sort=;filter=; fdd_title=sort=;filter=; 7080-exp0=ResearchandDevelopment/Theis/Exploris/Data/FAIMS_Eval_20221202_Ex1/; email=theis.jason@mayo.edu; 6080-exp0=Kurtin%20to%20Dasari/|ResearchandDevelopment/Theis/Exploris/Data/AmyloidStandard10_20230110_IO25cm/|windows/; param=339; JSESSIONID_9080=aeg07795le94; JSESSIONID_8080=1xean7qxxe5dn; JSESSIONID_6080=ugnrzuddc1cs
```


