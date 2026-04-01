cmake_minimum_required(VERSION 3.16)
project(calculatortest VERSION 0.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
endif()

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Core Svg)

qt_standard_project_setup()

qt_add_executable(appcalculatortest
    main.cpp
    calculatorengine.cpp
    calculatorengine.h
)

qt_add_resources(appcalculatortest "qml_files"
    PREFIX "/"
    FILES main.qml
    SecretPage.qml
)

target_link_libraries(appcalculatortest PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Core
    Qt6::Svg   # обязательно
)
# Добавляем иконки (относительные пути от корня проекта)
qt_add_resources(appcalculatortest "icons"
   FILES
        images/bkt.svg
        images/division.svg
        images/equal.svg
        images/minus.svg
        images/multiplication.svg
        images/percent.svg
        images/plus.svg
        images/plus_minus.svg
)

target_link_libraries(appcalculatortest PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Core
)

set_target_properties(appcalculatortest PROPERTIES
    WIN32_EXECUTABLE TRUE
)