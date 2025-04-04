import 'package:farematch_driver/model/address_model.dart';
import 'package:flutter/cupertino.dart';

class AppInf0 extends ChangeNotifier {
  AddressModel? pickUpLocation;
  AddressModel? dropOffLocation;

  get pickupAddress => null;

  get dropoffAddress => null;

  void updatePickUpLocation(AddressModel pickUpModel) {
    pickUpLocation = pickUpModel;
    notifyListeners();
  }

  void updateDropOffLocation(AddressModel dropOffModel) {
    dropOffLocation = dropOffModel;
    notifyListeners();
  }
}
