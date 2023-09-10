# This Python file uses the following encoding: utf-8
import sys
import requests
import json
from PySide6.QtCore import QObject, Slot, Signal
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine


class EmissionsCalculator(QObject):
    showRoute = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self.api_key = "AIzaSyBz5OjUxNTQ8s4Xps881yCAGrSEITSUWwY" # replace with your actual API key

    def get_coordinates(self, location):
        # Prepare the API endpoint
        url = "https://maps.googleapis.com/maps/api/geocode/json"

        # Prepare the request parameters
        params = {
            "address": location,
            "key": self.api_key
        }

        # Send the request
        response = requests.get(url, params=params, verify=False)
        # Check for a successful response
        if response.status_code == 200:
            # Parse the response
            data = response.json()

            # Extract and return the coordinates
            if data["status"] == "OK":
                result = data["results"][0]
                location = result["geometry"]["location"]
                return location["lat"], location["lng"]
            else:
                return None
        else:
            return None

    @Slot(str, str, str, int, str, result=str)
    def calculate(self, origin, destination, carrier_code, flight_number, departure_date):

        # Get the coordinates of the origin and destination
        origin_coords = self.get_coordinates(origin)
        destination_coords = self.get_coordinates(destination)

        if origin_coords is None or destination_coords is None:
            return "Error: Failed to retrieve coordinates"

        # Update the coordinates in QML
        engine.rootContext().setContextProperty("originLatitude", origin_coords[0])
        engine.rootContext().setContextProperty("originLongitude", origin_coords[1])
        engine.rootContext().setContextProperty("destinationLatitude", destination_coords[0])
        engine.rootContext().setContextProperty("destinationLongitude", destination_coords[1])

        # Trigger a QML update
        engine.rootObjects()[0].update()

        # Prepare the API endpoint
        url = f"https://travelimpactmodel.googleapis.com/v1/flights:computeFlightEmissions?key={self.api_key}"

        # Prepare the request body
        body = {
            "flights": [
                {
                    "origin": origin,
                    "destination": destination,
                    "operating_carrier_code": carrier_code,
                    "flight_number": flight_number,
                    "departure_date": {
                        "year": int(departure_date.split('-')[0]),
                        "month": int(departure_date.split('-')[1]),
                        "day": int(departure_date.split('-')[2])
                    }
                }
            ]
        }

        # Send the request
        response = requests.post(url, headers={"Content-Type": "application/json"}, data=json.dumps(body), verify=False)

        # Check for a successful response
        if response.status_code == 200:
            # Parse the response
            data = response.json()

            # Extract and return the emissions in grams per passenger for economy class
            return str(data['flightEmissions'][0]['emissionsGramsPerPax']['economy'])
        else:
            return "Error: " + response.text

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()
    calculator = EmissionsCalculator()
    engine.rootContext().setContextProperty("calculator", calculator)
    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)


    # Bind the QML engine to a variable for easy access
    qmlEngine = engine

    sys.exit(app.exec())
