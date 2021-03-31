#!/bin/sh

#  Script.sh
#  VideoPlayerLib
#
#  Created by lzz on 2019/4/10.
#  Copyright © 2019 lzz. All rights reserved.

#注意：脚本目录和xxxx.xcodeproj要在同一个目录，如果放到其他目录，请自行修改脚本。
#要build的target名
target_Name=MyFrameWork
echo "target_Name=${target_Name}"

#工程名
project_name=$target_Name
echo "project_name=${project_name}"

#打包模式 Debug/Release 默认是Release
development_mode=Release


#当前脚本文件所在的路径 $(pwd)
SCRIPT_DIR=$(pwd)
echo "======脚本路径=${SCRIPT_DIR}======"

#工程路径
#PROJECT_DIR=${SCRIPT_DIR} 和下面写法也样
PROJECT_DIR=$SCRIPT_DIR
echo "======工程路径=${PROJECT_DIR}======"

#build之后的文件夹路径
build_DIR=$SCRIPT_DIR/Build
echo "======Build路径=${build_DIR}======"

#真机build生成的.framework 文件路径
DEVICE_DIR=${build_DIR}/${development_mode}-iphoneos/${project_name}.framework

#真机build生成的sdk文件路径
DEVICE_DIR_A=${build_DIR}/${development_mode}-iphoneos/${project_name}.framework/${project_name}
echo "======真机.framework路径=${DEVICE_DIR_A}======"

#模拟器build生成的sdk文件路径
SIMULATOR_DIR_A=${build_DIR}/${development_mode}-iphonesimulator/${project_name}.framework/${project_name}
echo "======模拟器.framework路径=${SIMULATOR_DIR_A}======"



#目标文件夹路径（也就SDK的文件：.framework文件 和 bundle文件）
INSTALL_DIR=${build_DIR}/Products/${project_name}
echo "======SDK的文件夹路径=${INSTALL_DIR}======"

#目标 sdk 路径
INSTALL_DIR_A=${build_DIR}/Products/${project_name}/${project_name}.framework/${project_name}
echo "======目标sdk路径=${INSTALL_DIR_A}======"

#sdk最终保存的路径
PRODUCTS_DIR=$SCRIPT_DIR/Products
echo "======PRODUCTS_DIR最终保存的路径=${PRODUCTS_DIR}======"

#判断build文件夹是否存在，存在则删除
#rm -rf 命令的功能:删除一个目录中的一个或多个文件或目录
if [ -d "${build_DIR}" ]
then
rm -rf "${build_DIR}"
fi


#判断目标文件夹是否存在，存在则删除该文件夹
if [ -d "${INSTALL_DIR}" ]
then
rm -rf "${INSTALL_DIR}"
fi

#判断最终保存目标文件夹是否存在，存在则删除该文件夹
if [ -d "${PRODUCTS_DIR}" ]
then
rm -rf "${PRODUCTS_DIR}"
fi


#创建目标文件夹
mkdir -p "${INSTALL_DIR}"



echo "======盒子已经准备好了，开始生产.a 并合成装到盒子里吧======"

#build之前clean一下
xcodebuild -target ${target_Name} -configuration ${development_mode} -sdk iphonesimulator clean

xcodebuild -target ${target_Name} -configuration ${development_mode} -sdk iphoneos clean

#模拟器build
xcodebuild -target ${target_Name} -configuration ${development_mode} -sdk iphonesimulator

#真机build
xcodebuild -target ${target_Name} -configuration ${development_mode} -sdk iphoneos


#1.复制真机的${project_name}.framework到目标文件夹
#使用-R参数可实现递归功能，即所有子目录中的文件与目录均拷贝
cp -R "${DEVICE_DIR}" "${INSTALL_DIR}"

#2.删除真机 INSTALL_DIR 中原来的MySDK 文件
#判断目标文件夹是否存在，存在则删除该文件夹
if [ -f "${INSTALL_DIR_A}" ]
then
rm -f "${INSTALL_DIR_A}"
fi



#合成模拟器和真机 MySDK 文件替换目标文件夹中${project_name}.framework 下的 真机 MySDK 文件
lipo -create "${DEVICE_DIR_A}" "${SIMULATOR_DIR_A}" -output "${INSTALL_DIR_A}"

echo "======合成结束======"


cp -R "${build_DIR}/Products" "${PRODUCTS_DIR}"

# -f 判断文件是否存在
if [ -f "${PRODUCTS_DIR}/${project_name}/${project_name}.framework/${project_name}" ]
then
echo "======验证合成包是否成功======"
lipo -info "${PRODUCTS_DIR}/${project_name}/${project_name}.framework/${project_name}"
fi

if [ -d "${build_DIR}" ]
then
echo "======删除${build_DIR}======"
rm -rf "${build_DIR}"
fi


#打开目标文件夹
#open "${INSTALL_DIR}"
open "${PRODUCTS_DIR}"
