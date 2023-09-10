import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtLocation 5.6
import QtPositioning 5.6


Window {
    visible: true
    width: 390
    height: 844
    title: "FlyNeutral"
    color: "transparent"

    property string uiState: "input"
    property real totalCarbon: 0
    property int totalTrees: 0

    function resetTextFields() {
        origin.text = ""
        destination.text = ""
        carrierFlight.text = ""
        departureDate.text = ""
    }


    Rectangle {
        anchors.fill: parent
        color: "#2D81FF" // Set the background color to 2D81FF

        ColumnLayout {
            anchors.bottom: parent.bottom
            spacing: 10
            width: parent.width

            // Insert Map here
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 550

                Map {
                    id: map
                    anchors.fill: parent
                    plugin: Plugin {
                        name: "osm" // or the appropriate plugin name for your map provider
                    }

                    // Bind the map center to the updated coordinates
                    center: QtPositioning.coordinate(originLatitude, originLongitude)
                    zoomLevel: 12

                    MapPolyline {
                        line.width: 3
                        line.color: "blue"
                        path: [
                            QtPositioning.coordinate(originLatitude, originLongitude),
                            QtPositioning.coordinate(destinationLatitude, destinationLongitude)
                        ]
                    }
                }
            }

            RowLayout {
                spacing: 10
                Layout.alignment: Qt.AlignHCenter
                visible: uiState === "input"

                TextField {
                    id: origin
                    placeholderText: "Origin"
                    Layout.preferredWidth: 176
                    Layout.preferredHeight: 43
                    font.pixelSize: 20 // Adjust the value to set the placeholder text size
                    font.weight: Font.DemiBold

                    background: Rectangle {
                        color: "white"
                        radius: 21
                    }

                    // Align the placeholder text in the middle
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                }

                TextField {
                    id: destination
                    placeholderText: "Destination"
                    Layout.preferredWidth: 176
                    Layout.preferredHeight: 43
                    font.pixelSize: 20 // Adjust the value to set the placeholder text size
                    font.weight: Font.DemiBold

                    background: Rectangle {
                        color: "white"
                        radius: 21
                    }

                    // Align the placeholder text in the middle
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                }
            }

            RowLayout {
                spacing: 10
                Layout.alignment: Qt.AlignHCenter
                visible: uiState === "input"

                TextField {
                    id: carrierFlight
                    placeholderText: "Flight Number"
                    Layout.preferredWidth: 176
                    Layout.preferredHeight: 43
                    font.pixelSize: 20 // Adjust the value to set the placeholder text size
                    font.weight: Font.DemiBold

                    background: Rectangle {
                        color: "white"
                        radius: 21
                    }

                    // Align the placeholder text in the middle
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                }

                TextField {
                    id: departureDate
                    placeholderText: "Departure Date"
                    Layout.preferredWidth: 176
                    Layout.preferredHeight: 43
                    font.pixelSize: 20 // Adjust the value to set the placeholder text size
                    font.weight: Font.DemiBold

                    background: Rectangle {
                        color: "white"
                        radius: 21
                    }

                    // Align the placeholder text in the middle
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                }
            }

            RowLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                visible: uiState === "input"

                Button {
                    id: submitButton
                    text: "Calculate"
                    hoverEnabled: false // Disable default hover behavior

                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 36

                    background: Rectangle {
                        color: submitButton.pressed ? "lightgray" : "#A7C2EA"
                        radius: 21 // Use the same radius as the TextFields
                    }
                    contentItem: Text {
                        text: submitButton.text
                        font.weight: Font.DemiBold
                        font.pixelSize: 20
                        color: submitButton.enabled ? "#6F6E6E" : "lightgray"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true // Enable custom hover behavior

                        onEntered: {
                            submitButton.background.color = "#B6D4F1" // Customize hover color
                        }

                        onExited: {
                            submitButton.background.color = submitButton.pressed ? "lightgray" : "#A7C2EA"
                        }

                        onClicked: {
                            var carrierFlightText = carrierFlight.text
                            var match = carrierFlightText.match(/([A-Za-z]+)(\d+)/)
                            if (match) {
                                var carrierCodeText = match[1]
                                var flightNumberText = match[2]
                                var carbon = 0.001 * calculator.calculate(origin.text, destination.text, carrierCodeText, parseInt(flightNumberText), departureDate.text);
                                carbon = carbon.toFixed(2)
                                var trees = Math.round((carbon / 1000) * 38.5);

                                totalCarbon += parseFloat(carbon); // update totalCarbon
                                totalTrees += trees; // update totalTrees

                                resultText.text = "Donate " + totalTrees + " trees to offset your total Carbon Emissions of " + totalCarbon + " kg CO2";

                                uiState = "result"
                            } else {
                                resultTextInRectangle.text = "Invalid flight number format."
                                uiState = "result"
                            }
                        }
                    }
                }


            }

            ColumnLayout {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10
                visible: uiState === "result"
                Layout.alignment: Qt.AlignHCenter

                Rectangle {
                    id: resultRectangle
                    color: "black"
                    radius: 20
                    width: 368
                    height: 65
                    visible: uiState === "result"
                    clip: true

                    Item {
                        id: contentContainer
                        anchors.centerIn: parent
                        width: resultRectangle.width
                        height: resultRectangle.height

                        Text {
                            id: resultText
                            text: ""
                            color: "white"
                            font.bold: true
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                            verticalAlignment: Text.AlignVCenter
                            width: contentContainer.width - treeImage.width - 20 // Subtract image width and some margin
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Image {
                            id: treeImage
                            source: "images/tree.png"
                            width: 50
                            height: 50
                            anchors.left: resultText.right
                            anchors.verticalCenter: parent.verticalCenter
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            Qt.openUrlExternally("https://www.teamtrees.org/")
                        }
                        onEntered: {
                            resultRectangle.color = "#808080"
                        }
                        onExited: {
                            resultRectangle.color = "black"
                        }
                    }
                }

                Button {
                    id: addFlightButton
                    text: "Add Flight"
                    hoverEnabled: false // Disable default hover behavior

                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignHCenter

                    background: Rectangle {
                        color: addFlightButton.pressed ? "lightgray" : "#A7C2EA"
                        radius: 21 // Use the same radius as the TextFields
                    }
                    contentItem: Text {
                        text: addFlightButton.text
                        font.weight: Font.DemiBold
                        font.pixelSize: 20
                        color: addFlightButton.enabled ? "#6F6E6E" : "lightgray"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true // Enable custom hover behavior

                        onEntered: {
                            addFlightButton.background.color = "#B6D4F1" // Customize hover color
                        }

                        onExited: {
                            addFlightButton.background.color = addFlightButton.pressed ? "lightgray" : "#A7C2EA"
                        }

                        onClicked: {
                            uiState = "input"
                            resetTextFields(); // Call the resetTextFields function
                        }
                    }
                }

                Button {
                    id: startOverButton
                    text: "Start Over"
                    hoverEnabled: false // Disable default hover behavior

                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignHCenter

                    background: Rectangle {
                        color: startOverButton.pressed ? "lightgray" : "#A7C2EA"
                        radius: 21 // Use the same radius as the TextFields
                    }
                    contentItem: Text {
                        text: startOverButton.text
                        font.weight: Font.DemiBold
                        font.pixelSize: 20
                        color: startOverButton.enabled ? "#6F6E6E" : "lightgray"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true // Enable custom hover behavior

                        onEntered: {
                            startOverButton.background.color = "#B6D4F1" // Customize hover color
                        }

                        onExited: {
                            startOverButton.background.color = startOverButton.pressed ? "lightgray" : "#A7C2EA"
                        }

                        onClicked: {
                            uiState = "input"
                            resetTextFields(); // Call the resetTextFields function
                            totalCarbon = 0; // reset totalCarbon
                            totalTrees = 0; // reset totalTrees
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 20  // Adjust this value to set the amount of space you want.
            }

        }
    }

    Rectangle {
        id: titleBackground
        color: "transparent"
        height: 150
        width: parent.width
        anchors.top: parent.top

        Text {
            id: titleText
            text: "FlyNeutral"
            font.bold: true
            color: "white"
            font.pixelSize: 36
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
