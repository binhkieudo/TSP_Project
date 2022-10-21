!#bin/bash
source /opt/xilinx/xrt/setup.sh
echo $HOME
var=($PWD)

if [ -d "$HOME/Desktop/TSP.temp/" ]
then
	echo "Directory exist"
else
	echo "Not exist"
	mkdir $HOME/Desktop/TSP.temp
	cd $HOME/Desktop/TSP.temp
	mkdir config exe bin result.hit result.summary
fi

#install dependencies
sudo apt install default-jre
sudo apt install libboost-dev

#copy bin
echo Copy executable...
echo $var
cd $var
pwd
cp -rf bin/ $HOME/Desktop/TSP.temp/
echo Completed

#load bitstream



#create dummy setting.mk
echo Create dummy setting.mk
pwd
cd $HOME/Desktop/TSP.temp/config/
touch setting.mk
echo Completed

#build program
echo Build host program...
cd $var/build/
pwd
make tsp-program
make tsp-host
cd ../
echo Completed

#copy exe
echo Copy executable...
echo $var
cd $var/build/
cp Makefile tsp-program tsp-host program.sh search.sh xrt.ini $HOME/Desktop/TSP.temp/exe
cd $HOME/Desktop/TSP.temp/exe
chmod +x tsp-program tsp-host program.sh search.sh
pwd
echo Completed

#untar presets
echo Extracting preset text...
cd $var
tar -xf test-data.tar.xz --directory $HOME/Desktop/TSP.temp/
echo Extracted

#make executable
echo make gui executable
cd $var/gui/
chmod +x TSP_GUI_application.jar
echo Finished

echo Setup Finish
