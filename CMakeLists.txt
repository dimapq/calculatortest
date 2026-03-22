cmake_minimum_required(VERSION 3.16)
project(calctest VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup()

qt_add_executable(appcalctest

    calculatorengine.cpp
    calculatorengine.h
    main.cpp
    main.qml

)

set_target_properties(appcalctest PROPERTIES
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appcalctest PRIVATE Qt6::Quick)

