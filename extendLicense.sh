#!/usr/bin/env bash

rm -rf ~/.java/.userPrefs/
rm -rf ~/.cache/JetBrains/

cd ~/.config/JetBrains/GoLand2020.2/
rm -rf eval
cd options
sed -i '/evl/d' other.xml 

cd ~/.config/JetBrains/IntelliJIdea2020.2/
rm -rf eval
cd options
sed -i '/evl/d' other.xml 
