#changed paths - kreuschner-mar2025
export DASHBOARD_PATH=~/git/public-svn/shared/sounding-board/ccc/
export CURRENT_PATH=~/git/public-svn/shared/sounding-board/current/

default:
	Rscript --default-packages=tidyr --verbose CCC_dashboard_privaterPersonenverkehr_MK.R
	#Rscript --default-packages=tidyr --verbose CCC_dashboard_gueterverkehr.R
	#head -11 CCC_dashboard_gueter.csv
	-rm ${DASHBOARD_PATH}/CCC_dashboard_privaterPersonenverkehr_MK.csv
	mv CCC_dashboard_privaterPersonenverkehr_MK.csv ${DASHBOARD_PATH}
	#cd ${DASHBOARD_PATH} ; /opt/homebrew/bin/svn update ;/opt/homebrew/bin/svn commit -m "commit new version"

current:
	Rscript --default-packages=tidyr --verbose current_dashboard_privaterPersonenverkehr_KN.R
	-rm ${CURRENT_PATH}/current-dashboard-v1.1.csv
	mv current-dashboard-v1.1.csv ${CURRENT_PATH}
	cd ${CURRENT_PATH} ; /opt/homebrew/bin/svn update ;/opt/homebrew/bin/svn commit -m "commit new version"
