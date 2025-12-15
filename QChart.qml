import QtQuick
import QtQuick.Window
import QtQuick.Controls

import QtCharts

ApplicationWindow {
    width: 700
    height: 500
    visible: true
    title: "Simple ChartView Example"

    MouseArea {
        id: catchAllClicks
        anchors.fill: parent
        acceptedButtons: Qt.MiddleButton | Qt.LeftButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.MiddleButton) {
                rectChart.x = mouse.x - 150
                rectChart.y = mouse.y - 150
                chart.visible = true
            }else if(mouse.button === Qt.LeftButton){
                chart.visible = false
            }
        }
    }


    Rectangle{
        id: rectChart
        width: 300
        height: 300
        color: "red"
        ChartView {
            id: chart
            // title: "Production Costs"
            // anchors.fill: parent
            width: 350
            height: 350
            legend.visible: false
            antialiasing: true
            backgroundColor: "transparent"
            animationDuration: 2000
            animationOptions: ChartView.AllAnimations
            visible: false


            PieSeries {
                id: pieOuter
                size: 1
                holeSize: 0.2
                // PieSlice { id: slice; label: "Alpha"; value: 19511; color: "#99CA53" }
                // PieSlice { label: "Epsilon"; value: 11105; color: "#209FDF" }
                // PieSlice { label: "Psi"; value: 9352; color: "#F6A625" }
            }

            Repeater {
                model: cicularMenuModel
                delegate: Item {
                    QtObject {
                        Component.onCompleted: {
                            // let imgLabel = "<img src='/home/client121/Documents/ali/qt-test/QCharts/AircraftIcon.png' width='20' height='20'/> " + model.label
                            pieOuter.append(model.label, model.value)
                            // console.log(pieOuter.horizontalPosition, pieOuter.verticalPosition)
                            let slice = pieOuter.at(pieOuter.count - 1)
                            // console.log(slice.label)
                            slice.color = model.color
                            slice.labelVisible = true
                            slice.labelPosition = PieSlice.LabelInsideHorizontal
                            slice.borderWidth = 3

                            slice.clicked.connect(function() {
                                cicularMenuModel.cicularClicked(label)
                            })
                        }
                    }
                }
            }

//             // PieSeries {
//             //     size: 0.7
//             //     id: pieInner
//             //     holeSize: 0.25

//             //     PieSlice { label: "Materials"; value: 10334; color: "#B9DB8A" }
//             //     PieSlice { label: "Employee"; value: 3066; color: "#DCEDC4" }
//             //     PieSlice { label: "Logistics"; value: 6111; color: "#F3F9EB" }

//             //     PieSlice { label: "Materials"; value: 7371; color: "#63BCE9" }
//             //     PieSlice { label: "Employee"; value: 2443; color: "#A6D9F2" }
//             //     PieSlice { label: "Logistics"; value: 1291; color: "#E9F5FC" }

//             //     PieSlice { label: "Materials"; value: 4022; color: "#F9C36C" }
//             //     PieSlice { label: "Employee"; value: 3998; color: "#FCE1B6" }
//             //     PieSlice { label: "Logistics"; value: 1332; color: "#FEF5E7" }
//             // }

//             // Component.onCompleted: {
//             //     // Set the common slice properties dynamically for convenience
//             //     for (var i = 0; i < pieOuter.count; i++) {
//             //         pieOuter.at(i).labelPosition = PieSlice.LabelInsideNormal;
//             //         pieOuter.at(i).labelVisible = true;
//             //         pieOuter.at(i).borderWidth = 3;
//             //     }
//             //     // for (var i = 0; i < pieInner.count; i++) {
//             //     //     pieInner.at(i).labelPosition = PieSlice.LabelInsideNormal;
//             //     //     pieInner.at(i).labelVisible = true;
//             //     //     pieInner.at(i).borderWidth = 2;
//             //     // }
//             // }
        }

    }


}
