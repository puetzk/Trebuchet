@echo off
rmdir /q /s %~dp0deploy
mkdir %~dp0deploy
SET QTDIR=C:\Qt\5.3\msvc2013
SET OUTPUT=%~dp0deploy\


copy %~dp0Trebuchet.exe %OUTPUT%

copy %QTDIR%\bin\Qt5Core.dll %OUTPUT%
copy %QTDIR%\bin\Qt5Gui.dll %OUTPUT%
copy %QTDIR%\bin\Qt5Qml.dll %OUTPUT%
copy %QTDIR%\bin\Qt5Multimedia.dll %OUTPUT%
copy %QTDIR%\bin\Qt5Quick.dll %OUTPUT%
copy %QTDIR%\bin\Qt5MultimediaQuick_p.dll %OUTPUT%
copy %QTDIR%\bin\Qt5Network.dll %OUTPUT%
copy %QTDIR%\bin\Qt5Svg.dll %OUTPUT%

mkdir %~dp0\QtQuick.2
call :copydir %QTDIR%\qml QtQuick.2 plugins.qmltypes qmldir qtquick2plugin.dll

call :copydir %QTDIR%\plugins platforms qwindows.dll
call :copydir %QTDIR%\plugins imageformats qjpeg.dll
call :copydir %QTDIR%\plugins mediaservice dsengine.dll qtmedia_audioengine.dll wmfengine.dll
call :copydir %QTDIR%\qml QtQuick\Layouts plugins.qmltypes qmldir qquicklayoutsplugin.dll
call :copydir %QTDIR%\qml QtQuick\Window.2 plugins.qmltypes qmldir windowplugin.dll
call :copydir %QTDIR%\qml QtQuick\Controls plugins.qmltypes qmldir qtquickcontrolsplugin.dll ApplicationWindow.qml CheckBox.qml Slider.qml TextField.qml
REM call :copydir %QTDIR%\qml QtQuick\Controls\Private qmldir style.js AbstractCheckable.qml Control.qml SourceProxy.qml Style.qml
call :copydir %QTDIR%\qml QtQuick\Controls\Private qmldir *.js *.qml
call :copydir %QTDIR%\qml QtQuick\Controls\Styles qmldir
call :copydir %QTDIR%\qml QtQuick\Controls\Styles\Base CheckBoxStyle.qml SliderStyle.qml
call :copydir %QTDIR%\qml QtQuick\Controls\Styles\Base\images check.png
call :copydir %QTDIR%\qml QtQuick\Controls\Styles\Desktop CheckBoxStyle.qml SliderStyle.qml
call :copydir %QTDIR%\qml QtMultimedia plugins.qmltypes qmldir declarative_multimedia.dll Video.qml
call :copydir %QTDIR%\qml QtGraphicalEffects qmldir BrightnessContrast.qml GammaAdjust.qml
call :copydir %QTDIR%\qml QtGraphicalEffects\private SourceProxy.qml

copy %QTDIR%\bin\Qt5Widgets.dll %OUTPUT%
copy %QTDIR%\bin\Qt5MultimediaWidgets.dll %OUTPUT%

REM ANGLE
copy %QTDIR%\bin\libglesv2.dll %OUTPUT%
copy %QTDIR%\bin\libegl.dll %OUTPUT%
copy %QTDIR%\bin\d3dcompiler_47.dll %OUTPUT%


REM unicode
copy %QTDIR%\bin\icuin52.dll %OUTPUT%
copy %QTDIR%\bin\icuuc52.dll %OUTPUT%
copy %QTDIR%\bin\icudt52.dll %OUTPUT%

REM CRT
copy "%VS120COMNTOOLS%..\..\VC\redist\x86\Microsoft.VC120.CRT\msvcr120.dll" %~dp0
copy "%VS120COMNTOOLS%..\..\VC\redist\x86\Microsoft.VC120.CRT\msvcp120.dll" %~dp0

goto :eof

:copydir
@setlocal enableextensions
SET source=%1
SET relative=%2

shift 
shift 

echo %source%\%relative% -- %OUTPUT%%relative%

if not exist "%OUTPUT%%relative%" (
	mkdir %OUTPUT%%relative%
)

:loop
if "%1" neq "" (
	copy %source%\%relative%\%1 %OUTPUT%%relative%
	shift
	goto :loop
)
goto :eof
