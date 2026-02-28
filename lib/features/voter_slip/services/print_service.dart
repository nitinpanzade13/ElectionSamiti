import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrintService {
  static final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  /// Fetches a list of all paired Bluetooth devices on the worker's phone
  static Future<List<BluetoothDevice>> getPairedPrinters() async {
    try {
      return await _bluetooth.getBondedDevices();
    } catch (e) {
      return [];
    }
  }

  /// Connects to a specific selected printer
  static Future<void> connectToPrinter(BluetoothDevice device) async {
    bool? isConnected = await _bluetooth.isConnected;
    if (isConnected == false) {
      await _bluetooth.connect(device);
    }
  }

  /// Prints the actual voter slip
  static Future<void> printVoterSlip({
    required String voterName,
    required String voterId,
    required String constituency,
    required int wardNumber,
    required int boothNumber,
  }) async {
    bool? isConnected = await _bluetooth.isConnected;

    if (isConnected == true) {
      // Size 0 = Normal, Size 1 = Medium, Size 2 = Large
      // Align 0 = Left, Align 1 = Center, Align 2 = Right

      _bluetooth.printNewLine();
      _bluetooth.printCustom("ELECTION SAMITI", 2, 1);
      _bluetooth.printNewLine();

      _bluetooth.printCustom("--------------------------------", 0, 1);
      _bluetooth.printLeftRight("Voter Name:", voterName, 0);
      _bluetooth.printLeftRight("Voter ID:", voterId, 0);
      _bluetooth.printLeftRight("Constituency:", constituency, 0);
      _bluetooth.printLeftRight(
        "Ward / Booth:",
        "W:$wardNumber | B:$boothNumber",
        0,
      );
      _bluetooth.printCustom("--------------------------------", 0, 1);

      _bluetooth.printNewLine();
      _bluetooth.printCustom("Please bring valid ID proof.", 0, 1);
      _bluetooth.printNewLine();
      _bluetooth.printNewLine();

      // Cuts the paper (if the printer supports auto-cut)
      _bluetooth.paperCut();
    } else {
      throw Exception(
        'Printer is not connected. Please connect a device first.',
      );
    }
  }
}
